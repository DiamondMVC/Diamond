/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.sqlshared.sqladapter;

import std.variant : Variant;

import diamond.data.mapping.model;
import diamond.database : DbParam;

/// Wrapper around a sql adapter.
abstract class SqlAdapter(TModel)
{
  private:
  /// The connection string.
  string _connectionString;

  public:
  /**
  * Creates a new sql adapter.
  * Params:
  *   connectionString = The connection string of the adapter.
  */
  final this(string connectionString)
  {
    _connectionString = connectionString;
  }

  @property
  {
    /// Gets the connection string.
    final string connectionString() { return _connectionString; }
  }

  public:
  /**
  *  Executes an sql statement.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    The amount of rows affected.
  */
  abstract ulong execute(string query, DbParam[string] params, string connectionString = null);

  /**
  *  Executes a raw sql statement.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    The amount of rows affected.
  */
  abstract ulong executeRaw(string query, DbParam[] params, string connectionString = null);

  /**
  *  Validates whether a row is selected from the query or not.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    True if the row exists, false otherwise.
  */
  abstract bool exists(string query, DbParam[string] params, string connectionString = null);

  /**
  *  Validates whether a row is selected from the raw query or not.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    True if the row exists, false otherwise.
  */
  abstract bool existsRaw(string query, DbParam[] params, string connectionString = null);

  /**
  *  Executes a multi sql read.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    A range filled models with the rows returned by the sql read.
  */
  abstract TModel[] readMany(string query, DbParam[string] params, string connectionString = null);

  /**
  *  Executes a raw multi sql read.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    A range filled models with the rows returned by the sql read.
  */
  abstract TModel[] readManyRaw(string query, DbParam[] params, string connectionString = null);

  /**
  *  Executes a single sql read.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    The model of the first row read.
  */
  abstract TModel readSingle(string query, DbParam[string] params, string connectionString = null);

  /**
  *  Executes a single raw sql read.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    The model of the first row read.
  */
  abstract TModel readSingleRaw(string query, DbParam[] params, string connectionString = null);

  protected
  {
    /**
    *  Executes a scalar sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The value of the statement.
    */
    abstract Variant scalarImpl(string query, DbParam[string] params, string connectionString = null);

    /**
    *  Executes a raw scalar sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The value of the statement.
    */
    abstract Variant scalarRawImpl(string query, DbParam[] params, string connectionString = null);

    /**
    *  Executes a scalar insert sql statement.
    *  Params:
    *    query =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The id of inserted row.
    */
    abstract Variant scalarInsertImpl(string query, DbParam[string] params, string connectionString = null);

    /**
    *  Executes a raw scalar insert sql statement.
    *  Params:
    *    sql =                The sql query.
    *    params =             The parameters.
    *    connectionString =  The connection string. (If null, it will select the default)
    *  Returns:
    *    The id of the inserted row.
    */
    abstract Variant scalarInsertRawImpl(string query, DbParam[] params, string connectionString = null);
  }

  public:
  final:
  /**
  *  Executes a scalar sql statement.
  *  Params:
  *    query =                The sql query.
  *    params =             The parameters.
  *    connectionString =  The connection string. (If null, it will select the default)
  *  Returns:
  *    The value of the statement.
  */
  T scalar(T)(string query, DbParam[string] params, string connectionString = null)
  {
    Variant value = scalarImpl(query, params, connectionString);

    if (!value.hasValue)
    {
      return T.init;
    }

    return value.get!T;
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
  T scalarRaw(T)(string query, DbParam[] params, string connectionString = null)
  {
    Variant value = scalarRawImpl(query, params, connectionString);

    if (!value.hasValue)
    {
      return T.init;
    }

    return value.get!T;
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
  T scalarInsert(T)(string query, DbParam[string] params, string connectionString = null)
  {
    Variant value = scalarInsertImpl(query, params, connectionString);

    if (!value.hasValue)
    {
      return T.init;
    }

    return value.get!T;
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
  T scalarInsertRaw(T)(string query, DbParam[] params, string connectionString = null)
  {
    Variant value = scalarInsertRawImpl(query, params, connectionString);

    if (!value.hasValue)
    {
      return T.init;
    }

    return value.get!T;
  }
}
