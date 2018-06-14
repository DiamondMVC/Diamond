/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mssql;

import diamond.core.apptype;

static if (hasMsSql)
{
  import std.string : format;
  import std.variant : Variant;

  import diamond.data.mapping.engines.sqlshared;

  public
  {
    import diamond.data.mapping.engines.mssql.mssqladapter;
    import diamond.data.mapping.engines.mssql.mssqlentityformatter;
    import diamond.data.mapping.engines.mssql.mssqlmodel;
  }

  /// A variant db parameter type.
  alias DbParam = Variant;

  /// The connection string format.
  private enum connectionStringFormat = "odbc://%s/%s/?user=%s,password=%s,driver=FreeTDS,database=%s";

  /// The db connection string.
  private static __gshared string _dbConnectionString;

  /// Collection of mssql connection pools.
  // private static __gshared POOL_NAME[string] _pools;

  package(diamond.data.mapping.engines)
  {
    // mixin CreatePool!(POOL_NAME);
  }

  /// Initializing Mssql
  package(diamond) void initializeMsSql()
  {
    import diamond.core.webconfig;

    if (!webConfig)
    {
      loadWebConfig();
    }

    if (!webConfig.dbConnections || !webConfig.dbConnections.mssql)
    {
      return;
    }

    auto dbConfig = webConfig.dbConnections.mssql.get("default", null);

    if (!dbConfig)
    {
      return;
    }

    _dbConnectionString = connectionStringFormat.format(
      dbConfig.host, dbConfig.namedInstance,
      dbConfig.user, dbConfig.password,
      dbConfig.database
    );

    // _pools[_dbConnectionString] = new POOL_NAME(_dbConnectionString);

    import diamond.data.mapping.engines.mssql.mssqlmodel;

    initializeMsSqlAdapter(_dbConnectionString);
  }

  @property
  {
    /// Gets the connection string.
    auto dbConnectionString()
    {
      return _dbConnectionString;
    }
  }

  /// The mssql adapter.
  private __gshared MsSqlRawAdapter _adapter;

  /**
  * Initializes the mssql adapter.
  * Params:
  *   connectionString = The connection string of the mssql adapter.
  */
  package(diamond) void initializeMsSqlAdapter(string connectionString)
  {
    _adapter = new MsSqlRawAdapter(connectionString);
  }

  @property
  {
    /// Gets the mssql adapter.
    MsSqlRawAdapter msSqlAdapter() { return _adapter; }
  }

}
