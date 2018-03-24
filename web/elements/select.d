/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.select;

import diamond.web.elements.input;

/// Wrapper around a select input.
final class Select : Input
{
  private:
  /// The associated form.
  string _form;

  /// The options.
  string[string] _options;

  public:
  final:
  /// Creates a new select input.
  this()
  {
    super("select");
  }

  @property
  {
    /// Gets the form.
    string form() { return _form; }

    /// Sets the form.
    void form(string newForm)
    {
      _form = newForm;

      addAttribute("form", _form);
    }
  }

  /**
  * Adds an option.
  * Params:
  *   value = The value of the option.
  *   text =  The text of the option.
  */
  void addOption(string value, string text)
  {
    _options[value] = text;
  }

  /**
  * Gets an option.
  * Params:
  *   value = The value of the option.
  * Returns:
  *   The text of the option if found, null otherwise.
  */
  string getOption(string value)
  {
    return _options.get(value, null);
  }

  /**
  * Removes an option.
  * Params:
  *   value = The value of the option to remove.
  */
  void removeOption(string value)
  {
    _options.remove(value);
  }

  protected:
  /// Generates the appropriate html for the element.
  override string generateHtml()
  {
    import std.string : format;
    import std.array : join;

    string[] options;

    foreach (value,text; _options)
    {
      options ~= "<option value=\"%s\">%s</option>".format(value,text);
    }

    auto optionsHtml = options ? options.join("\n") : "";

    return "%3$s<%1$s %2$s>%4$s</%1$s>".format
    (
      super.tagName, super.attributeHtml(),
      super.label && super.label.length && super.id && super.id.length ?
      "<label for=\"%s\">%s</label>".format(super.id, super.label) : "",
      optionsHtml
    );
  }
}
