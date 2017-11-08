/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.routing;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest;

  import diamond.errors : enforce;

  /// Collection of routes.
  private static __gshared RouteEntry[string] _routes;

  package(diamond)
  {
    /// Gets a boolean determining whether there are routes specified.
    @property bool hasRoutes()
    {
      return _routes && _routes.length;
    }

    /// Enumeration of route modes.
    enum RouteMode
    {
      /// Specifies a redirection route.
      redirect,
      /// Specifies a combination route.
      combine,
      /// Specifies an internal route.
      internal
    }

    /// A route entry.
    class RouteEntry
    {
      /// The mode of the route.
      RouteMode mode;
      /// The routes.
      string[] routes;

      /**
      * Creates a new route entry.
      * Params:
      *   mode =   The mode.
      *   routes = The routes.
      */
      this(RouteMode mode, string[] routes)
      {
        this.mode = mode;
        this.routes = routes;
      }
    }

    /**
    * Handling a route.
    * Params:
    *   isInternal =  Boolean determining whether the handling is internal.
    *   route =       The route.
    * Returns:
    *   The routes to handle for the specific route.
    */
    auto handleRoute(bool isInternal, string route)
    {
      auto routeEntry = _routes.get(rewriteRoute(route), null);

      if (!routeEntry)
      {
        return [route];
      }

      if (!routeEntry.routes || !routeEntry.routes.length)
      {
        return null;
      }

      final switch (routeEntry.mode)
      {
        case RouteMode.redirect: return routeEntry.routes[1 .. $]; // Using slices avoid s allocation
        case RouteMode.combine: return routeEntry.routes;
        case RouteMode.internal: return isInternal ? routeEntry.routes[0 .. 1] : null; // Using slices avoids allocation
      }
    }
  }

  /**
  * Rewrites a route.
  * Params:
  *   route = The route to rewrite.
  * Returns:
  *   The rewritten route.
  */
  private string rewriteRoute(string route)
  {
    import std.string : strip;
    import diamond.core.string : firstToLower;

    if (route == "/")
    {
      import diamond.core : webConfig;

      route = webConfig.homeRoute.firstToLower();
    }

    if (route[0] == '/')
    {
      route = route[1 .. $];
    }

    if (route[$-1] == '/')
    {
      route = route[0 .. $-1];
    }

    return route.strip();
  }

  /**
  * Adds a route.
  * Params:
  *   mode =             The mode of the route.
  *   sourceRoute =      The source route.
  *   destinationRoute = The destination route. (Should be null for RouteMode.internal)
  */
  private void addRoute(RouteMode mode, string sourceRoute, string destinationRoute)
  {
    import std.string : strip;

    enforce(sourceRoute && sourceRoute.strip().length, "Found no source route.");

    if (mode != RouteMode.internal)
    {
      enforce(destinationRoute && destinationRoute.strip().length, "Found no destination route.");
    }

    sourceRoute = rewriteRoute(sourceRoute);

    if (mode != RouteMode.internal)
    {
      destinationRoute = rewriteRoute(destinationRoute);
    }

    _routes[sourceRoute] = new RouteEntry(mode, destinationRoute ? [sourceRoute, destinationRoute] : [sourceRoute]);
  }

  /// Static class to create routes.
  static final class Routes
  {
    public:
    final:
    static:
    /**
    * Creates a redirection route.
    * Will redirect 'sourceRoute' to 'destinationRoute' internally.
    * Params:
    *   sourceRoute =      The source route.
    *   destinationRoute = The destination route.
    */
    void redirect(string sourceRoute, string destinationRoute)
    {
      addRoute(RouteMode.redirect, sourceRoute, destinationRoute);
    }

    /**
    * Creates a combination route.
    * Will handle 'sourceRoute' first, then 'destinationRoute' afterwaards.
    * The first route should not create respponse data!
    * For data passing from first route to the second use the request context.
    * Params:
    *   sourceRoute =      The source route.
    *   destinationRoute = The destination route.
    */
    void combine(string sourceRoute, string destinationRoute)
    {
      addRoute(RouteMode.combine, sourceRoute, destinationRoute);
    }

    /**
    * Creates an internal route.
    * Internal routes can only be accessed internally, which measn any external access to them will throw an unauthorized error.
    * Params:
    *   route = The route.
    */
    void internal(string route)
    {
      addRoute(RouteMode.internal, route, null);
    }
  }

  // A http route.
  final class Route
  {
    private:
    /// The raw route url.
    string _raw;
    /// The name of the route.
    string _name;
    /// The action of the route.
    string _action;
    /// The paramters of the route.
    string[] _params;

    public:
    final:
    /**
    * Creates a new route.
    * Params:
    *   url = The url of the route.
    */
    package(diamond) this(string url)
    {
      enforce(url && url.length, "Invalid route url.");

      import std.string : strip;
      import diamond.core.string : firstToLower;

      url = url.strip();
      _raw = url;

      if (url == "/")
      {
        import diamond.core : webConfig;

        _name = webConfig.homeRoute.firstToLower();
        return;
      }

      import std.array : split, array;
      import std.algorithm : map, canFind;

      if (url[0] == '/')
      {
        url = url[1 .. $];
      }

      if (url[$-1] == '/')
      {
        url = url[0 .. $-1];
      }

      auto routeData = url.split("/");

      enforce(!routeData[$-1].canFind("?"), "Found query string in the routing url.");

      _name = routeData[0].strip().firstToLower();

      if (routeData.length > 1)
      {
        _action = routeData[1].strip();

        if (routeData.length > 2)
        {
          _params = routeData[2 .. $].map!(d => d.strip()).array;
        }
      }
    }

    /**
    * Creates a new route.
    * Params:
    *   request = The request to create a route of.
    */
    this(HTTPServerRequest request)
    {
      enforce(request, "No request given.");

      this(request.path);
    }

    @property
    {
      /// Gets the name.
      string name() { return _name; }

      /// Gets the action.
      string action() { return _action; }

      /// Gets the parameters.
      string[] params() { return _params; }

      /// Gets a boolean determining whether the route has paramters or not.
      bool hasParams() { return _params && _params.length; }
    }

    package(diamond) void passDataToAction()
    {
      if (!hasParams)
      {
        _action = null;
        return;
      }

      _action = _params[0];
      
      if (_params.length > 1)
      {
        _params = _params[1 .. $];
      }
      else
      {
        _params = null;
      }
    }

    /**
    * Gets data from a specific parameter.
    * Params:
    *   index = The index to get data from.
    * Returns:
    *   The data of the parameter.
    */
    T getData(T)(size_t index)
    {
      enforce(hasParams, "No parameters specified.");
      enforce(index < _params.length, "Index out of bounds.");

      import std.conv : to;

      return to!T(_params[index]);
    }

    /// Converts the route to a string.
    override string toString()
    {
      return _raw;
    }
  }
}
