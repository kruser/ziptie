package org.ziptie.net.client;

/**
 * EqualsFactory
 */
public final class EqualsFactory
{
    /**
     * Check the equality of two objects.  Custom code can be performed here
     * to override equality for generated SOAP objects.
     *
     * @param obj1 the first object
     * @param obj2 the second object
     * @return <code>true</code> if they are equal, <code>false</code> if they are not
     */
    public static boolean equals(Object obj1, Object obj2)
    {
        return obj1 == obj2;
    }

    /**
     * Calculate the hash code of the provided object.  Custom code can be performed
     * here to override the hash code calculation for generated SOAP objects.
     *
     * @param obj the object to calculate the hash code for
     * @return the hash code of the object
     */
    public static int hashCode(Object obj)
    {
        return System.identityHashCode(obj);
    }

    /**
     * Returns a string representation of the object.
     *
     * @param obj The object to get the string for.
     * @return A string representation of this object.
     */
    public static String toString(Object obj)
    {
        return obj.getClass().getName() + "@" + Integer.toHexString(obj.hashCode()); //$NON-NLS-1$
    }    
}
