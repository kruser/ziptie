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
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.crates;

import java.util.Set;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * SAX handler for a site xml.
 */
@SuppressWarnings("nls")
class SiteSaxHandler extends DefaultHandler
{
    private static final String ATTR_NAME = "name";

    private CrateRef ref;

    private Set<CrateRef> refs;

    public SiteSaxHandler(Set<CrateRef> refs)
    {
        this.refs = refs;
    }

    /** {@inheritDoc} */
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
    {
        if (qName.equals("crate"))
        {
            ref = new CrateRef();
            ref.setId(attributes.getValue("id"));
            ref.setName(attributes.getValue(ATTR_NAME));
            ref.setVersion(attributes.getValue("version"));
            refs.add(ref);
        }
        else if (qName.equals("category"))
        {
            ref.addCategory(attributes.getValue(ATTR_NAME));
        }
    }
}
