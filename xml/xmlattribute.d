/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xml.xmlattribute;

import std.string : strip;

import diamond.errors.checks;

/// An XML attribute.
final class XmlAttribute
{
  private:
  /// The name of the attribute.
  string _name;
  /// The value of the attribute.
  string _value;

  public:
  /**
  * Creates a new xml attribute.
  * Params:
  *   name = The name.
  *   value = The value.
  */
  this(string name, string value) @safe
  {
    enforce(name !is null, "The name cannot be null.");

    _name = name.strip();
    _value = value ? value.strip() : null;
  }

  @property
  {
    /// Gets the name of the attribute.
    string name() @safe { return _name; }

    /// Sets the name of the attribute.
    void name(string newName) @safe
    {
      enforce(name !is null, "The name cannot be null.");

      _name = newName.strip();
    }

    /// Gets the value of the attribute.
    string value() @safe { return _value; }

    /// Sets the value of the attribute.
    void value(string newValue) @safe
    {
      _value = newValue ? newValue.strip() : null;
    }
  }
}
