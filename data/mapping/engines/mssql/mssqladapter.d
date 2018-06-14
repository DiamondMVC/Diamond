/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mssql.mssqladapter;

import diamond.core.apptype;

static if (hasMsSql)
{
  import std.variant : Variant;
  import std.algorithm : map;
  import std.array : array;

  import ddbc;

  import diamond.data.mapping.engines.sqlshared;
  import diamond.data.mapping.engines.mssql.mssqlmodel;
  import diamond.database : DbParam;
  import diamond.data.mapping.engines.mssql;

  /// CTFE string for mixin MsSql connection setup with specialized parameters.
  private enum MsSqlConnectionNamedParametersSetup = q{
    auto useDbConnectionString = connectionString ? connectionString : super.connectionString;

    string newSql;
    DbParam[] newParams = null;
    if (params)
    {
      newParams = prepareSql(query, params, newSql);
    }
    else
    {
      newSql = query;
    }

    Connection connection = createConnection(useDbConnectionString);

    scope (exit) connection.close();

    PreparedStatement statement = connection.prepareStatement(query);

    scope (exit) statement.close();

    if (newParams)
    {
      foreach (i; 0 .. newParams.length)
      {
        statement.setVariant(i, newParams[i]);
      }
    }
  };

  /// CTFE string for mixin MsSql connection setup.
  private enum MsSqlConnectionSetup = q{
    auto useDbConnectionString = connectionString ? connectionString : super.connectionString;

    Connection connection = createConnection(useDbConnectionString);

    scope (exit) connection.close();

    PreparedStatement statement = connection.prepareStatement(query);

    scope (exit) statement.close();

    if (params)
    {
      foreach (i; 0 .. params.length)
      {
        statement.setVariant(i, params[i]);
      }
    }
  };

  /// Gets a mssql adapter based on a model.
  MsSqlAdapter!TModel getMsSqlAdapter(TModel)(string connectionString = null)
  {
    return new MsSqlAdapter!TModel(connectionString);
  }

  // Wrapper for an empty mssql model.
  private class EmptyMsSqlModel
  {
    import vibe.data.serialization : ignore;

    @ignore static const string table = "";

    ResultSet row;
    void readModel() { }
  }

  /// Wrapper around a raw mssql adapter.
  final class MsSqlRawAdapter : MsSqlAdapter!EmptyMsSqlModel
  {
    public:
    /**
    * Creates a new mssql raw adapter.
    * Params:
    *   connectionString = The connection string of the adapter.
    */
    this(string connectionString = null)
    {
      super(connectionString);
    }
  }

  /// Wrapper around a mssql adapter.
  class MsSqlAdapter(TModel) : SqlAdapter!TModel
  {
    public:
    final:
    /**
    * Creates a new mssql adapter.
    * Params:
    *   connectionString = The connection string of the adapter.
    */
    this(string connectionString = null)
    {
      super(connectionString ? connectionString : dbConnectionString);
    }

    /**
    *  Executes an sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The amount of rows affected.
    */
    override ulong execute(string query, DbParam[string] params, string connectionString = null)
    {
      mixin(MsSqlConnectionNamedParametersSetup);

      return cast(ulong)statement.executeUpdate();
    }

    /**
    *  Executes a raw sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The amount of rows affected.
    */
    override ulong executeRaw(string query, DbParam[] params, string connectionString = null)
    {
      mixin(MsSqlConnectionSetup);

      return cast(ulong)statement.executeUpdate();
    }

    /**
    *  Validates whether a row is selected from the query or not.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    True if the row exists, false otherwise.
    */
    override bool exists(string query, DbParam[string] params, string connectionString = null)
    {
      auto rows = execute(query, params, connectionString);

      return cast(bool)rows;
    }

    /**
    *  Validates whether a row is selected from the raw query or not.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    True if the row exists, false otherwise.
    */
    override bool existsRaw(string query, DbParam[] params, string connectionString = null)
    {
      auto rows = executeRaw(query, params, connectionString);

      return cast(bool)rows;
    }

    /**
    *  Executes a multi sql read.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    A range filled models with the rows returned by the sql read.
    */
    override TModel[] readMany(string query, DbParam[string] params, string connectionString = null)
    {
      TModel[] models;

      params["table"] = TModel.table;

      mixin(MsSqlConnectionNamedParametersSetup);

      auto result = statement.executeQuery();

      while (result.next())
      {
        auto model = new TModel;
        model.row = result;
        model.readModel();

        models ~= model;
      }

      return models;
    }

    /**
    *  Executes a raw multi sql read.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    A range filled models with the rows returned by the sql read.
    */
    override TModel[] readManyRaw(string query, DbParam[] params, string connectionString = null)
    {
      TModel[] models;

      mixin(MsSqlConnectionSetup);

      auto result = statement.executeQuery();

      while (result.next())
      {
        auto model = new TModel;
        model.row = result;
        model.readModel();

        models ~= model;
      }

      return models;
    }

    /**
    *  Executes a single sql read.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The model of the first row read.
    */
    override TModel readSingle(string query, DbParam[string] params, string connectionString = null)
    {
      params["table"] = TModel.table;

      mixin(MsSqlConnectionNamedParametersSetup);

      auto result = statement.executeQuery();

      auto model = TModel.init;

      if (result.next())
      {
        model = new TModel;
        model.row = result;
        model.readModel();
      }

      return model;
    }

    /**
    *  Executes a single raw sql read.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The model of the first row read.
    */
    override TModel readSingleRaw(string query, DbParam[] params, string connectionString = null)
    {
      mixin(MsSqlConnectionSetup);

      auto result = statement.executeQuery();

      auto model = TModel.init;

      if (result.next())
      {
        model = new TModel;
        model.row = result;
        model.readModel();
      }

      return model;
    }

    protected:
    /**
    *  Executes a scalar sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The value of the statement.
    */
    override Variant scalarImpl(string query, DbParam[string] params, string connectionString = null)
    {
      mixin(MsSqlConnectionNamedParametersSetup);

      throw new Exception("Not implemented ...");
    }

    /**
    *  Executes a raw scalar sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The value of the statement.
    */
    override Variant scalarRawImpl(string query, DbParam[] params, string connectionString = null)
    {
      mixin(MsSqlConnectionSetup);

      throw new Exception("Not implemented ...");
    }

    /**
    *  Executes a scalar insert sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The id of inserted row.
    */
    override Variant scalarInsertImpl(string query, DbParam[string] params, string connectionString = null)
    {
      mixin(MsSqlConnectionNamedParametersSetup);

      Variant id;

      auto success = cast(bool)statement.executeUpdate(id);

      return success ? id : Variant.init;
    }

    /**
    *  Executes a raw scalar insert sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The id of the inserted row.
    */
    override Variant scalarInsertRawImpl(string query, DbParam[] params, string connectionString = null)
    {
      mixin(MsSqlConnectionSetup);

      Variant id;

      auto success = cast(bool)statement.executeUpdate(id);

      return success ? id : Variant.init;
    }
  }
}
