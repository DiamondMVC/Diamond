/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.app.appcache;

import diamond.http.client : HttpClient;

/// Interface for an app cache.
interface IAppCache
{
  /**
  * Updates the app cache.
  * Params:
  *   client =        The client to cache from.
  *   defaultResult = The default result to cache.
  */
  void updateCache(HttpClient client, string defaultResult);

  /**
  * Retrieves the cached result based on a client.
  * Params:
  *   client = The client to receive the cached result based on.
  * Returns:
  *   The cached result.
  */
  string retrieveCache(HttpClient client);

  /// Clears the cache results.
  void clearCache();

  /**
  * Removes a cached result.
  * Params:
  *   client = The client to remove the cached result based on.
  */
  void removeCache(HttpClient client);
}

/**
* Sets the app cache.
* Params:
*   cache = The app cache.
*/
void setAppCache(IAppCache cache)
{
  if (!cache)
  {
    return;
  }

  _cache = cache;
}

private
{
  /// Wrapper around the default diamond app cache.
  class DiamondAppCache : IAppCache
  {
    private:
    /// The cache.
    string[string] _cache;

    public:
    /// Creates a new diamond app cache.
    this()
    {

    }

    /**
    * Updates the app cache.
    * Params:
    *   client =        The client to cache from.
    *   defaultResult = The default result to cache.
    */
    void updateCache(HttpClient client, string defaultResult)
    {
      _cache[client.route.name] = defaultResult;
    }

    /**
    * Retrieves the cached result based on a client.
    * Params:
    *   client = The client to receive the cached result based on.
    * Returns:
    *   The cached result.
    */
    string retrieveCache(HttpClient client)
    {
      return _cache.get(client.route.name, null);
    }

    /// Clears the cache results.
    void clearCache()
    {
      _cache.clear();
    }

    /**
    * Removes a cached result.
    * Params:
    *   client = The client to remove the cached result based on.
    */
    void removeCache(HttpClient client)
    {
      _cache.remove(client.route.name);
    }
  }

  /// The cache.
  __gshared IAppCache _cache;
}

package(diamond):
/// Gets the app cache.
@property IAppCache cache()
{
  return _cache;
}
