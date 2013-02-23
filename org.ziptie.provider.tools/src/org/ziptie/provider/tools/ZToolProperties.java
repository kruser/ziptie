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

import static java.lang.Integer.parseInt;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * ZToolProperties
 */
@SuppressWarnings("nls")
public class ZToolProperties
{
    private static final String PLUGIN_RUN_PERMISSION = "plugin.runPermission";
    private static final String SCRIPT_NAME = "script.name"; //$NON-NLS-1$
    private static final String ENABLE_FILTER = "enable.filter"; //$NON-NLS-1$
    private static final Pattern INPUT_PATTERN;

    private Properties properties;
    private Map<Integer, Field> fields;

    static
    {
        INPUT_PATTERN = Pattern.compile("input\\.([0-9]+)\\.?(.*)");
    }

    /**
     * Constructor.
     *
     * @param props the property set associated with this tool.
     *     actual script
     */
    public ZToolProperties(Properties props)
    {
        this.properties = props;

        fields = new HashMap<Integer, Field>();
        parse();
    }

    /**
     * Get literal name of the script to run (eg. ping.pl)
     *
     * @return the name of the tool script
     */
    public String getScriptName()
    {
        String scriptName = properties.getProperty(SCRIPT_NAME).trim();
        String[] splitName = scriptName.split(" ");
        return splitName[0];
    }

    /**
     * Retrieves the LDAP filter string used to check whether or not a tool should be enabled.  If the property
     * does not exist in the script, then an empty string is returned.
     * 
     * @return The enable filter string if the property exists; an empty string otherwise.
     */
    public String getEnableFilterString()
    {
        return this.getProperty(ENABLE_FILTER);
    }

    /**
     * Get the permission, if any, required to run jobs of this plugin type.
     *
     * @return the permission required to run jobs of this plugin type, or null
     */
    public String getRunPermission()
    {
        return this.getProperty(PLUGIN_RUN_PERMISSION);
    }

    /**
     * Get the declared script parameter format string.
     *S
     * @return the format string for the parameters
     */
    public String getScriptParamString()
    {
        String scriptName = properties.getProperty(SCRIPT_NAME).trim();
        int ndx = scriptName.indexOf(' ');
        if (ndx + 1 > 0)
        {
            return scriptName.substring(ndx + 1);
        }

        return "";
    }

    /**
     * Get the display name of the tool.  This is used in the context menu.
     *
     * @return the display name of the tool
     */
    public String getToolName()
    {
        return properties.getProperty("menu.label");
    }

    /**
     * Get the fields for the input to this tool.
     *
     * @return an iterable collection of Fields
     */
    public Iterable<Field> getInputFields()
    {
        LinkedList<Field> result = new LinkedList<Field>();
        Integer[] keys = fields.keySet().toArray(new Integer[0]);
        Arrays.sort(keys);

        for (Integer key : keys)
        {
            result.add(fields.get(key));
        }

        return result;
    }

    /**
     * Get the execution mode supported by this tool.
     *
     * @return the ToolMode of this tool
     */
    public ToolMode getMode()
    {
        return ToolMode.valueOf(properties.getProperty("mode.supported").toUpperCase());
    }

    /**
     * Determine whether this tool is enabled or disabled.  A disabled tool will not
     * appear in the tools menu.
     *
     * @return true if the tool is enabled, false otherwise
     */
    public boolean isEnabled()
    {
        return !"false".equalsIgnoreCase(properties.getProperty("script.enabled"));
    }

    /**
     * Get the output format provided by the plugin.
     *
     * @return the plugin format
     */
    public String getOutputFormat()
    {
        return properties.getProperty("detail.format", "grid(text)"); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Get an arbitrary property.  This should normally be avoided in favor of
     * calling one of the specific property accessors.  Specific accessors
     * should be added when needed rather than just using this because it's
     * convenient.
     *
     * @param name the name of the property to get
     * @return the value of the property, or <code>null</code> if it does not exist
     */
    public String getProperty(String name)
    {
        return properties.getProperty(name);
    }

    //-----------------------------------------------------------------------
    //                     P R I V A T E   M E T H O D S
    //-----------------------------------------------------------------------

    private void parse()
    {
        Set<?> keys = properties.keySet();
        for (Iterator<?> iter = keys.iterator(); iter.hasNext();)
        {
            String key = (String) iter.next();
            if (key.startsWith("input"))
            {
                parseInput(key);
            }
        }
    }

    /**
     * @param key
     */
    private void parseInput(String key)
    {
        Matcher matcher = INPUT_PATTERN.matcher(key);
        if (matcher.matches())
        {
            try
            {
                String fieldStr = matcher.group(1);
                String additional = matcher.group(2);

                int c = parseInt(fieldStr);
                Field field = fields.get(c);
                if (field == null)
                {
                    field = new Field();
                    fields.put(c, field);
                }

                String value = properties.getProperty(key);
                if ("".equals(additional))
                {
                    field.setName(value);
                }
                else if ("label".equals(additional))
                {
                    field.setLabel(value);
                }
                else if ("type".equals(additional))
                {
                    field.setType(value);
                }
                else if ("default".equals(additional))
                {
                    field.setDefaultValue(value);
                }
            }
            catch (Exception e)
            {
                e.printStackTrace();
            }
        }
    }

    //-----------------------------------------------------------------------
    //                       I N N E R   C L A S S E S
    //-----------------------------------------------------------------------

    /**
     * ToolMode
     */
    public static enum ToolMode
    {
        SINGLE,
        MULTI,
        COMBINED
    }

    /**
     * Field
     */
    public static class Field
    {
        private String name;
        private String label;
        private String type;
        private String defaultValue;

        /**
         * Get the default value for this field, if it exists.
         *
         * @return the default value
         */
        public String getDefaultValue()
        {
            return defaultValue;
        }

        /**
         * Set the default value for this field.
         *
         * @param defaultValue the default value
         */
        public void setDefaultValue(String defaultValue)
        {
            this.defaultValue = defaultValue;
        }

        /**
         * Get the display label of this field.
         *
         * @return the display label
         */
        public String getLabel()
        {
            return label;
        }

        /**
         * Set the display label of this field.
         *
         * @param label the display label
         */
        public void setLabel(String label)
        {
            this.label = label;
        }

        /**
         * Get the variable name of this field.
         *
         * @return the name
         */
        public String getName()
        {
            return name;
        }

        /**
         * Set the variable name of this field.
         *
         * @param name the name
         */
        public void setName(String name)
        {
            this.name = name;
        }

        /**
         * Get the data type of this field.  Types are extensible and
         * can be added by Extention Point, an extensible type registers
         * its data type name.  This field refers to that name.
         *
         * @return the type
         */
        public String getType()
        {
            return type;
        }

        /**
         * Set the data type of this field.
         *
         * @param type the type
         */
        public void setType(String type)
        {
            this.type = type;
        }
    }
}
