/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.postgresql.generators.insertgenerator;

version (Diamond_PostgreSqlDev)
{
  import std.string : format;
  import std.traits : hasUDA, FieldNameTuple;
  import std.algorithm : map, cumulativeFold;
  import std.array : join, array;
  import std.conv : to;

  import diamond.core.traits;
  import diamond.data.mapping.attributes;
  import diamond.data.mapping.engines.postgresql.model : IPostgreSqlModel;

  package(diamond.data):
  /**
  * Generates the insert function for a database model.
  * Returns:
  *   The insert function string to use with mixin.
  */
  string generateInsert(T : IPostgreSqlModel)()
  {
    import models;

    string s = q{
      {
        static const sql = "INSERT INTO \"%s\" (%s) VALUES (%s)%s";
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
        execution = "model.%s = PostgreSql.scalar!%s(sql, params);".format(idName, idType);
      }
      else
      {
        execution = "PostgreSql.execute(sql, params);";
      }
    }

    {
      mixin HandleFields!(T, q{{
        enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
        enum hasId = hasUDA!({{fullName}}, DbId);

        static if (!hasNoMap && !hasId)
        {
          columns ~= "\"{{fieldName}}\"";
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
          enum hasTimestamp = hasUDA!({{fullName}}, DbTimestamp);

          static if (hasTimestamp)
          {
            paramsInserts ~= `
             model.timestamp = Clock.currTime().asDateTime();
             params[index++] = "%s-%s-%s %s:%s:%s".format
             (
               model.timestamp.year,model.timestamp.month,model.timestamp.day,
               model.timestamp.hour,model.timestamp.minute,model.timestamp.second
             );
            `;
          }
          else
          {
            paramsInserts ~= "params[index++] = to!string(model.{{fieldName}});";
          }
        }
      }});
      mixin(handleThem());
    }

    if (!paramsInserts || !paramsInserts.length)
    {
      return "";
    }

    auto preparedParams = columns.map!(a => 1)
          .cumulativeFold!((a,b) => 1 + a)
          .map!(a => "$" ~ to!string(a))
          .array
          .join(",");

    return s.format(T.table, columns.join(","), preparedParams, idName && idName.length ? " RETURNING " ~ idName : "", columns.length, paramsInserts.join("\r\n"), execution);
  }
}
