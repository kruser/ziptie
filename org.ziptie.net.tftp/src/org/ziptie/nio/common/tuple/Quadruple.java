package org.ziptie.nio.common.tuple;

public abstract class Quadruple<A, B, C, D> extends Triple<A, B, C>
{

    // -- fields
    protected final D d;

    // -- constructors
    protected Quadruple(final A a, final B b, final C c, final D d)
    {
        super(a, b, c);
        this.d = d;
        fields.add(d);
    }

}
