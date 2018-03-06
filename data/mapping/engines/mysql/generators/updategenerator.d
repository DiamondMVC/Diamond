/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.generators.updategenerator;

import std.string : format;
import std.traits : hasUDA, FieldNameTuple;
import std.algorithm : map;
import std.array : join, array;

import diamond.core.traits;
import diamond.data.mapping.attributes;
import diamond.data.mapping.engines.mysql.model : IMySqlModel;

package(diamond.data):
/**
* Generates the update function for a database model.
* Returns:
*   The update function string to use with mixin.
*/
string generateUpdate(T : IMySqlModel)()
{
  import models;

  string s = q{
    {
      static const sql = "UPDATE `%s` SET %s WHERE `%s` = ?";
      auto params = getParams(%s);

      size_t index;

      %s

      %s

      MySql.executeRaw(sql, params);
    }
  };

  string[] columns;
  string[] paramsUpdates;
  string idName;
  string idParams;

  {
    mixin HandleFields!(T, q{{
      enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (!hasNoMap && !hasId)
      {
        columns ~= "`{{fieldName}}` = ?";
      }
    }});
    mixin(handleThem());
  }

  if (!columns || !columns.length)
  {
    return "";
  }

  {
    mixin HandleFields!(T, q{{
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (hasId)
      {
        idName = "{{fieldName}}";
        idParams = "params[%s] = model.{{fieldName}};".format(columns.length);
      }
    }});
    mixin(handleThem());

    if (!idName)
    {
      return "";
    }
  }

  {
    mixin HandleFields!(T, q{{
      enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (!hasNoMap && !hasId)
      {
        enum hasEnum = hasUDA!({{fullName}}, DbEnum);
        enum hasTimestamp = hasUDA!({{fullName}}, DbTimestamp);

        static if (hasEnum)
        {
          paramsUpdates ~= "params[index++] = cast(string)model.{{fieldName}};";
        }
        else static if (hasTimestamp)
        {
          paramsUpdates ~= `
           model.timestamp = Clock.currTime().asDateTime();
           params[index++] = model.timestamp;
          `;
        }
        else static if (is(typeof({{fullName}}) == bool))
        {
          paramsUpdates ~= "params[index++] = cast(ubyte)model.{{fieldName}};";
        }
        else
        {
          paramsUpdates ~= "params[index++] = model.{{fieldName}};";
        }
      }
    }});
    mixin(handleThem());
  }

  if (!paramsUpdates || !paramsUpdates.length)
  {
    return "";
  }

  return s.format(T.table, columns.join(","), idName, (columns.length + 1), paramsUpdates.join("\r\n"), idParams);
}
