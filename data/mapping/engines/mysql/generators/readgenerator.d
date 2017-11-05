/**
* Copyright © DiamondMVC 2016-2017
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

    static if (!hasNoMap)
    {
      enum hasNull = hasUDA!({{fullName}}, DbNull);
      enum hasEnum = hasUDA!({{fullName}}, DbEnum);
      enum typeName = typeof({{fullName}}).stringof;

      static if (hasNull && hasEnum)
      {
        mixin(readNullEnumFomat.format("{{fieldName}}", typeName));
      }
      else static if (hasNull)
      {
        mixin(readNullFomat.format("{{fieldName}}", typeName));
      }
      else static if (hasEnum)
      {
        mixin(readEnumFomat.format("{{fieldName}}", typeName));
      }
      else static if (is(typeof({{fullName}}) == bool))
      {
        mixin(readBoolFormat.format("{{fieldName}}", typeName));
      }
      else
      {
        mixin(readFomat.format("{{fieldName}}", typeName));
      }
    }
  }});

  return s.format(handleThem());
}
