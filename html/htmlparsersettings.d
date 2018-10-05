/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.html.htmlparsersettings;

import diamond.dom.domparsersettings;

/// Wrapper around html parser settings.
final class HtmlParserSettings : DomParserSettings
{
  public:
  final:
  /// Creates a new html parser settings:
  this() @safe
  {
    super(false, ["script", "pre", "code"]);
  }
}
