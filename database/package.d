/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.database;

import std.variant : Variant;

import diamond.core.apptype;

public
{
  import std.datetime : Date, DateTime, Clock, SysTime;

  import diamond.data.mapping.attributes;

  import diamond.data.mapping.engines.mysql;
  import MySql = diamond.data.mapping.engines.mysql;

  static if (hasMsSql)
  {
    import diamond.data.mapping.engines.mssql;
    import MsSql = diamond.data.mapping.engines.mssql;
  }

  /// A variant db parameter type.
  alias DbParam = Variant;

  /// A variant db value type.
  alias DbValue = Variant;

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
