/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.textarea;

import diamond.web.elements.input;

/// Wrapper around a textarea input.
final class TextArea : Input
{
  private:
  /// The associated form.
  string _form;
  /// The rows.
  size_t _rows;
  /// The columns.
  size_t _columns;

  public:
  final:
  /// Creates a new textarea input.
  this()
  {
    super("textarea");
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

    /// Gets the rows.
    size_t rows() { return _rows; }

    /// Sets the rows.
    void rows(size_t newRows)
    {
      _rows = newRows;
      addAttribute("rows", _rows);
    }

    /// Gets the columns.
    size_t columns() { return _columns; }

    /// Sets the columns.
    void columns(size_t newColumns)
    {
      _columns = newColumns;
      addAttribute("cols", _columns);
    }
  }

  protected:
  /// Generates the appropriate html for the element.
  override string generateHtml()
  {
    import std.string : format;

    return "%3$s<%1$s %2$s>%4$s</%1$s>".format
    (
      super.tagName, super.attributeHtml(),
      super.label && super.label.length && super.id && super.id.length ?
      "<label for=\"%s\">%s</label>".format(super.id, super.label) : "",
      super.value ? super.value : ""
    );
  }
}
