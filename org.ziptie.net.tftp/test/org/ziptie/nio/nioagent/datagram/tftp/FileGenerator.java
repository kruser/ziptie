package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.File;

import org.ziptie.nio.common.FileIn;
import org.ziptie.nio.common.FileOut;
import org.ziptie.nio.common.SystemLogger;


public class FileGenerator implements SystemLogger.Injector
{

    // -- member fields
    private byte[] testPattern;
    private int numPatternRepetitions;

    // -- constructors
    public FileGenerator(String dir, String filename, byte[] testPattern, int numPatternRepetitions)
    {
        this.testPattern = testPattern;
        this.numPatternRepetitions = numPatternRepetitions;
        generateFile(dir, filename);
        verifyFile(dir, filename, false);
    }

    // -- public methods    
    public void verifyFile(String dir, String filename, boolean delete)
    {
        FileIn fileIn = new FileIn(dir, filename, logger);
        byte[] verifyArray = new byte[testPattern.length];
        for (int i = 0; i < numPatternRepetitions; i++)
        {
            fileIn.read(verifyArray, 0, verifyArray.length);
            for (int j = 0; j < testPattern.length; j++)
            {
                if (testPattern[j] != verifyArray[j])
                {
                    throw new RuntimeException("byte not equal, expected " + (char) testPattern[j] + " but found " + (char) verifyArray[j] + " in " + dir + "/"
                            + filename + " (i=" + i + ", j=" + j + ")");
                }
            }
        }
        fileIn.close();
        if (delete)
        {
            new File(dir + File.separatorChar + filename).delete();
        }
    }

    public int fileSize()
    {
        return testPattern.length * numPatternRepetitions;
    }

    // -- private methods
    private void generateFile(String dir, String filename)
    {
        FileOut fileOut = new FileOut(dir, filename, logger);
        for (int i = 0; i < numPatternRepetitions; i++)
        {
            fileOut.write(testPattern, 0, testPattern.length);
        }
        fileOut.close();
    }

}
