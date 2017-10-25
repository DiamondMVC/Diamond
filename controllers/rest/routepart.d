/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.rest.routepart;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.controllers.rest.routetype;
  import diamond.controllers.rest.routedatatype;

  package (diamond.controllers):

  /// A route part.
  final class RoutePart
  {
    package(diamond.controllers.rest)
    {
      /// The route type.
      RouteType _routeType;

      /// The identifier.
      string _identifier;

      /// The type.
      RouteDataType _type;

      /// Creates a new route part.
      final this() { }

      @property
      {
        /// Sets the route type.
        final void routeType(RouteType newRouteType)
        {
          _routeType = newRouteType;
        }

        /// Sets the identifier.
        final void identifier(string newIdentifier)
        {
          _identifier = newIdentifier;
        }

        /// Sets the type.
        final void type(RouteDataType newType)
        {
          _type = newType;
        }
      }
    }

    final:
    @property
    {
      /// Gets the route type.
      RouteType routeType() { return _routeType; }

      /// Gets the identifier.
      string identifier() { return _identifier; }

      /// Gets the type.
      RouteDataType type() { return _type; }
    }
  }
}
