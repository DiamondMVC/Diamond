/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql;

import std.string : format;
import std.variant : Variant;

import mysql;

import diamond.data.mapping.engines.sqlshared;

public
{
  import diamond.data.mapping.engines.mysql.mysqladapter;
  import diamond.data.mapping.engines.mysql.mysqlentityformatter;
  import diamond.data.mapping.engines.mysql.mysqlmodel;
}

/// A variant db parameter type.
alias DbParam = Variant;

/// The connection string format.
private enum connectionStringFormat = "host=%s;port=%s;user=%s;pwd=%s;db=%s";

/// The db connection string.
private static __gshared string _dbConnectionString;

/// Collection of mysql connection pools.
private static __gshared MySQLPool[string] _pools;

package(diamond.data.mapping.engines)
{
  mixin CreatePool!(MySQLPool);
}

/// Initializing Mysql
package(diamond) void initializeMySql()
{
  import diamond.core.webconfig;

  if (!webConfig)
  {
    loadWebConfig();
  }

  if (!webConfig.dbConnections || !webConfig.dbConnections.mysql)
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

  import diamond.data.mapping.engines.mysql.mysqlmodel;

  initializeMySqlAdapter(_dbConnectionString);
}

@property
{
  /// Gets the connection string.
  auto dbConnectionString()
  {
    return _dbConnectionString;
  }
}

/// The mysql adapter.
private __gshared MySqlRawAdapter _adapter;

/**
* Initializes the mysql adapter.
* Params:
*   connectionString = The connection string of the mysql adapter.
*/
package(diamond) void initializeMySqlAdapter(string connectionString)
{
  _adapter = new MySqlRawAdapter(connectionString);
}

@property
{
  /// Gets the mysql adapter.
  MySqlRawAdapter mySqlAdapter() { return _adapter; }
}
