/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewcache;

import diamond.http.client : HttpClient;

/**
* Caches a view.
* Params:
*   client =       The client to cache from.
*   result =    The result to cache.
*   cacheTime = The time to cache the view. 0 equals process-lifetime.
*/
package(diamond) void cacheView(HttpClient client, string result, size_t cacheTime)
{
  import diamond.app.appcache;

  cache.updateCache(client, result);

  if (cacheTime)
  {
    import diamond.tasks : executeTask, sleep, msecs;

    executeTask(
    {
      sleep(cacheTime.msecs);

      cache.removeCache(client);
    });
  }
}

/**
* Gets the result of a cached view.
* Params:
*   client = The client to get the cached view from.
* Returns:
*   The cached view result if present.
*/
string getCachedView(HttpClient client)
{
  import diamond.app.appcache;

  return cache.retrieveCache(client);
}
