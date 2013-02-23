package org.ziptie.nio.common.tuple;

public abstract class Quintuple<A, B, C, D, E> extends Quadruple<A, B, C, D>
{

    // -- fields
    protected final E e;

    // -- constructors
    protected Quintuple(final A a, final B b, final C c, final D d, final E e)
    {
        super(a, b, c, d);
        this.e = e;
        fields.add(e);
    }
}
