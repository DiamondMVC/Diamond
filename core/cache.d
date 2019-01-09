/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.cache;

/// Thread-local cache.
private ICacheEntry[string] _cache;
/// Global cache.
private __gshared ICacheEntry[string] _globalCache;

/// An interface around a cache entry.
private interface ICacheEntry { }

/// Wrapper around a cache entry.
private class CacheEntry(T) : ICacheEntry
{
  /// The value to be cached.
  T value;
}

/**
* Adds an entry to the thread-local cache.
* Params:
*   key =   The key of the entry.
*   value = The value to cache.
*   cacheTime = The amount of time the value should be cached. (0 = forever)
*/
void addCache(T)(string key, T value, size_t cacheTime = 0)
{
  _cache[key] = new CacheEntry!T(value);

  if (cacheTime)
  {
    import diamond.tasks : executeTask, sleep, msecs;

    executeTask(
    {
      sleep(cacheTime.msecs);

      removeCache(key);
    });
  }
}

/**
* Removes a cached value.
* Params:
*   key = the key of the cached entry to remove.
*/
void removeCache(string key)
{
  _cache.remove(key);
}

/**
* Gets a value from the cache.
* Params:
*   key = The key of the value to get.
*/
T getCache(T)(string key)
{
  auto entry = _cache.get(key, null);

  if (!entry)
  {
    return T.init;
  }

  return (cast(CacheEntry!T)entry).value;
}

/// Clears the cache.
void clearCache()
{
  _cache.clear();
}

/**
* Adds an entry to the global cache.
* Params:
*   key =   The key of the entry.
*   value = The value to cache.
*   cacheTime = The amount of time the value should be cached. (0 = forever)
*/
void addGlobalCache(T)(string key, T value, size_t cacheTime = 0)
{
  _globalCache[key] = new CacheEntry!T(value);

  if (cacheTime)
  {
    import diamond.tasks : executeTask, sleep, msecs;

    executeTask(
    {
      sleep(cacheTime.msecs);

      removeCache(key);
    });
  }
}

/**
* Removes a globally cached value.
* Params:
*   key = the key of the cached entry to remove.
*/
void removeGlobalCache(string key)
{
  _globalCache.remove(key);
}

/**
* Gets a value from the global cache.
* Params:
*   key = The key of the value to get.
*/
T getGlobalCache(T)(string key)
{
  auto entry = _globalCache.get(key, null);

  if (!entry)
  {
    return T.init;
  }

  return (cast(CacheEntry!T)entry).value;
}

/// Clears the global cache.
void clearGlobalCache()
{
  _globalCache.clear();
}
