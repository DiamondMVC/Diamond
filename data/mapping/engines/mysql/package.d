/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql;

import std.variant : Variant;
import std.traits : hasMember;
import std.algorithm : map;
import std.conv : to;
import std.string : format;

import vibe.data.serialization : optional;

import mysql.db;
import mysql.commands;

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
private static __gshared immutable string _dbConnectionString;

/// The configurations for the connection string.
private class DbConfig
{
  /// The host.
  string host;
  /// The port.
  @optional ushort port;
  /// The user.
  string user;
  /// The password.
  string password;
  /// The database.
  string database;
}

/// Static shared constructor for the module.
shared static this()
{
  import std.file : exists, readText;
  import vibe.d : deserializeJson;
  
  if (!exists("config/db.json"))
  {
    return;
  }

  auto dbConfig = deserializeJson!DbConfig(readText("config/db.json"));

  _dbConnectionString = connectionStringFormat.format(
    dbConfig.host, dbConfig.port ? dbConfig.port : 3306,
    dbConfig.user, dbConfig.password,
    dbConfig.database
  );
}

@property
{
  /// Gets the connection string.
  auto dbConnectionString()
  {
    return _dbConnectionString;
  }
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
/// TODO: Implement MySql Pool: https://raw.githubusercontent.com/mysql-d/mysql-native/4eaf5c6bb57d4ca852aa7fa5e8d2cd8810c0808a/source/mysql/pool.d
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

	// Setup MySql connection ...
	import mysql.db;
	auto mdb = new MysqlDB(useDbConnectionString);
	auto c = mdb.lockConnection();
	scope(exit) c.close();

	// Prepare the command ...
	auto cmd = new Command(c, newSql);
	cmd.prepare();

	// Binds the parameters ...
	cmd.bindParameters(newParams);
};

/// CTFE string for mixin MySql connection setup.
private enum MySqlConnectionSetup = q{
  auto useDbConnectionString = connectionString ? connectionString : _dbConnectionString;

	// Setup MySql connection ...
	import mysql.db;
	auto mdb = new MysqlDB(useDbConnectionString);
	auto c = mdb.lockConnection();
	scope(exit) c.close();

	// Prepare the command ...
	auto cmd = new Command(c, sql);
	cmd.prepare();

	// Binds the parameters ...
	cmd.bindParameters(params);
};

/**
*	Executes an sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The amount of rows affected.
*/
ulong execute(string sql, DbParam[string] params, string connectionString = null)
{
  // Setsup the mysql connection
  mixin(MySqlConnectionNamedParametersSetup);

  // Executes the statement ...
  ulong affectedRows;
  cmd.execPrepared(affectedRows);

  return affectedRows;
}

/**
*	Executes a raw sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The amount of rows affected.
*/
ulong executeRaw(string sql, DbParam[] params, string connectionString = null)
{
  // Setsup the mysql connection
  mixin(MySqlConnectionSetup);

  // Executes the statement ...
  ulong affectedRows;
  cmd.execPrepared(affectedRows);

  return affectedRows;
}

/**
*	Executes a scalar sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The value of the statement.
*/
T scalar(T)(string sql, DbParam[string] params, string connectionString = null)
{
  // Setup the mysql connection
  mixin(MySqlConnectionNamedParametersSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return T.init;
  }

  // Returns the first column selected of the first row ...
  return rows[0][0].get!T;
}

/**
*	Executes a raw scalar sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The value of the statement.
*/
T scalarRaw(T)(string sql, DbParam[] params, string connectionString = null)
{
  // Setup the mysql connection
  mixin(MySqlConnectionSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return T.init;
  }

  // Returns the first column selected of the first row ...
  return rows[0][0].get!T;
}

/**
*	Executes a scalar insert sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The id of inserted row.
*/
T scalarInsert(T)(string sql, DbParam[string] params, string connectionString = null)
{
  // Setup the mysql connection
  mixin(MySqlConnectionNamedParametersSetup);

  ulong affectedRows;
  cmd.execPrepared(affectedRows);

  if (!affectedRows)
  {
    return T.init;
  }

  // Prepare the id command ...
	cmd = new Command(c, "SELECT last_insert_id()");
	cmd.prepare();

  newParams = null;
	cmd.bindParameters(newParams);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return T.init;
  }

  // Returns the first column selected of the first row ...
  return rows[0][0].get!T;
}

/**
*	Executes a raw scalar insert sql statement.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The id of the inserted row.
*/
T scalarInsertRaw(T)(string sql, DbParam[] params, string connectionString = null)
{
  // Setup the mysql connection
  mixin(MySqlConnectionSetup);

  ulong affectedRows;
  cmd.execPrepared(affectedRows);

  if (!affectedRows)
  {
    return T.init;
  }

  // Prepare the id command ...
	cmd = new Command(c, "SELECT last_insert_id()");
	cmd.prepare();

  params = null;
	cmd.bindParameters(params);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return T.init;
  }

  // Returns the first column selected of the first row ...
  return rows[0][0].get!T;
}

/**
*	Validates whether a row is selected from the query or not.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		True if the row exists, false otherwise.
*/
bool exists(string sql, DbParam[string] params, string connectionString = null)
{
  mixin(MySqlConnectionNamedParametersSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  return cast(bool)rows.length;
}

/**
*	Validates whether a row is selected from the raw query or not.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		True if the row exists, false otherwise.
*/
bool existsRaw(string sql, DbParam[] params, string connectionString = null)
{
  mixin(MySqlConnectionSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  return cast(bool)rows.length;
}

/**
*	Executes a single sql read.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The model of the first row read.
*/
TModel readSingle(TModel : IMySqlModel)(string sql, DbParam[string] params, string connectionString = null)
{
  params["table"] = TModel.table;

  // Sets up the mysql connection
  mixin(MySqlConnectionNamedParametersSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return TModel.init;
  }

  // Returns the first row and fills the model ...
  auto model = new TModel;
  model.row = rows[0];
  model.readModel();
  return model;
}

/**
*	Executes a single raw sql read.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		The model of the first row read.
*/
TModel readSingleRaw(TModel : IMySqlModel)(string sql, DbParam[] params, string connectionString = null)
{
  // Sets up the mysql connection
  mixin(MySqlConnectionSetup);

  // Executes the statement ...
  auto rows = cmd.execPreparedResult();

  // Checks whether there's a result ...
  if (!rows.length)
  {
    return TModel.init;
  }

  // Returns the first row and fills the model ...
  auto model = new TModel();
  model.row = rows[0];
  model.readModel();
  return model;
}

/**
*	Executes a multi sql read.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		A range filled models with the rows returned by the sql read.
*/
auto readMany(TModel : IMySqlModel)(string sql, DbParam[string] params, string connectionString = null)
{
  params["table"] = TModel.table;

  // Sets up the mysql connection
  mixin(MySqlConnectionNamedParametersSetup);

  // Executes the statement ...
  return cmd.execPreparedResult().map!((row)
  {
    auto model = new TModel();
    model.row = row;
    model.readModel();
    return model;
  });
}

/**
*	Executes a raw multi sql read.
*	Params:
*		sql =				        The sql query.
*		params = 			      The parameters.
*		connectionString =	The connection string. (If null, it will select the default)
*	Returns:
*		A range filled models with the rows returned by the sql read.
*/
auto readManyRaw(TModel : IMySqlModel)(string sql, DbParam[] params, string connectionString = null)
{
  // Sets up the mysql connection
  mixin(MySqlConnectionSetup);

  // Executes the statement ...
  return cmd.execPreparedResult().map!((row)
  {
    auto model = new TModel();
    model.row = row;
    model.readModel();
    return model;
  });
}
