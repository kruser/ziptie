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
package org.ziptie.common;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

/**
 * StringUtils
 */
public final class StringElf
{

    /**
     * Private constructor since this only contains static methods
     */
    private StringElf()
    {
        //no-op
    }

    /**
     * Reads an InputStream into a String
     * @param inputStream the stream to read
     * @return the String
     */
    public static String inputStreamToString(InputStream inputStream)
    {
        try
        {
            Reader reader = new InputStreamReader(inputStream);
            Reader bufferedReader = new BufferedReader(reader);
            char[] buf = new char[1024];
            int charsRead = 0;
            StringBuffer result = new StringBuffer();
            while (-1 != (charsRead = bufferedReader.read(buf)))
            {
                result.append(buf, 0, charsRead);
            }
            bufferedReader.close();
            return result.toString();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * Given a file name, this method will create a .tmp file in the system
     * defined temp folder. This file will be set to be deleted when the JVM
     * exits, although it is a good idea to do your own cleanup.
     *
     * @param filename the file
     * @param strSource the source text
     * @return the resulting file
     * @throws IOException if there is an error creating the temp file
     */
    public static File stringToTempFile(String filename, String strSource) throws IOException
    {
        // Create a temp file in the servers temp directory
        File tmpFile = File.createTempFile(filename, null);

        // Have the JVM clean up the file on exit if it still exists
        tmpFile.deleteOnExit();

        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(tmpFile));
        bufferedWriter.write(strSource);
        bufferedWriter.flush();
        bufferedWriter.close();

        return tmpFile;
    }

}
