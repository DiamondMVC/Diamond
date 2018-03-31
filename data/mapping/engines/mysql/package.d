/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql;

import std.variant : Variant;
import std.traits : hasMember;
import std.algorithm : map;
import std.conv : to;
import std.string : format;
import std.typecons : Nullable;
import std.array : array;

import vibe.data.serialization : optional;

import mysql;

public
{
  import diamond.data.mapping.engines.mysql.generators;
  import diamond.data.mapping.engines.mysql.model;
}

/// A variant db parameter type.
alias DbParam = Variant;

/// The connection string format.
private enum connectionStringFormat = "host=%s;port=%s;user=%s;pwd=%s;db=%s";

/// The db connection string.
private static __gshared string _dbConnectionString;

/// Static shared constructor for the module.
package(diamond) void initializeMySql()
{
  import diamond.core.webconfig;

  if (!webConfig)
  {
    loadWebConfig();
  }

  if (!webConfig.dbConnections)
  {
    return;
  }

  auto dbConfig = webConfig.dbConnections.mysql.get("default", null);

  if (!dbConfig)
  {
    return;
  }

  _dbConnectionString = connectionStringFormat.format(
    dbConfig.host, dbConfig.port ? dbConfig.port : 3306,
    dbConfig.user, dbConfig.password,
    dbConfig.database
  );

  _pools[_dbConnectionString] = new MySQLPool(_dbConnectionString);
}

@property
{
  /// Gets the connection string.
  auto dbConnectionString()
  {
    return _dbConnectionString;
  }
}

/// Collection of connection pools.
private static __gshared MySQLPool[string] _pools;

/// Global pool lock to ensure we don't attempt to create a connection pool twice on same connection string.
private static shared globalPoolLock = new Object;

/**
* Gets or creates a mysql pool from a connection string.
* Params:
*   connectionString = The connection string for the pool.
* Returns:
*   The mysql pool.
*/
private MySQLPool getPool(string connectionString)
{
  auto pool = _pools.get(connectionString, null);

  if (!pool)
  {
    synchronized (globalPoolLock)
    {
      pool = new MySQLPool(connectionString);

      _pools[connectionString] = pool;
    }

    return getPool(connectionString);
  }

  return pool;
}

/**
* Prepares a specialized parameter sql.
* Params:
*   sql =            The sql.
*   params =         The params.
*   transformedSql = The newly transformed sql.
* Returns:
*   The raw db parameters.
*/
private DbParam[] prepareSql(string sql, DbParam[string] params, out string transformedSql)
{
  transformedSql = "";
  string paramName = "";
  bool selectParam = false;
  DbParam[] sqlParams;

  foreach (i; 0 .. sql.length)
  {
    auto c = sql[i];

    if (c == 13) continue;

    bool isEnd = i == (sql.length - 1);

    if (c == '@')
    {
      paramName = "";
      selectParam = true;
    }
    else if (selectParam && (
      c == ';' || c == '=' ||
      c == '+' || c == '-' ||
      c == 9 || c == 13 ||
      c == 10 || c == ' ' ||
      c == 0 || c == '|' ||
      c == '.' || c == '/' ||
      c == '*' || c == '(' ||
      c == ')' || c == '[' ||
      c == ']' || c == ',' ||
      c == '`' || c == 39
    ))
    {
      if (paramName == "table")
      {
        transformedSql ~= params[paramName].get!string ~ to!string(c);
        selectParam = false;
        paramName = "";
      }
      else
      {
        sqlParams ~= params[paramName];
        transformedSql ~= "?" ~ c;

        selectParam = false;
        paramName = "";
      }
    }
    else if (selectParam)
    {
      paramName ~= c;

      if (isEnd)
      {
        if (paramName == "table")
        {
          transformedSql ~= params[paramName].get!string ~ to!string(c);
        }
        else
        {
          sqlParams ~= params[paramName];
          transformedSql ~= "?";
        }
      }
    }
    else
    {
      transformedSql ~= c;
    }
  }

  return sqlParams;
}

/// CTFE string for mixin MySql connection setup with specialized parameters.
private enum MySqlConnectionNamedParametersSetup = q{
  auto useDbConnectionString = connectionString ? connectionString : _dbConnectionString;

  // Prepare statement
  string newSql;
  DbParam[] newParams = null;
  if (params)
  {
    newParams = prepareSql(sql, params, newSql);
  }
  else
  {
    newSql = sql;
  }

  auto pool = getPool(useDbConnectionString);
  auto connection = pool.lockConnection();
  auto prepared = connection.prepare(newSql);

  prepared.setArgs(newParams);
};

/// CTFE string for mixin MySql connection setup.
private enum MySqlConnectionSetup = q{
  auto useDbConnectionString = connectionString ? connectionString : _dbConnectionString;

  auto pool = getPool(useDbConnectionString);
  auto connection = pool.lockConnection();
  auto prepared = connection.prepare(sql);

  prepared.setArgs(params);
};

/**
*  Executes an sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The amount of rows affected.
*/
ulong execute(string sql, DbParam[string] params, string connectionString = null)
{
  mixin(MySqlConnectionNamedParametersSetup);

  return connection.exec(prepared);
}

/**
*  Executes a raw sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The amount of rows affected.
*/
ulong executeRaw(string sql, DbParam[] params, string connectionString = null)
{
  mixin(MySqlConnectionSetup);

  return connection.exec(prepared);
}

/**
*  Executes a scalar sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The value of the statement.
*/
T scalar(T)(string sql, DbParam[string] params, string connectionString = null)
{
  mixin(MySqlConnectionNamedParametersSetup);

  auto value = connection.queryValue(prepared);

  if (value.isNull)
  {
    return T.init;
  }

  return value.get.get!T;
}

/**
*  Executes a raw scalar sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The value of the statement.
*/
T scalarRaw(T)(string sql, DbParam[] params, string connectionString = null)
{
  mixin(MySqlConnectionSetup);

  auto value = connection.queryValue(prepared);

  if (value.isNull)
  {
    return T.init;
  }

  return value.get.get!T;
}

/**
*  Executes a scalar insert sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The id of inserted row.
*/
T scalarInsert(T)(string sql, DbParam[string] params, string connectionString = null)
{
  auto rows = execute(sql, params, connectionString);

  if (!rows)
  {
    return T.init;
  }

  static const idSql = "SELECT last_insert_id()";

  return scalar!T(sql, null, connectionString);
}

/**
*  Executes a raw scalar insert sql statement.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The id of the inserted row.
*/
T scalarInsertRaw(T)(string sql, DbParam[] params, string connectionString = null)
{
  auto rows = executeRaw(sql, params, connectionString);

  if (!rows)
  {
    return T.init;
  }

  static const idSql = "SELECT last_insert_id()";

  return scalarRaw!T(sql, null, connectionString);
}

/**
*  Validates whether a row is selected from the query or not.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    True if the row exists, false otherwise.
*/
bool exists(string sql, DbParam[string] params, string connectionString = null)
{
  auto rows = execute(sql, params, connectionString);

  return cast(bool)rows;
}

/**
*  Validates whether a row is selected from the raw query or not.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    True if the row exists, false otherwise.
*/
bool existsRaw(string sql, DbParam[] params, string connectionString = null)
{
  auto rows = executeRaw(sql, params, connectionString);

  return cast(bool)rows;
}

/**
*  Executes a single sql read.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The model of the first row read.
*/
TModel readSingle(TModel : IMySqlModel)(string sql, DbParam[string] params, string connectionString = null)
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
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    The model of the first row read.
*/
TModel readSingleRaw(TModel : IMySqlModel)(string sql, DbParam[] params, string connectionString = null)
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

/**
*  Executes a multi sql read.
*  Params:
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    A range filled models with the rows returned by the sql read.
*/
auto readMany(TModel : IMySqlModel)(string sql, DbParam[string] params, string connectionString = null)
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
*    sql =                The sql query.
*    params =             The parameters.
*    connectionString =  The connection string. (If null, it will select the default)
*  Returns:
*    A range filled models with the rows returned by the sql read.
*/
auto readManyRaw(TModel : IMySqlModel)(string sql, DbParam[] params, string connectionString = null)
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
