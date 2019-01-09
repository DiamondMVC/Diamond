/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.mysqlentityformatter;

import std.string : format;
import std.traits : hasUDA, FieldNameTuple;
import std.algorithm : map;
import std.array : join, array;

import diamond.core.traits;
import diamond.data.mapping.attributes;
import diamond.data.mapping.engines.mysql.mysqlmodel : IMySqlModel;
import diamond.data.mapping.engines.sqlshared.sqlentityformatter;

package(diamond.data.mapping.engines.mysql)
{
  import diamond.database;

  /**
  * Converts a system time to a datetime.
  * Params:
  *   sysTime = The system time to convert.
  * Returns:
  *   The system time as a datetime.
  */
  DateTime asDateTime(SysTime sysTime)
  {
    return DateTime(sysTime.year, sysTime.month, sysTime.day, sysTime.hour, sysTime.minute, sysTime.second);
  }

  /// The format for nullable enums.
  enum readNullEnumFomat = "model.%s = retrieve!(%s, true, true);";

  /// The format for nullable proxies.
  enum readNullProxyFormat = q{
    import std.variant : Variant;
    mixin("model." ~ proxy.readHandler ~ "!(\"%s\")(_row.isNull(_index) ? Variant.init : _row[_index]);");
    _index++;
  };

  /// The format for nullables.
  enum readNullFormat = "model.%s = retrieve!(%s, true, false);";

  /// The format for enums.
  enum readEnumFormat = "model.%s = retrieve!(%s, false, true);";

  /// The format for proxies.
  enum readProxyFormat = q{
    mixin("model." ~ proxy.readHandler ~ "!(\"%s\")(_row[_index]);");
    _index++;
  };

  /// The format for reading relationships.
  enum readRelationshipFormat = q{
    if (relationship.sql)
    {
      model.%1$s = (getMySqlAdapter!%3$s).readMany(relationship.sql, null);
    }
    else if (relationship.members)
    {
      auto params = getParams();

      string[] whereClause = [];

      static foreach (memberLocal,memberRemote; relationship.members)
      {
        mixin("whereClause ~= \"`" ~ memberRemote ~ "` = @" ~ memberLocal ~ "\";");
        mixin("params[\"" ~ memberLocal ~ "\"] = model." ~ memberLocal ~ ";");
      }

      import std.array : join;

      model.%1$s = (getMySqlAdapter!%3$s).readMany("SELECT * FROM `@table` WHERE " ~ whereClause.join(" AND "), params);
    }
  };

  /// The format for booleans.
  enum readBoolFormat = "model.%s = retrieve!(%s);";

  /// The format for default reading.
  enum readFormat = "model.%s = retrieve!(%s);";
}

/// Wrapper around a mysql entity formatter.
final class MySqlEntityFormatter(TModel) : SqlEntityFormatter!TModel
{
  public:
  final:
  /// Creates a new mysql entity formatter.
  this()
  {

  }

  /// Generates the read mixin.
  override string generateRead() const
  {
    string s = q{
      {
        %s
      }
    };

    mixin HandleFields!(TModel, q{{
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

  /// Generates the insert mixin.
  override string generateInsert() const
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
      mixin HandleFields!(TModel, q{{
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
        execution = "model.%s = adapter.scalarInsertRaw!%s(sql, params);".format(idName, idType);
      }
      else
      {
        execution = "adapter.executeRaw(sql, params);";
      }
    }

    {
      mixin HandleFields!(TModel, q{{
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
      return "null";
    }

    {
      mixin HandleFields!(TModel, q{{
        enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
        enum hasId = hasUDA!({{fullName}}, DbId);

        static if (!hasNoMap && !hasId)
        {
          import std.traits : getUDAs;

          enum hasEnum = hasUDA!({{fullName}}, DbEnum);
          enum hasTimestamp = hasUDA!({{fullName}}, DbTimestamp);
          enum hasProxy = hasUDA!({{fullName}}, DbProxy);

          static if (hasEnum)
          {
            paramsInserts ~= "params[index++] = cast(string)model.{{fieldName}};";
          }
          else static if (hasProxy)
          {
            mixin("enum proxy = getUDAs!(%s, DbProxy)[0];".format("{{fullName}}"));

            paramsInserts ~= "params[index++] = model." ~ proxy.writeHandler  ~ "!(\"{{fieldName}}\")();";
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
      return "null";
    }

    return s.format(TModel.table, columns.join(","), columns.map!(c => "?").array.join(","), columns.length, paramsInserts.join("\r\n"), execution);
  }

  /// Generates the update mixin.
  override string generateUpdate() const
  {
    import models;

    string s = q{
      {
        static const sql = "UPDATE `%s` SET %s WHERE `%s` = ?";
        auto params = getParams(%s);

        size_t index;

        %s

        %s

        adapter.executeRaw(sql, params);
      }
    };

    string[] columns;
    string[] paramsUpdates;
    string idName;
    string idParams;

    {
      mixin HandleFields!(TModel, q{{
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
      return "null";
    }

    {
      mixin HandleFields!(TModel, q{{
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
        return "null";
      }
    }

    {
      mixin HandleFields!(TModel, q{{
        enum hasNoMap = hasUDA!({{fullName}}, DbNoMap);
        enum hasId = hasUDA!({{fullName}}, DbId);

        static if (!hasNoMap && !hasId)
        {
          import std.traits : getUDAs;
          
          enum hasEnum = hasUDA!({{fullName}}, DbEnum);
          enum hasTimestamp = hasUDA!({{fullName}}, DbTimestamp);
          enum hasProxy = hasUDA!({{fullName}}, DbProxy);

          static if (hasEnum)
          {
            paramsUpdates ~= "params[index++] = cast(string)model.{{fieldName}};";
          }
          else static if (hasProxy)
          {
            mixin("enum proxy = getUDAs!(%s, DbProxy)[0];".format("{{fullName}}"));

            paramsUpdates ~= "params[index++] = model." ~ proxy.writeHandler  ~ "!(\"{{fieldName}}\")();";
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
      return "null";
    }

    return s.format(TModel.table, columns.join(","), idName, (columns.length + 1), paramsUpdates.join("\r\n"), idParams);
  }

  /// Generates the delete mixin.
  override string generateDelete() const
  {
    import models;

    string s = q{
      {
        static const sql = "DELETE FROM `%s` WHERE `%s` = ?";
        auto params = getParams(1);

        %s

        adapter.executeRaw(sql, params);
      }
    };

    string idName;
    string idParams;

    {
      mixin HandleFields!(TModel, q{{
        enum hasId = hasUDA!({{fullName}}, DbId);

        static if (hasId)
        {
          idName = "{{fieldName}}";
          idParams = "params[0] = model.{{fieldName}};";
        }
      }});
      mixin(handleThem());

      if (!idName)
      {
        return "null";
      }
    }

    return s.format(TModel.table, idName, idParams);
  }

  /// Generates the read relationship mixin.
  override string generateReadRelationship() const
  {
    string s = q{
      {
        %s
      }
    };

    mixin HandleFields!(TModel, q{{
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
}
