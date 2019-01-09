/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.rest.routedatatype;

import diamond.core.apptype;

static if (isWeb)
{
  package (diamond.controllers):

  /// Enumeration of route data types.
  enum RouteDataType : string
  {
    /// A signed 8 bit integer.
    int8 = "byte",

    /// A signed 16 bit integer.
    int16 = "short",

    /// A signed 32 bit integer.
    int32 = "int",

    /// A signed 64 bit integer.
    int64 = "long",

    /// An unsigned 8 bit integer.
    uint8 = "ubyte",

    /// An unsigned 16 bit integer.
    uint16 = "ushort",

    /// An unsigned 32 bit integer.
    uint32 = "uint",

    /// An unsigned 64 bit integer.
    uint64 = "ulong",

    /// A string.
    stringType = "string",

    /// A boolean.
    boolean = "bool"
  }
}
