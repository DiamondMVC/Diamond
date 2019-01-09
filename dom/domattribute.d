/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.dom.domattribute;

import std.string : strip, toLower;

import diamond.errors.checks;

/// A dom attribute.
final class DomAttribute
{
  private:
  /// The name of the attribute.
  string _name;
  /// The value of the attribute.
  string _value;

  public:
  /**
  * Creates a new dom attribute.
  * Params:
  *   name = The name.
  *   value = The value.
  */
  this(string name, string value) @safe
  {
    enforce(name !is null, "The name cannot be null.");

    _name = name.strip().toLower();
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

      _name = newName.strip().toLower();
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
