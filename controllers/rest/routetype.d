/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.rest.routetype;

import diamond.core.apptype;

static if (isWeb)
{
  package (diamond.controllers):

  /// Enumeration of route types.
  enum RouteType
  {
    /// An action identifier.
    action,

    /// An identifier.
    identifier,

    /// A type.
    type,

    /// A type identifier.
    typeIdentifier,

    /// A wildcard.
    wildcard
  }
}
