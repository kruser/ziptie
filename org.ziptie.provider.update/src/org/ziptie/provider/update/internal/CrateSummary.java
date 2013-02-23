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
package org.ziptie.provider.update.internal;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.ziptie.crates.Crate;
import org.ziptie.crates.CrateException;
import org.ziptie.crates.InstallLocation;
import org.ziptie.provider.update.ISummaryBuilder;

/**
 * Adds the list of installed crates to the summary.
 */
public class CrateSummary implements ISummaryBuilder
{
    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void buildSummary(XMLStreamWriter writer) throws XMLStreamException
    {
        writer.writeStartElement("crates");

        try
        {
            InstallLocation loc = UpdateActivator.getInstallLocation();
            for (Crate crate : loc.getAllCrates())
            {
                writer.writeStartElement("crate");
                writer.writeAttribute("id", crate.getId());
                writer.writeAttribute("version", crate.getVersion());
                writer.writeEndElement();
            }
        }
        catch (CrateException e)
        {
            throw new RuntimeException(e);
        }

        writer.writeEndElement();
    }
}
