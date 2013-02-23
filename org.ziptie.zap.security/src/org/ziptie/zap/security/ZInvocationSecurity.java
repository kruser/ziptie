package org.ziptie.zap.security;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


/**
 * ZInvocationSecurity
 */
@Retention(value = RetentionPolicy.RUNTIME)
public @interface ZInvocationSecurity
{
    String UNSECURED = "unsecured"; //$NON-NLS-1$

    /**
     * Security permission
     */
    String perm() default UNSECURED;
}
