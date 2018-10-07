/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xml.xmlparsersettings;

import diamond.dom.domparsersettings;

/// Wrapper around xml parser settings.
final class XmlParserSettings : DomParserSettings
{
  public:
  final:
  /// Creates a new xml parser settings.
  this() @safe
  {
    // Xml is strict, has no flexible tags, allows no self-closing tags, has no standard tags and cannot be repaired.
    super(true, null, false, null, null, null, null);
  }
}
