/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.route;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest;

  import diamond.errors : enforce;

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
    this(string url)
    {
      enforce(url && url.length, "Invalid route url.");

      import std.string : strip, toLower;

      url = url.strip();
      _raw = url;

      if (url == "/")
      {
        import diamond.core : webConfig;

        _name = webConfig.homeRoute.toLower();
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

      _name = routeData[0].strip().toLower();

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
