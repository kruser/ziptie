/* $Id: IndentingXMLEventWriter.java,v 1.1 2008/10/06 21:40:20 mdessureault Exp $
 *
 * Copyright (c) 2004, Sun Microsystems, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of Sun Microsystems, Inc. nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package javanet.staxutils;

import java.io.IOException;
import java.io.Writer;
import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.stream.Location;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.Characters;
import javax.xml.stream.events.EndElement;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;

/**
 * Wraps another {@link XMLEventWriter} and does the indentation.
 *
 * <p>
 * {@link XMLEventWriter} API doesn't provide any portable way of
 * doing pretty-printing. This {@link XMLEventWriter} filter provides
 * a portable indentation support by wrapping another {@link XMLEventWriter}
 * and adding proper {@link Characters} event for indentation.
 *
 * <p>
 * Because whitespace handling in XML is tricky, this is not an
 * one-size-fit-all indentation engine. Instead, this class is
 * focused on handling so-called "data-oritented XML" like follows:
 *
 * <pre><xmp>
 * <cards>
 *   <card id="kk.152">
 *     <firstName>Kohsuke</firstName>
 *     <lastName>Kawaguchi</lastName>
 *   </card>
 * </cards>
 * </xmp></pre>
 *
 * <p>
 * We'll discuss more about the supported subset of XML later.
 *
 * <p>
 * To use this engine, do as follows:
 * <pre>
 * {@link XMLEventWriter} w = xmlOutputFactory.createXMLEventWriter(...);
 * w = new {@link IndentingXMLEventWriter}(w);
 *
 * // start writing
 * </pre>
 *
 * <p>
 * Use {@link #setIndent(String)} and {@link #setNewLine(String)} to
 * control the indentation if you want.
 *
 *
 * <h2>What Subset Does This Support?</h2>
 * <p>
 * This engine works when the content model of each element is either
 * element-only or #PCDATA (but not mixed content model.) IOW, it
 * assumes that the children of any element is either (a) only elements
 * and no #PCDATA or (b) #PCDATA only and no elements.
 *
 * <p>
 * The engine also tries to handle comments, PIs, and a DOCTYPE decl,
 * but in general it works only when those things appear in the
 * element-only content model.
 *
 *
 * <h2>For Maintainers</h2>
 * <p>
 * Please don't try to make this class into an almighty indentation class.
 * I've seen it attempted in Xerces and it's not gonna be pretty.
 *
 * <p>
 * If you come up with an idea of another pretty-printer
 * that supports another subset, please go ahead and write your own class.
 *
 *
 *
 * @author
 *     Kohsuke Kawaguchi (kohsuke.kawaguchi@sun.com)
 */
public class IndentingXMLEventWriter implements  XMLEventWriter {
    private final XMLEventWriter core;

    /**
     * String used for indentation.
     */
    private String indent = "  ";

    /**
     * String for EOL.
     */
    private String newLine;

    /**
     * Current nest level.
     */
    private int depth = 0;

    /**
     * True if the current element has text.
     */
    private boolean hasText;

    /**
     * {@link XMLEvent} constant that returns the {@link #newLine}.
     */
    private final Characters newLineEvent = new CharactersImpl() {
        public String getData() {
            return newLine;
        }
    };

    /**
     * {@link XMLEvent} constant that returns the {@link #indent}.
     */
    private final Characters indentEvent = new CharactersImpl() {
        public String getData() {
            return indent;
        }
    };

    /**
     * Partial implementation of {@link Characters} event.
     */
    private static abstract class CharactersImpl implements  Characters {

        public boolean isWhiteSpace() {
            return true;
        }

        public boolean isCData() {
            return false;
        }

        public boolean isIgnorableWhiteSpace() {
            // this is hard call. On one hand, we want the indentation to
            // get through whatever pipeline, so we are tempted to return false.
            // also DTD isn't necessarily present.
            //
            // But on the other hand, this IS an ignorable whitespace
            // in its intended meaning.
            return true;
        }

        public int getEventType() {
            // it's not clear if we are supposed to return SPACES
            return XMLStreamConstants.CHARACTERS;
        }

        public Location getLocation() {
            // spec isn't clear if we can return null, but it doesn't say we can't.
            return null;
        }

        public boolean isStartElement() {
            return false;
        }

        public boolean isAttribute() {
            return false;
        }

        public boolean isNamespace() {
            return false;
        }

        public boolean isEndElement() {
            return false;
        }

        public boolean isEntityReference() {
            return false;
        }

        public boolean isProcessingInstruction() {
            return false;
        }

        public boolean isCharacters() {
            return true;
        }

        public boolean isStartDocument() {
            return false;
        }

        public boolean isEndDocument() {
            return false;
        }

        public StartElement asStartElement() {
            return null;
        }

        public EndElement asEndElement() {
            return null;
        }

        public Characters asCharacters() {
            return this ;
        }

        public QName getSchemaType() {
            return null;
        }

        public void writeAsEncodedUnicode(Writer writer)
                throws XMLStreamException {
            try {
                // technically we need to do escaping, for we allow
                // any characters to be used for indent and newLine.
                // but in practice, who'll use something other than 0x20,0x0D,0x0A,0x08?
                writer.write(getData());
            } catch (IOException e) {
                throw new XMLStreamException(e);
            }
        }
    };

    public IndentingXMLEventWriter(XMLEventWriter core) {
        if (core == null)
            throw new IllegalArgumentException();
        this.core = core;

        // get the default line separator
        try {
            newLine = System.getProperty("line.separator");
        } catch (SecurityException e) {
            // use '\n' if we can't figure it out
            newLine = "\n";
        }
    }

    /**
     * Returns the string used for indentation.
     */
    public String getIndent() {
        return indent;
    }

    /**
     * Sets the string used for indentation.
     *
     * <p>
     * By default, this is set to two space chars.
     *
     * @param indent
     *      A string like "  ", "\\t". Must not be null.
     */
    public void setIndent(String indent) {
        if (indent == null)
            throw new IllegalArgumentException();
        this.indent = indent;
    }

    /**
     * Returns the string used for newline.
     */
    public String getNewLine() {
        return newLine;
    }

    /**
     * Sets the string used for newline.
     *
     * <p>
     * By default, this is set to the platform default new line.
     *
     * @param newLine
     *      A string like "\\n" or "\\r\\n". Must not be null.
     */
    public void setNewLine(String newLine) {
        if (newLine == null)
            throw new IllegalArgumentException();
        this.newLine = newLine;
    }

    public void add(XMLEvent event) throws XMLStreamException {
        switch (event.getEventType()) {
        case XMLStreamConstants.CHARACTERS:
        case XMLStreamConstants.CDATA:
        case XMLStreamConstants.SPACE:
            if (event.asCharacters().isWhiteSpace())
                // skip any indentation given by the client
                // we are running the risk of ignoring the non-ignorable
                // significant whitespaces, but that's a risk explained
                // in the class javadoc.
                return;

            hasText = true;
            core.add(event);
            return;

        case XMLStreamConstants.START_ELEMENT:
            newLine();
            core.add(event);
            hasText = false;
            depth++;
            return;

        case XMLStreamConstants.END_ELEMENT:
            depth--;
            if (!hasText) {
                newLine();
            }
            core.add(event);
            hasText = false;
            return;

        case XMLStreamConstants.PROCESSING_INSTRUCTION:
        case XMLStreamConstants.COMMENT:
        case XMLStreamConstants.DTD:
            // those things can be mixed with text,
            // and at this point we don't know if text follows this
            // like <foo><?pi?>text</foo>
            //
            // but we make a bold assumption that the those primitives
            // only appear as a part of the element-only content model.
            // so we always indent them as:
            // <foo>
            //   <?pi?>
            //   ...
            // </foo>
            if (!hasText) {
                // if we know that we already had a text, I see no
                // reason to indent
                newLine();
            }
            core.add(event);
            return;

        case XMLStreamConstants.END_DOCUMENT:
            core.add(event);
            // some implementation does the buffering by default,
            // and it prevents the output from appearing.
            // this has been a confusion for many people.
            // calling flush wouldn't hurt decent impls, and it
            // prevent such unnecessary confusion.
            flush();
            break;

        default:
            core.add(event);
            return;
        }
    }

    /**
     * Prints out a new line and indent.
     */
    private void newLine() throws XMLStreamException {
        core.add(newLineEvent);
        for (int i = 0; i < depth; i++)
            core.add(indentEvent);
    }

    public void add(XMLEventReader reader) throws XMLStreamException {
        // we can't just delegate to the core
        // because we need to do indentation.
        if (reader == null)
            throw new IllegalArgumentException();
        while (reader.hasNext()) {
            add(reader.nextEvent());
        }
    }

    public void close() throws XMLStreamException {
        core.close();
    }

    public void flush() throws XMLStreamException {
        core.flush();
    }

    public NamespaceContext getNamespaceContext() {
        return core.getNamespaceContext();
    }

    public String getPrefix(String uri) throws XMLStreamException {
        return core.getPrefix(uri);
    }

    public void setDefaultNamespace(String uri)
            throws XMLStreamException {
        core.setDefaultNamespace(uri);
    }

    public void setNamespaceContext(NamespaceContext context)
            throws XMLStreamException {
        core.setNamespaceContext(context);
    }

    public void setPrefix(String prefix, String uri)
            throws XMLStreamException {
        core.setPrefix(prefix, uri);
    }
}
