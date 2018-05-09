/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.generators.readgenerator;

import std.string : format;
import std.traits : hasUDA, FieldNameTuple;

import diamond.core.traits;
import diamond.data.mapping.engines.mysql.model : IMySqlModel;

package(diamond.data):
/**
* Generates the read function for a database model.
* Returns:
*   The read function string to use with mixin.
*/
string generateRead(T : IMySqlModel)()
{
  string s = q{
    {
      %s
    }
  };

  mixin HandleFields!(T, q{{
    enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
    enum hasRelationship = hasUDA!({{fullName}}, DbRelationship);

    static if (!hasNoMap && !hasRelationship)
    {
      import std.traits : getUDAs;

      enum hasNull = hasUDA!({{fullName}}, DbNull);
      enum hasEnum = hasUDA!({{fullName}}, DbEnum);
      enum hasProxy = hasUDA!({{fullName}}, DbProxy);

      enum typeName = typeof({{fullName}}).stringof;

      static if (hasNull && hasEnum)
      {
        mixin(readNullEnumFormat.format("{{fieldName}}", typeName));
      }
      else static if (hasNull && hasProxy)
      {
        mixin("enum proxy = getUDAs!(%s, DbProxy)[0];".format("{{fullName}}"));

        mixin(readNullProxyFormat.format("{{fieldName}}"));
      }
      else static if (hasNull)
      {
        mixin(readNullFormat.format("{{fieldName}}", typeName));
      }
      else static if (hasEnum)
      {
        mixin(readEnumFormat.format("{{fieldName}}", typeName));
      }
      else static if (hasProxy)
      {
        mixin("enum proxy = getUDAs!(%s, DbProxy)[0];".format("{{fullName}}"));

        mixin(readProxyFormat.format("{{fieldName}}"));
      }
      else static if (is(typeof({{fullName}}) == bool))
      {
        mixin(readBoolFormat.format("{{fieldName}}", typeName));
      }
      else
      {
        mixin(readFormat.format("{{fieldName}}", typeName));
      }
    }
  }});

  return s.format(handleThem());
}

/**
* Generates the read relationship function for a database model.
* Returns:
*   The read relationship function string to use with mixin.
*/
string generateReadRelationship(T : IMySqlModel)()
{
  string s = q{
    {
      %s
    }
  };

  mixin HandleFields!(T, q{{
    enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);

    static if (!hasNoMap)
    {
      import std.string : indexOf;
      import std.traits : getUDAs;

      enum hasRelationship = hasUDA!({{fullName}}, DbRelationship);

      enum typeName = typeof({{fullName}}).stringof;

      static if (hasRelationship)
      {
        enum shortTypeName = typeof({{fullName}}).stringof[0 .. typeof({{fullName}}).stringof.indexOf('[')];

        mixin("enum relationship = getUDAs!(%s, DbRelationship)[0];".format("{{fullName}}"));

        mixin(readRelationshipFormat.format("{{fieldName}}", typeName, shortTypeName));
      }
    }
  }});

  return s.format(handleThem());
}
