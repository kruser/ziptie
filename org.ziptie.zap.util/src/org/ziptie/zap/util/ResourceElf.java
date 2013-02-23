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

package org.ziptie.zap.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Locale;
import java.util.Properties;

import org.osgi.framework.Bundle;

/**
 * A helper for loading resource files in a bundle
 * 
 * @author bwooldridge
 */
public final class ResourceElf
{
    // no reason to ever make one of these
    private ResourceElf()
    {
    }

    /**
     * Load a language resource from the specified bundle for the specified locale.
     *
     * @param bundle the bundle to load resources from
     * @param basename the basename of the resource (e.g. interface.properties)
     * @param locale the locale to load the resource for
     * @return the Properties 
     */
    public static Properties loadLanguageProperties(Bundle bundle, String basename, Locale locale)
    {
        Properties props = new Properties();
        String[] baseSplit = basename.split("\\."); //$NON-NLS-1$

        Object[] variants = { baseSplit[0], locale.getLanguage(), locale.getCountry(), locale.getVariant() };
        String[] formats = { "%s", "%s_%s", "%s_%s_%s", "%s_%s_%s_%s" }; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
        for (int i = 0; i < 4; i++)
        {
            String resourceName = String.format("%s.%s", String.format(formats[i], variants), baseSplit[1]); //$NON-NLS-1$

            URL resource = bundle.getResource(resourceName);
            if (resource != null)
            {
                try
                {
                    InputStream openStream = resource.openStream();
                    props.load(openStream);
                    openStream.close();
                }
                catch (IOException e)
                {
                    continue;
                }
            }
        }

        return props;
    }
}
