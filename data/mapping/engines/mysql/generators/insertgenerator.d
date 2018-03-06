/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.generators.insertgenerator;

import std.string : format;
import std.traits : hasUDA, FieldNameTuple;
import std.algorithm : map;
import std.array : join, array;

import diamond.core.traits;
import diamond.data.mapping.attributes;
import diamond.data.mapping.engines.mysql.model : IMySqlModel;

package(diamond.data):
/**
* Generates the insert function for a database model.
* Returns:
*   The insert function string to use with mixin.
*/
string generateInsert(T : IMySqlModel)()
{
  import models;

  string s = q{
    {
      static const sql = "INSERT INTO `%s` (%s) VALUES (%s)";
      auto params = getParams(%s);

      size_t index;

      %s

      %s
    }
  };

  string[] columns;
  string[] paramsInserts;
  string idName;
  string idType;
  string execution;

  {
    mixin HandleFields!(T, q{{
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (hasId)
      {
        idName = "{{fieldName}}";
        idType = typeof({{fullName}}).stringof;
      }
    }});
    mixin(handleThem());

    if (idName)
    {
      execution = "model.%s = MySql.scalarInsertRaw!%s(sql, params);".format(idName, idType);
    }
    else
    {
      execution = "MySql.executeRaw(sql, params);";
    }
  }

  {
    mixin HandleFields!(T, q{{
      enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (!hasNoMap && !hasId)
      {
        columns ~= "`{{fieldName}}`";
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
      enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (!hasNoMap && !hasId)
      {
        enum hasEnum = hasUDA!({{fullName}}, DbEnum);
        enum hasTimestamp = hasUDA!({{fullName}}, DbTimestamp);

        static if (hasEnum)
        {
          paramsInserts ~= "params[index++] = cast(string)model.{{fieldName}};";
        }
        else static if (hasTimestamp)
        {
          paramsInserts ~= `
           model.timestamp = Clock.currTime().asDateTime();
           params[index++] = model.timestamp;
          `;
        }
        else static if (is(typeof({{fullName}}) == bool))
        {
          paramsInserts ~= "params[index++] = cast(ubyte)model.{{fieldName}};";
        }
        else
        {
          paramsInserts ~= "params[index++] = model.{{fieldName}};";
        }
      }
    }});
    mixin(handleThem());
  }

  if (!paramsInserts || !paramsInserts.length)
  {
    return "";
  }

  return s.format(T.table, columns.join(","), columns.map!(c => "?").array.join(","), columns.length, paramsInserts.join("\r\n"), execution);
}
