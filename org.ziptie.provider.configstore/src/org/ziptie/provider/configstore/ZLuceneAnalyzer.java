package org.ziptie.provider.configstore;

import java.io.Reader;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.TokenStream;

/**
 * ZLuceneAnalyzer
 */
public class ZLuceneAnalyzer extends Analyzer
{
    /** {@inheritDoc} */
    @Override
    public TokenStream tokenStream(String fieldName, Reader reader)
    {
        return new LowerCaseFilter(new ZLuceneTokenizer(reader));
    }
}
