/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.model;

import std.traits : hasUDA;
import std.string : format;
import std.datetime : Date, DateTime, Clock, SysTime;

import vibe.data.serialization : ignore;

import diamond.data.mapping.model;
import diamond.data.mapping.attributes;
import diamond.data.mapping.engines.mysql.generators;
import diamond.database : getParams, MySql;

/// Base-interface for a mysql model.
interface IMySqlModel { }

/**
* Converts a SysTime to a DateTime.
*  Params:
*    sysTime = The SysTime to convert.
*  Returns:
*    The converted DateTime.
*/
private DateTime asDateTime(SysTime sysTime)
{
  return DateTime(sysTime.year, sysTime.month, sysTime.day, sysTime.hour, sysTime.minute, sysTime.second);
}

/**
* Creates a new mysql model.
*  Params:
*    tableName = The name of the table the model is associated with.
*/
class MySqlModel(string tableName) : Model, IMySqlModel
{
  import mysql.result : Row;

  private
  {
    /// The row.
    Row _row;
    /// The index.
    size_t _index;

    /**
    * Retrieves a value from the row.
    *  Params:
    *    T =        The type.
    *    nullable = Boolean determining whether the value is nullable or not.
    *    isEnum =    Boolean determining whether the value is an enum or not.
    *    column =    The column index of the value.
    *  Returns:
    *    The value.
    */
    final T retrieve(T, bool nullable = false, bool isEnum = false)(size_t column) @system
    {
      import std.traits : OriginalType;

      static if (nullable && isEnum)
      {
        return cast(T)(_row.isNull(column) ? T.init : _row[column].get!(OriginalType!T));
      }
      else static if (isEnum)
      {
        return cast(T)(_row[column].get!(OriginalType!T));
      }
      else static if (nullable)
      {
        return _row.isNull(column) ? T.init : _row[column].get!T;
      }
      else static if (is(T == bool))
      {
        return cast(bool)_row[column].get!ubyte;
      }
      else
      {
        return _row[column].get!T;
      }
    }

    /**
    * Retrieves a value from the row.
    *  Params:
    *    T =        The type.
    *    nullable = Boolean determining whether the value is nullable or not.
    *    isEnum =    Boolean determining whether the value is an enum or not.
    *  Returns:
    *    The value.
    */
    final T retrieve(T, bool nullable = false, bool isEnum = false)() @system
    {
      auto value = retrieve!(T, nullable, isEnum)(_index);
      _index++;
      return value;
    }
  }

  public:
  final:
  /// The table name.
  @ignore static const string table = tableName;

  /// Creates a new database model.
  this(this TModel)()
  {
    auto model = cast(TModel)this;

    enum readNullEnumFomat = "model.%s = retrieve!(%s, true, true);";
    enum readNullFomat = "model.%s = retrieve!(%s, true, false);";
    enum readEnumFomat = "model.%s = retrieve!(%s, false, true);";
    enum readBoolFormat = "model.%s = retrieve!(%s);";
    enum readFomat = "model.%s = retrieve!(%s);";

    import models;
    mixin
    (
      "super(%s, %s, %s, %s);".format
      (
        generateRead!TModel, generateInsert!TModel,
        generateUpdate!TModel, generateDelete!TModel
      )
    );
  }

  @property
  {
    /// Gets the raw row.
    @ignore Row row() @system { return _row; }

    /// Sets the native row. Settings this manually outside the engine is undefined-behavior.
    @ignore void row(Row newRow)  @system
    {
      _row = newRow;
    }
  }
}
