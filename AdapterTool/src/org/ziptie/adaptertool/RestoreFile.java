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
package org.ziptie.adaptertool;

import java.io.File;

/**
 * details of a file to be restored to a remote device
 * RestoreFile
 * @author rkruse
 */
public class RestoreFile
{
    private String base64EncodedFileBlob;
    private String fullPathOnDevice;
    private File originalFile;

    /**
     * @return the originalFile
     */
    public File getOriginalFile()
    {
        return originalFile;
    }

    /**
     * @param originalFile the originalFile to set
     */
    public void setOriginalFile(File originalFile)
    {
        this.originalFile = originalFile;
    }

    /**
     * @return the base64EncodedFileBlob
     */
    public String getBase64EncodedFileBlob()
    {
        return base64EncodedFileBlob;
    }

    /**
     * @param base64EncodedFileBlob the base64EncodedFileBlob to set
     */
    public void setBase64EncodedFileBlob(String base64EncodedFileBlob)
    {
        this.base64EncodedFileBlob = base64EncodedFileBlob;
    }

    /**
     * @return the fullPathOnDevice
     */
    public String getFullPathOnDevice()
    {
        return fullPathOnDevice;
    }

    /**
     * @param fullPathOnDevice the fullPathOnDevice to set
     */
    public void setFullPathOnDevice(String fullPathOnDevice)
    {
        this.fullPathOnDevice = fullPathOnDevice;
    }

}
