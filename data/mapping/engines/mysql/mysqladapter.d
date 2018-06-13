/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.mysqladapter;

import std.variant : Variant;
import std.algorithm : map;
import std.array : array;

import mysql;

import diamond.data.mapping.engines.sqlshared;
import diamond.data.mapping.engines.mysql.mysqlmodel;
import diamond.database : DbParam;
import diamond.data.mapping.engines.mysql;

/// CTFE string for mixin MySql connection setup with specialized parameters.
private enum MySqlConnectionNamedParametersSetup = q{
  auto useDbConnectionString = connectionString ? connectionString : super.connectionString;

  // Prepare statement
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

  auto pool = getPool(useDbConnectionString);
  auto connection = pool.lockConnection();
  auto prepared = connection.prepare(newSql);

  prepared.setArgs(newParams ? newParams : new DbParam[0]);
};

/// CTFE string for mixin MySql connection setup.
private enum MySqlConnectionSetup = q{
  auto useDbConnectionString = connectionString ? connectionString : super.connectionString;

  auto pool = getPool(useDbConnectionString);
  auto connection = pool.lockConnection();
  auto prepared = connection.prepare(query);

  prepared.setArgs(params ? params : new DbParam[0]);
};

/// Gets a mysql adapter based on a model.
MySqlAdapter!TModel getMySqlAdapter(TModel)(string connectionString = null)
{
  return new MySqlAdapter!TModel(connectionString);
}

// Wrapper for an empty mysql model.
private class EmptyMySqlModel
{
  import vibe.data.serialization : ignore;
  import mysql;

  @ignore static const string table = "";

  Row row;
  void readModel() { }
}

/// Wrapper around a raw mysql adapter.
final class MySqlRawAdapter : MySqlAdapter!EmptyMySqlModel
{
  public:
  /**
  * Creates a new mysql raw adapter.
  * Params:
  *   connectionString = The connection string of the adapter.
  */
  this(string connectionString = null)
  {
    super(connectionString);
  }
}

/// Wrapper around a mysql adapter.
class MySqlAdapter(TModel) : SqlAdapter!TModel
{
  public:
  final:
  /**
  * Creates a new mysql adapter.
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
    mixin(MySqlConnectionNamedParametersSetup);

    return connection.exec(prepared);
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
    mixin(MySqlConnectionSetup);

    return connection.exec(prepared);
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
    params["table"] = TModel.table;

    mixin(MySqlConnectionNamedParametersSetup);

    return connection.query(prepared).map!((row)
    {
      auto model = new TModel;
      model.row = row;
      model.readModel();
      return model;
    }).array;
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
    mixin(MySqlConnectionSetup);

    return connection.query(prepared).map!((row)
    {
      auto model = new TModel;
      model.row = row;
      model.readModel();
      return model;
    }).array;
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

    mixin(MySqlConnectionNamedParametersSetup);

    auto row = connection.queryRow(prepared);

    if (row.isNull)
    {
      return TModel.init;
    }

    auto model = new TModel;
    model.row = row.get;
    model.readModel();
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
    mixin(MySqlConnectionSetup);

    auto row = connection.queryRow(prepared);

    if (row.isNull)
    {
      return TModel.init;
    }

    auto model = new TModel;
    model.row = row.get;
    model.readModel();
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
    mixin(MySqlConnectionNamedParametersSetup);

    Variant variant = Variant.init;
    auto value = connection.queryValue(prepared);

    if (value.isNull)
    {
      return variant;
    }

    return value.get;
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
    mixin(MySqlConnectionSetup);

    Variant variant = Variant.init;
    auto value = connection.queryValue(prepared);

    if (value.isNull)
    {
      return variant;
    }

    return value.get;
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
    auto rows = execute(query, params, connectionString);

    if (!rows)
    {
      return Variant.init;
    }

    static const idSql = "SELECT last_insert_id()";

    return scalarRawImpl(idSql, null, connectionString);
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
    auto rows = executeRaw(query, params, connectionString);

    if (!rows)
    {
      return Variant.init;
    }

    static const idSql = "SELECT last_insert_id()";

    return scalarRawImpl(idSql, null, connectionString);
  }
}
