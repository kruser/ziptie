package org.ziptie.nio.common.tuple;

public abstract class Single<A> extends Tuple
{

    // -- fields
    protected final A a;

    // -- constructors
    protected Single(final A a)
    {
        this.a = a;
        fields.add(a);
    }

}
