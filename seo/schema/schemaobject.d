/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.schemaobject;

import diamond.core.apptype;

static if (isWeb)
{
  import std.variant;

  /// Wrapper around a schema object.
  abstract class SchemaObject
  {
    private:
    /// The type of the schema object.
    string _type;
    /// Boolean determining whether the object is a child or not.
    package(diamond) bool _isChild;
    /// ALl fields attached to the schema object.
    Variant[string] _fields;

    public:
    final:
    /**
    * Creates a new schema object.
    * Params:
    *   type = The type of the schema object. Equivalent to "@type"
    */
    this(string type)
    {
      _type = type;
    }

    @property
    {
      /// Gets a boolean determining whether the schema object is a root object or not.
      bool isRoot() { return !_isChild; }
    }

    /**
    * Adds a schema object field to the schema object.
    * Params:
    *   key =          The key of the field.
    *   schemaObject = The schema object to add.
    */
    void addField(T : SchemaObject)(string key, T schemaObject)
    {
      auto schema = cast(SchemaObject)schemaObject;

      if (schema)
      {
        schema._isChild = true;
      }

      _fields[key] = schema;
    }

    /**
    * Adds an array of schema objects to the schema object.
    * Params:
    *   key =    The key of the field.
    *   values = An array of schema objects to add.
    */
    void addField(T : SchemaObject)(string key, T[] values)
    {
      SchemaObject[] arrayResult;

      if (values)
      {
        foreach (child; values)
        {
          child._isChild = true;

          arrayResult ~= child;
        }

        _fields[key] = arrayResult ? arrayResult : [];
      }
      else
      {
        _fields[key] = arrayResult;
      }
    }

    /**
    * Adds a field to the schema object.
    * Params:
    *   key =   The key of the field.
    *   value = The value of the field.
    */
    void addField(T)(string key, T value)
    {
      _fields[key] = value;
    }

    /**
    * Removes a field from the schema object.
    * Params:
    *   key = The key of the field to remove.
    */
    void removeField(string key)
    {
      _fields.remove(key);
    }

    /// Converts the schema object to a string that represent a JSON-LD object.
    override string toString()
    {
      import std.string : format;
      import std.conv : to;
      import std.array : join;

      string[] fieldsValue;

      if (_fields && _fields.length)
      {
        foreach (k,v; _fields)
        {
          if (!v.hasValue)
          {
            continue;
          }

          if (v.convertsTo!SchemaObject)
          {
            auto schemaObject = v.get!SchemaObject;

            fieldsValue ~= "\"%s\": %s".format(k,schemaObject.toString());
          }
          else if (v.convertsTo!(SchemaObject[]))
          {
            auto schemaObjects = v.get!(SchemaObject[]);

            if (schemaObjects)
            {
              fieldsValue ~= "\"%s\": %s".format(k,to!string(schemaObjects));
            }
            else
            {
              fieldsValue ~= "\"%s\": null".format(k);
            }
          }
          else if (v.convertsTo!string)
          {
            auto stringValue = v.get!string;

            fieldsValue ~= "\"%s\": \"%s\"".format(k,stringValue);
          }
          else
          {
            fieldsValue ~= "\"%s\": %s".format(k,v.toString());
          }
        }
      }

      if (!_isChild)
      {
        return `{
    "@context" : "http://schema.org",
    "@type": "%s"
    %s
  }`.format
        (
          _type,
          fieldsValue && fieldsValue.length ? (", " ~ fieldsValue.join(",\r\n")) : ""
        );
      }
      else
      {
        return `{
    "@type": "%s"
    %s
    }`.format
        (
          _type,
          fieldsValue && fieldsValue.length ? (", " ~ fieldsValue.join(",\r\n")) : ""
        );
      }
    }
  }
}
