/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mssql.mssqlmodel;

import diamond.core.apptype;

static if (hasMsSql)
{
  import std.variant : Variant;
  import std.traits : hasUDA, isSomeString, OriginalType;
  import std.string : format;

  import vibe.data.serialization : ignore;

  import diamond.data.mapping.engines.mssql.mssqladapter;
  import diamond.data.mapping.engines.mssql.mssqlentityformatter;
  import diamond.data.mapping.engines.mssql : dbConnectionString;
  import diamond.data.mapping.attributes;

  import diamond.database;

  /// Interface for a mssql model.
  interface IMsSqlModel { }

  import diamond.data.mapping.model;
  /**
  * Creates a new mssql model.
  *  Params:
  *    tableName = The name of the table the model is associated with.
  */
  class MsSqlModel(string tableName) : Model, IMsSqlModel
  {
    import models;
    import ddbc;

    private:
    /// The row.
    ResultSet _row;
    /// The index.
    size_t _index;

    public:
    /// The name of the table associated with the mssql model.
    @ignore static const string table = tableName;

    final
    {
      /// Creates a new mssql model.
      this(this TModel)()
      {
        super();

        auto adapter = getMsSqlAdapter!TModel;

        static const formatter = new MsSqlEntityFormatter!TModel;

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
        alias Column = Variant;

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
        /// Gets the raw mssql row.
        @ignore ResultSet row() @system { return _row; }

        /// Sets the raw mssql row.
        @ignore void row(ResultSet newRow)  @system
        {
          _row = newRow;
        }
      }
    }

    protected:
    /// Moves to the next column.
    void moveToNextColumn()
    {
      throw new Exception("Not implemented ...");
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
        value = retrieveTextImpl();
      }

      return value;
    }

    /// Retrieves an enum value.
    Variant retrieveEnumImpl()
    {
      Variant text = retrieveTextImpl();

      return text;
    }

    /// Retrieves a nullable value.
    Variant retrieveNullableImpl()
    {
      Variant value = void;

      if (_row.isNull(_index))
      {
        value = Variant.init;
      }
      else
      {
        value = retrieveDefaultImpl();
      }

      return value;
    }

    /// Retrieves a boolean value.
    bool retrieveBoolImpl()
    {
      return _row.getBoolean(_index);
    }

    /// Retrieves a text value.
    string retrieveTextImpl()
    {
      return _row.getString(_index);
    }

    /// Retrieves any kind of value.
    Variant retrieveDefaultImpl()
    {
      return _row.getVariant(_index);
    }
  }
}
