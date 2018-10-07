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
    super
    (
      false, // Html is not strict
      // Tags that can contain flexible content.
      ["script", "pre", "code", "style", "svg"],
      // Html allows self-closing tags.
      true,
      // Tags that are self-closing.
      [
        "area", "base", "br", "col", "embed",
        "hr", "img", "input", "keygen", "link",
        "meta", "param", "source", "track", "wbr"
      ],
      // Standard tags are tags that aren't self-closing
      [
        // Main root tags
        "doctype", "html",
        // Sectioning root tags
        "head", "body",
        // Document metadata tags
        "title",
        // Content sectioning
        "address", "article", "aside",
        "footer", "header",
        "h1", "h2", "h3", "h4", "h5", "h6",
        "hgroup",
        "main", "nav", "section",
        // Text content
        "blockquote",
        "dd", "dir", "div", "dl", "dt",
        "figcaption", "figure",
        "hr",
        "li", "ol", "ul",
        "p",
        // Inline text semantics
        "a",
        "abbr",
        "b",
        "bdo", "bdo",
        "br",
        "cite",
        "data",
        "dfn",
        "em", "i",
        "kbd",
        "mark", "q",
        "rn", "rp", "rt", "rtc",
        "ruby",
        "s",
        "samp", "small", "span",
        "strong", "sub", "sup",
        "time", "tt",
        "u",
        "var",
        // Image and multimedia
        "audio", "map", "video",
        // Embedded content
        "applet", "iframe",
        "noembed", "object",
        "picture",
        // Scripting
        "canvas",
        // Demarcating edits
        "del", "ins",
        // Table content
        "caption",
        "col", "colgroup",
        "table",
        "tbody", "td",
        "tfoot",
        "th", "thead",
        "tr",
        // Forms,
        "button", "datalist", "fieldset",
        "form", "label", "legend",
        "meter", "optgroup",
        "option",
        "output",
        "progress",
        "select",
        "textarea",
        // Interactive elements,
        "details", "dialog",
        "menu", "menuitem", "summary",
        // Web Components
        "content", "element", "shadow", "slot", "template"
      ]
    );
  }
}
