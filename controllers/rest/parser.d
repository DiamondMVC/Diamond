/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.rest.parser;

import diamond.core.apptype;

static if (isWeb)
{
  import std.string : strip;
  import std.array : array, split;
  import std.algorithm : filter, map;

  import diamond.controllers.rest.routetype;
  import diamond.controllers.rest.routedatatype;
  import diamond.controllers.rest.routepart;
  import diamond.errors;

  package (diamond.controllers):

  /**
  * Parses a special route.
  * Params:
  *   route = The route to parse.
  * Returns:
  *   The parts of the route.
  */
  RoutePart[] parseRoute(string route)
  {
    if (!route || !route.strip().length) return [];

    if (route[0] == '/')
    {
      route = route[1 .. $];
    }

    if (route[$-1] == '/')
    {
      route = route[0 .. $-1];
    }

    auto routeData = route
      .split("/")
      .map!(r => r.strip())
      .filter!(r => r.length)
      .array;

    RoutePart[] parts;

    foreach (i; 0 .. routeData.length)
    {
      auto data = routeData[i];
      auto part = new RoutePart;

      if (i == 0)
      {
        part.routeType = RouteType.action;
        part.identifier = data;
      }
      else if (data == "*")
      {
        part.routeType = RouteType.wildcard;
      }
      else if (data[0] == '{' && data[$-1] == '}')
      {
        auto typeData = data[1 .. $-1].split(":");

        part.type = cast(RouteDataType)typeData[0];

        if (typeData.length == 1)
        {
          part.routeType = RouteType.type;
        }
        else if (typeData.length == 2)
        {
          part.routeType = RouteType.typeIdentifier;
          part.identifier = typeData[1];
        }
        else
        {
          throw new RouteException("Invalid type identifier for route.");
        }
      }
      else
      {
        part.identifier = data;
        part.routeType = RouteType.identifier;
      }

      parts ~= part;
    }

    return parts;
  }
}
