/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.database;

import std.variant : Variant;

public
{
  import std.datetime : Date, DateTime, Clock, SysTime;

  import diamond.data.mapping.attributes;

  import diamond.data.mapping.engines.mysql.model;

  version (Diamond_PostgreSqlDev)
  {
    import diamond.data.mapping.engines.postgresql.model;
  }

  import MySql = diamond.data.mapping.engines.mysql;
  version (Diamond_PostgreSqlDev)
  {
    import PostgreSql = diamond.data.mapping.engines.postgresql;
  }

  /// A variant db parameter type.
  alias DbParam = Variant;

  import diamond.database.mongo;
}

/// Gets an associative array to use for specialized parameters.
auto getParams()
{
  DbParam[string] params;

  return params;
}

/// Gets a static-sized array to use for raw sql statements.
auto getParams(size_t count)
{
  return new DbParam[count];
}
