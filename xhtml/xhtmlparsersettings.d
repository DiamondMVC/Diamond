/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xhtml.xhtmlparsersettings;

import diamond.dom.domparsersettings;

/// Wrapper around xhtml parser settings.
final class XHtmlParserSettings : DomParserSettings
{
  public:
  final:
  /// Creates a new xhtml parser settings:
  this() @safe
  {
    super
    (
      false, // XHtml is not strict
      // Tags that can contain flexible content.
      ["script", "pre", "code", "style"],
      // XHtml does not allow self-closing tags.
      false,
      // XHtml has no self-closing tags.
      null,
      // Standard tags are not relevant without self-closing tags.
      null,
      // XHtml documents cannot be repaired.
      null, null
    );
  }
}
