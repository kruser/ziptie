package org.ziptie.build;

import org.xml.sax.ErrorHandler;

import com.sun.codemodel.JDefinedClass;
import com.sun.codemodel.JMethod;
import com.sun.codemodel.JMod;
import com.sun.tools.xjc.Options;
import com.sun.tools.xjc.Plugin;
import com.sun.tools.xjc.outline.ClassOutline;
import com.sun.tools.xjc.outline.Outline;

public class XjcEqualsHashcodePlugin extends Plugin
{
    public XjcEqualsHashcodePlugin()
    {
    }

    @Override
    public String getOptionName()
    {
        return "Xequalshashcode";
    }

    @Override
    public String getUsage()
    {
        return "   -Xequalshashcode       : enable generation of equals() and hashCode() methods";
    }

    @Override
    public boolean run(Outline outline, Options options, ErrorHandler errorHandler)
    {
        for (ClassOutline classOutline: outline.getClasses())
        {
            JDefinedClass implClass = classOutline.implClass;
            
            JMethod equals = implClass.method(JMod.PUBLIC, Boolean.TYPE, "equals");
            equals.param(Object.class, "object");
            equals.javadoc().add("Override default equals().");
            equals.annotate(Override.class);
            equals.body().directStatement("   return EqualsFactory.equals(this, object);");

            JMethod hashCode = implClass.method(JMod.PUBLIC, Integer.TYPE, "hashCode");
            hashCode.javadoc().add("Override default hashCode().");
            hashCode.annotate(Override.class);
            hashCode.body().directStatement("   return EqualsFactory.hashCode(this);");

            JMethod toString = implClass.method(JMod.PUBLIC, String.class, "toString");
            toString.javadoc().add("Override default toString().");
            toString.annotate(Override.class);
            toString.body().directStatement("   return EqualsFactory.toString(this);");
        }

        return true;
    }
}
