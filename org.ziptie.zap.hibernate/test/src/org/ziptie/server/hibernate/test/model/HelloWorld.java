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
 */

package org.ziptie.server.hibernate.test.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.GenerationType;
import javax.persistence.GeneratedValue;
import java.io.Serializable;

/**
 * Class represents a Helloworld object
 */
@Entity
public class HelloWorld implements Serializable
{
    // Fields
    private Long id;
    private String name;

    // Constructors
    /**
     * Default constructor
     */
    public HelloWorld()
    {
    }

    /**
     * Full constructor
     * @param id Id of the object
     * @param name name of the object
     */
    public HelloWorld(Long id, String name)
    {
        this.id = id;
        this.name = name;
    }

    /**
     * Gets the Id of the object
     * @return Id of the object
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long getId()
    {
        return id;
    }

    /**
     * Sets the Id of the object
     * @param id Id of the object
     */
    public void setId(Long id)
    {
        this.id = id;
    }

    /**
     * Gets the Name of the object
     * @return Name of the object 
     */
    public String getName()
    {
        return name;
    }

    /**
     * Sets the Name of the object
     * @param name Name of the object
     */
    public void setName(String name)
    {
        this.name = name;
    }
}
