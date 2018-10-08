/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.client.envelopeparameter;

/// Wrapper around a soap envelope parameter.
final class SoapEnvelopeParameter
{
  private:
  /// The name.
  string _name;
  /// The value.
  string _value;

  public:
  final:
  /**
  * Creates a new soap envelope parameter.
  * Params:
  *   name = The name of the parameter.
  *   value = The value of the parameter.
  */
  this(string name, string value)
  {
    _name = name;
    _value = value;
  }

  @property
  {
    /// Gets the name.
    string name() { return _name; }

    /// Gets the value.
    string value() { return _value; }
  }
}
