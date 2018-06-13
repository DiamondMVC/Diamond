/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.sqlshared;

import std.conv : to;

import mysql;

import diamond.database : DbParam;

public
{
  import diamond.data.mapping.engines.sqlshared.sqladapter;
  import diamond.data.mapping.engines.sqlshared.sqlentityformatter;
}

mixin template CreatePool(TPool, string extraParams = "")
{
  /// Global pool lock to ensure we don't attempt to create a connection pool twice on same connection string.
  private static shared globalPoolLock = new Object;

  static const poolFormat = q{
    package(diamond.data.mapping.engines) TPool getPool(string connectionString)
    {
      auto pool = _pools.get(connectionString, null);

      if (!pool)
      {
        synchronized (globalPoolLock)
        {
          pool = new TPool(connectionString%s);

          _pools[connectionString] = pool;
        }

        return getPool(connectionString);
      }

      return pool;
    }
  };

  import std.string : format;

  mixin(poolFormat.format("," ~ extraParams));
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
package(diamond.data.mapping.engines) DbParam[] prepareSql(string sql, DbParam[string] params, out string transformedSql)
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
