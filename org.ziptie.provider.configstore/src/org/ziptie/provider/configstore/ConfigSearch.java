/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 */
package org.ziptie.provider.configstore;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.log4j.Logger;
import org.apache.lucene.document.DateTools;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.TermPositionVector;
import org.apache.lucene.index.TermVectorOffsetInfo;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.LockObtainFailedException;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * ConfigSearch
 */
public class ConfigSearch implements IConfigSearch
{
    private static final Logger LOGGER = Logger.getLogger(ConfigSearch.class);

    private static final String LUCENE_CONFIGURATION = "lucene/configurations"; //$NON-NLS-1$
    private static final String FIELD_UNIQUE_KEY = "uniqueKey"; //$NON-NLS-1$
    private static final String FIELD_DEVICE_ID = "deviceId"; //$NON-NLS-1$
    private static final String FIELD_CONFIGURATION = "text"; //$NON-NLS-1$
    private static final String FIELD_IPADDRESS = "address"; //$NON-NLS-1$
    private static final String FIELD_NETWORK = "network"; //$NON-NLS-1$
    private static final String FIELD_REPOSITORY_PATH = "name"; //$NON-NLS-1$
    private static final String FIELD_TIMESTAMP = "timestamp"; //$NON-NLS-1$
    private static final String FIELD_MIME_TYPE = "mimetype"; //$NON-NLS-1$
    private static final int OPTIMIZATION_FREQ = 500;
    private static int MAX_SEARCH_RESULTS;

    private Lock optimizeLock;
    private AtomicInteger writeCounter;
    private AtomicBoolean indexDirty;
    private IndexWriter writer;
    private AtomicReference<IndexReader> readerReference;
    private AtomicReference<IndexSearcher> searcherReference;
    private File indexFile;

    // CHECKSTYLE:OFF
    static
    {
        MAX_SEARCH_RESULTS = Integer.getInteger("org.ziptie.lucene.maxresults", 500); //$NON-NLS-1$
    }
    // CHECKSTYLE:ON

    /**
     * Default constructor.
     */
    public ConfigSearch()
    {
        optimizeLock = new ReentrantLock();
        writeCounter = new AtomicInteger();
        indexDirty = new AtomicBoolean(true);
        readerReference = new AtomicReference<IndexReader>();
        searcherReference = new AtomicReference<IndexSearcher>();

        indexFile = new File(LUCENE_CONFIGURATION);
        checkIndexIntegrity();
    }

    // ----------------------------------------------------------------------
    //                    IConfigSearch (Remote) Implementation
    // ----------------------------------------------------------------------

    /** {@inheritDoc} */
    public List<ConfigSearchResult> searchConfig(String expression)
    {
        ArrayList<ConfigSearchResult> list = new ArrayList<ConfigSearchResult>();
        if (expression == null || expression.trim().length() == 0)
        {
            return list;
        }

        try
        {
            if (indexDirty.getAndSet(false))
            {
                writer.flush();

                Directory directory = FSDirectory.getDirectory(indexFile);
                readerReference.set(IndexReader.open(directory));
                searcherReference.set(new IndexSearcher(readerReference.get()));
            }

            QueryParser parser = new QueryParser(FIELD_CONFIGURATION, new ZLuceneAnalyzer());
            Query query = parser.parse(expression);

            TopDocs topDocs = searcherReference.get().search(query, null, MAX_SEARCH_RESULTS);
            for (int i = 0; i < topDocs.totalHits; i++)
            {
                ScoreDoc scoreDoc = topDocs.scoreDocs[i];

                Document document = readerReference.get().document(scoreDoc.doc);
                ConfigSearchResult result = new ConfigSearchResult();
                try
                {
                    result.setLastChanged(DateTools.stringToDate(document.getField(FIELD_TIMESTAMP).stringValue()));
                }
                catch (java.text.ParseException e)
                {
                    LOGGER.warn(Messages.ConfigSearch_errorParsingLastChangedDate, e);
                }
                result.setPath(document.getField(FIELD_REPOSITORY_PATH).stringValue());
                result.setIpAddress(document.getField(FIELD_IPADDRESS).stringValue());
                result.setManagedNetwork(document.getField(FIELD_NETWORK).stringValue());
                result.setMimeType(document.getField(FIELD_MIME_TYPE).stringValue());

                TermPositionVector termVector = (TermPositionVector) readerReference.get().getTermFreqVector(scoreDoc.doc, FIELD_CONFIGURATION);
                if (termVector != null)
                {
                    List<ConfigSearchTerm> resultTerms = result.getTerms();

                    Set<Term> termSet = new HashSet<Term>();
                    query.extractTerms(termSet);

                    for (Term term : termSet)
                    {
                        int ndx = termVector.indexOf(term.text());
                        if (ndx >= 0)
                        {
                            TermVectorOffsetInfo[] offsets = termVector.getOffsets(ndx);
                            for (TermVectorOffsetInfo offset : offsets)
                            {
                                ConfigSearchTerm searchTerm = new ConfigSearchTerm();
                                searchTerm.setTerm(term.text());
                                searchTerm.setStartOffset(offset.getStartOffset());
                                searchTerm.setEndOffset(offset.getEndOffset());
                                resultTerms.add(searchTerm);
                            }
                        }
                    }
                }

                list.add(result);
            }
        }
        catch (CorruptIndexException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneCorrupt, e);
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigSearch_errorAccessingLucene, e);
        }
        catch (ParseException e)
        {
            throw new RuntimeException(Messages.ConfigSearch_errorParsingSearchExpression, e);
        }

        return list;
    }

    // ----------------------------------------------------------------------
    //                         Local Server Implementation
    // ----------------------------------------------------------------------

    /**
     * Update (re-index) a configuration file in the index.
     *
     * @param device the device whose configuration is to be updated in the index
     * @param config the ConfigHolder object holding revision information
     */
    public void updateIndex(ZDeviceCore device, ConfigHolder config)
    {
        deleteFromIndex(device, config);
        addToIndex(device, config);
    }

    /**
     * Delete a configuration file from the index.
     *
     * @param device the device whose configuration is to be deleted from
     *    the index
     * @param config the name in the repository of the configuration, this is are repository-
     *    relative path
     */
    public void deleteFromIndex(ZDeviceCore device, ConfigHolder config)
    {
        Term term = new Term(FIELD_UNIQUE_KEY, device.getDeviceId() + config.getFullName());
        try
        {
            maybeOptimize();

            writer.deleteDocuments(term);
            indexDirty.set(true);
        }
        catch (CorruptIndexException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneCorrupt, e);
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigSearch_errorAccessingLucene, e);
        }
    }

    /**
     * Delete all the documents associated with the specified device.
     *
     * @param device the device whose documents to delete.
     */
    public void deleteFromIndex(ZDeviceCore device)
    {
        try
        {
            maybeOptimize();

            Term term = new Term(FIELD_DEVICE_ID, String.valueOf(device.getDeviceId()));
            writer.deleteDocuments(term);
            indexDirty.set(true);
        }
        catch (CorruptIndexException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneCorrupt, e);
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigSearch_errorAccessingLucene, e);
        }
    }

    /**
     * Add a new configuration file to the index.
     *
     * @param device the device whose configuration is to be indexed
     * @param config the ConfigHolder containing change information
     */
    public void addToIndex(ZDeviceCore device, ConfigHolder config)
    {
        try
        {
            maybeOptimize();

            Reader reader = new FileReader(config.getConfigFile());

            Document document = new Document();
            document.add(new Field(FIELD_UNIQUE_KEY, device.getDeviceId() + config.getFullName(), Field.Store.YES, Field.Index.UN_TOKENIZED));
            document.add(new Field(FIELD_DEVICE_ID, String.valueOf(device.getDeviceId()), Field.Store.YES, Field.Index.NO_NORMS));
            document.add(new Field(FIELD_IPADDRESS, String.valueOf(device.getIpAddress()), Field.Store.YES, Field.Index.UN_TOKENIZED));
            document.add(new Field(FIELD_NETWORK, String.valueOf(device.getManagedNetwork()), Field.Store.YES, Field.Index.UN_TOKENIZED));
            document.add(new Field(FIELD_TIMESTAMP, DateTools.dateToString(config.getTimestamp(),
                                                                           DateTools.Resolution.SECOND), Field.Store.YES, Field.Index.NO));
            document.add(new Field(FIELD_REPOSITORY_PATH, config.getFullName(), Field.Store.YES, Field.Index.UN_TOKENIZED));
            document.add(new Field(FIELD_MIME_TYPE, config.getMediaType(), Field.Store.YES, Field.Index.NO));
            document.add(new Field(FIELD_CONFIGURATION, reader, Field.TermVector.WITH_POSITIONS_OFFSETS));

            writer.addDocument(document);

            indexDirty.set(true);
        }
        catch (IOException io)
        {
            LOGGER.error(Messages.bind(Messages.ConfigSearch_unableToIndexConfig, device.getIpAddress()));
        }
    }

    // ----------------------------------------------------------------------
    //                      P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------------

    private void checkIndexIntegrity()
    {
        try
        {
            boolean shouldCreate = !indexFile.exists();

            if (!shouldCreate)
            {
                // Clear any prior write locks
                File writeLock = new File(indexFile, IndexWriter.WRITE_LOCK_NAME);
                if (writeLock.exists())
                {
                    writeLock.delete();
                }
            }

            Directory directory = FSDirectory.getDirectory(indexFile);
            writer = new IndexWriter(directory, new ZLuceneAnalyzer(), shouldCreate);

            indexDirty.set(true);
        }
        catch (CorruptIndexException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneCorrupt, e);
            throw new RuntimeException(e);
        }
        catch (LockObtainFailedException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneLockFailure, e);
            throw new RuntimeException(e);
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigSearch_errorAccessingLucene, e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Depending on the write counter, optimize the index.
     */
    private void maybeOptimize()
    {
        optimizeLock.lock();
        try
        {
            if (writeCounter.incrementAndGet() % OPTIMIZATION_FREQ == 0)
            {
                writer.optimize();
            }
        }
        catch (CorruptIndexException e)
        {
            LOGGER.error(Messages.ConfigSearch_luceneCorrupt, e);
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigSearch_errorAccessingLucene, e);
        }
        finally
        {
            optimizeLock.unlock();
        }
    }
}
