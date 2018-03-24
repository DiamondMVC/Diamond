/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.button;

import diamond.web.elements.input;

/// Wrapper around a button element.
final class Button : Input
{
  public:
  final:
  /// Creates a new button element.
  this()
  {
    super("button");
  }

  @property
  {
    /// Gets the text.
    string text() { return super.inner; }

    /// Sets the text.
    void text(string newText)
    {
      super.inner = newText;
    }
  }

  protected:
  /// Generates the appropriate html for the element.
  override string generateHtml()
  {
    import std.string : format;

    return "<%1$s %2$s>%3$s</%1$s>".format(super.tagName, super.attributeHtml(), text ? text : "");
  }
}
