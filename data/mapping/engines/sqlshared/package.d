/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.sqlshared;

mixin template CreatePool(TPool, string extraParams = "")
{
  /// Global pool lock to ensure we don't attempt to create a connection pool twice on same connection string.
  private static shared globalPoolLock = new Object;

  static const poolFormat = q{
    private TPool getPool(string connectionString)
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
