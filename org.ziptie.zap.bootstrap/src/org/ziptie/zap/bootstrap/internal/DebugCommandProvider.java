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
package org.ziptie.zap.bootstrap.internal;

import java.lang.reflect.Field;

import org.eclipse.osgi.framework.console.CommandInterpreter;
import org.eclipse.osgi.framework.console.CommandProvider;
import org.eclipse.osgi.framework.debug.Debug;


// CHECKSTYLE:OFF
/**
 * Provides a console command that allows for enabling and disabling {@link Debug} properties.
 */
@SuppressWarnings("restriction")
public class DebugCommandProvider implements CommandProvider
{
    public String getHelp()
    {
        return "\n---ZipTie Debug Commands---\n\tztdebug <property> (<true>|<false>) Enables/disables debug properties."; //$NON-NLS-1$
    }

    public void _ztdebug(CommandInterpreter ci)
    {
        String key = ci.nextArgument();
        if (key == null)
        {
            ci.println("Must specify a property"); //$NON-NLS-1$
        }

        boolean enabled = true;
        String value = ci.nextArgument();
        if (value != null)
        {
            enabled = Boolean.parseBoolean(value);
        }

        try
        {
            Field field = Debug.class.getDeclaredField(key.toUpperCase());
            field.set(null, enabled);
        }
        catch (Exception e)
        {
            ci.println(e.getMessage());
        }
    }
}
