/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.mysqlmodel;

import std.variant : Variant;
import std.traits : hasUDA, isSomeString, OriginalType;
import std.string : format;

import vibe.data.serialization : ignore;

import diamond.data.mapping.engines.mysql.mysqladapter;
import diamond.data.mapping.engines.mysql.mysqlentityformatter;
import diamond.data.mapping.engines.mysql : dbConnectionString;
import diamond.data.mapping.engines.sqlshared.sqlmodel;
import diamond.data.mapping.attributes;

import diamond.database;

/// Interface for a mysql model.
interface IMySqlModel { }

import diamond.data.mapping.model;
/**
* Creates a new mysql model.
*  Params:
*    tableName = The name of the table the model is associated with.
*/
class MySqlModel(string tableName) : Model, IModel // SqlModel!tableName, IMySqlModel
{
  import models;
  import mysql;

  private:
  /// The row.
  Row _row;
  /// The index.
  size_t _index;

  public:
  /// The name of the table associated with the mysql model.
  @ignore static const string table = tableName;

  final
  {
    /// Creates a new mysql model.
    this(this TModel)()
    {
      super();

      auto adapter = getMySqlAdapter!TModel;

      static const formatter = new MySqlEntityFormatter!TModel;

      auto model = cast(TModel)this;

      mixin("setReader(" ~ formatter.generateRead() ~ ");");
      mixin("setInserter(" ~ formatter.generateInsert() ~ ");");
      mixin("setUpdater(" ~ formatter.generateUpdate() ~ ");");
      mixin("setDeleter(" ~ formatter.generateDelete() ~ ");");
      mixin("setReaderRelationship(" ~ formatter.generateReadRelationship() ~ ");");
    }

    /**
    * Retrieves a value from the model's data.
    * Returns:
    *   The value.
    */
    T retrieve(T, bool nullable = false, bool isEnum = false)()
    {
      Column value = Column.init;

      static if (nullable && isEnum)
      {
        value = retrieveNullableEnumImpl();

        if (!value.hasValue)
        {
          value = T.init;
        }
        else
        {
          value = cast(T)value.get!(OriginalType!T);
        }
      }
      else static if (isEnum)
      {
        value = cast(T)retrieveEnumImpl().get!(OriginalType!T);
      }
      else static if (nullable)
      {
        value = retrieveNullableImpl();

        if (!value.hasValue)
        {
          value = T.init;
        }
      }
      else static if (is(T == bool))
      {
        value = retrieveBoolImpl();
      }
      else static if (isSomeString!T)
      {
        value = retrieveTextImpl();
      }
      else
      {
        value = retrieveDefaultImpl();
      }

      moveToNextColumn();

      if (!value.hasValue)
      {
        return T.init;
      }

      return value.get!T;
    }

    @property
    {
      /// Gets the raw mysql row.
      @ignore Row row() @system { return _row; }

      /// Sets the raw mysql row.
      @ignore void row(Row newRow)  @system
      {
        _row = newRow;
      }
    }
  }

  protected:
  /// Moves to the next column.
  void moveToNextColumn()
  {
    _index++;
  }

  /// Retrieves a nullable enum value.
  Variant retrieveNullableEnumImpl()
  {
    Variant value = void;

    if (_row.isNull(_index))
    {
      value = Variant.init;
    }
    else
    {
      value = _row[_index];
    }

    return value;
  }

  /// Retrieves an enum value.
  Variant retrieveEnumImpl()
  {
    return _row[_index];
  }

  /// Retrieves a nullable value.
  Variant retrieveNullableImpl()
  {
    return retrieveNullableEnumImpl();
  }

  /// Retrieves a boolean value.
  bool retrieveBoolImpl()
  {
    return cast(bool)_row[_index].get!ubyte;
  }

  /// Retrieves a text value.
  string retrieveTextImpl()
  {
    return retrieveDefaultImpl().get!string;
  }

  /// Retrieves any kind of value.
  Variant retrieveDefaultImpl()
  {
    return _row[_index];
  }
}
