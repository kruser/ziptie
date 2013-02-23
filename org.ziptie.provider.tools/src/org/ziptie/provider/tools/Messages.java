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
package org.ziptie.provider.tools;

import org.eclipse.osgi.util.NLS;

/**
 * Messages for the provider commands bundle.
 */
public final class Messages extends NLS
{
    public static String CommandSetJob_cancelled;
    public static String CommandSetJob_exception;
    public static String CommandSetJob_starting;
    public static String CommandSetJob_success;
    public static String ScriptPluginManager_pluginTypeDisplayName;
    public static String ScriptToolJob_canceled;
    public static String ScriptToolJob_exception;
    public static String ScriptToolJob_startingTool;
    public static String ScriptToolJob_success;
    public static String ScriptToolManager_discoveredTool;
    public static String ScriptToolManager_errorReadingProperties;
    public static String ScriptToolManager_scanningBundles;
    public static String ScriptToolManager_totalToolsDiscovered;

    static
    {
        // initialize resource bundle
        NLS.initializeMessages("org.ziptie.provider.tools.messages", Messages.class); //$NON-NLS-1$
    }

    private Messages()
    {
    }
}
