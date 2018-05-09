/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewcache;

private __gshared string[string] _cache;

/**
* Caches a view.
* Params:
*   route =       The route to cache.
*   result =    The result to cache.
*   cacheTime = The time to cache the view. 0 equals process-lifetime.
*/
package(diamond) void cacheView(string route, string result, size_t cacheTime)
{
  _cache[route] = result;

  if (cacheTime)
  {
    import diamond.tasks : executeTask, sleep, msecs;

    executeTask(
    {
      sleep(cacheTime.msecs);

      _cache.remove(route);
    });
  }
}

/**
* Gets the result of a cached view.
* Params:
*   route = The route of the view to retrieve.
*/
string getCachedView(string route)
{
  return _cache.get(route, null);
}
