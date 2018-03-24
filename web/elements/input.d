/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.input;

import diamond.web.elements.element;

/// Wrapper around an input element.
abstract class Input : Element
{
  private:
  /// The value.
  string _value;
  /// The placeholder.
  string _placeholder;
  /// The label.
  string _label;

  public:
  final
  {
    /// Creates a new input element.
    this()
    {
      super("input");
    }

    package(diamond.web.elements) this(string tagName)
    {
      super(tagName);
    }

    @property
    {
      /// Gets the value.
      string value() { return _value; }

      /// Sets the value.
      void value(string newValue)
      {
        _value = newValue;

        addAttribute("value", _value);
      }

      /// Gets the placeholder.
      string placeholder() { return _placeholder; }

      /// Sets the placeholder.
      void placeholder(string newPlaceholder)
      {
        _placeholder = newPlaceholder;

        addAttribute("placeholder", _placeholder);
      }

      /// Gets the label.
      string label() { return _label; }

      /// Sets the label.
      void label(string newLabel)
      {
        _label = newLabel;
      }
    }
  }

  protected:
  /// Generates the appropriate html for the element.
  override string generateHtml()
  {
    import std.string : format;

    return "%3$s<%1$s %2$s>".format
    (
      super.tagName, super.attributeHtml(),
      _label && _label.length && super.id && super.id.length ?
      "<label for=\"%s\">%s</label>".format(super.id, _label) : ""
    );
  }
}
