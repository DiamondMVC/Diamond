/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.postgresql;

version (Diamond_PostgreSqlDev)
{
  import vibe.db.postgresql;

  import diamond.data.mapping.engines.sqlshared;

  /// The connection string format.
  private enum connectionStringFormat = "host=%s port=%s dbname=%s user=%s password=%s";

  /// The db connection string.
  private static __gshared string _dbConnectionString;

  /// Collection of connection pools.
  private PostgresClient[string] _pools;

  private
  {
    mixin CreatePool!(PostgresClient, "4");
  }

  /// Initializing Postgresql
  package(diamond) void initializePostgreSql()
  {
    import diamond.core.webconfig;

    if (!webConfig)
    {
      loadWebConfig();
    }

    if (!webConfig.dbConnections && !webConfig.dbConnections.postgresql)
    {
      return;
    }

    auto dbConfig = webConfig.dbConnections.postgresql.get("default", null);

    if (!dbConfig)
    {
      return;
    }

    _dbConnectionString = connectionStringFormat.format(
      dbConfig.host, dbConfig.port ? dbConfig.port : 5432,
      dbConfig.database && dbConfig.database ? dbConfig.database : "public",
      dbConfig.user, dbConfig.password
    );
  }
}
