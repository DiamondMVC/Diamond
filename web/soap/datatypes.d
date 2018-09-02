/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.datatypes;

import std.datetime : DateTime;

public
{
  /// xsd.duration
  alias duration = string;
  /// xsd.dateTime
  alias dateTime = DateTime;
  /// xsd.time
  alias time = DateTime;
  /// xsd.data
  alias data = string;
  /// xsd.gYearMonth
  alias gYearMonth = string;
  /// xsd.gYear
  alias gYear = string;
  /// xsd.gMonthDay
  alias gMonthDay = string;
  /// xsd.gDay
  alias gDay = string;
  /// xsd.gMonth
  alias gMonth = string;
  /// xsd.Boolean
  alias Boolean = bool;
  /// xsd.base64Binary
  alias base64Binary = ubyte[];
  /// xsd.hexBinary
  alias hexBinary = string;
  /// xsd.decimal. TODO: switch to decimal type when implemented.
  alias decimal = real;
  /// xsd.anyURI
  alias anyURI = string;
  /// xsd.QName
  alias QName = string;
  /// xsd.NOTATION
  alias NOTATION = string;
  /// xsd.normalizedString
  alias normalizedString = string;
    /// xsd.token
    alias token = normalizedString;
      /// xsd.language
      alias language = token;
      /// xsd.name
      alias name = token;
        /// xsd.NCName
        alias NCName = name;
          /// xsd.ID
          alias ID = NCName;
          /// xsd.IDREF
          alias IDREF = NCName;
            /// xsd.IDREFS
            alias IDREFS = IDREF[];
          /// xsd.ENTITY
          alias ENTITY = NCName;
            /// xsd.ENTITIES
            alias ENTITIES = ENTITY[];
      /// xsd.NMTOKEN
      alias NMTOKEN = token;
        /// xsd.NMTOKENS
        alias NMTOKENS = NMTOKEN[];
  /// xsd.integer
  alias integer = size_t;
  /// xsd.nonPositiveInteger
  alias nonPositiveInteger = ptrdiff_t;
    /// xsd.negativeInteger
    alias negativeInteger = nonPositiveInteger;
  /// xsd.nonNegativeInteger
  alias nonNegativeInteger = size_t;
    /// xsd.positiveInteger
    alias positiveInteger = nonNegativeInteger;
    /// xsd.unsignedLong
    alias unsignedLong = ulong;
    /// xsd.unsignedInt
    alias unsignedInt = uint;
    /// xsd.unsignedShort
    alias unsignedShort = ushort;
    /// xsd.unsignedByte
    alias unsignedByte = ubyte;

  import diamond.web.soap.envelopetype;
  import diamond.web.soap.binding;
}
