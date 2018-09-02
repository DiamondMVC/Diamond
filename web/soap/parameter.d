/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parameter;

package(diamond.web.soap):
/// Wrapper around a soap parameter.
final class SoapParameter
{
  private:
  /// The name.
  string _name;
  /// The type.
  string _type;

  public:
  final:
  /**
  * Creates a new soap parameter.
  * Params:
  *   name = The name.
  *   type = The type.
  */
  this(string name, string type)
  {
    _name = name;
    _type = type;
  }

  @property
  {
    /// Gets the name.
    string name() { return _name; }

    /// Gets the type.
    string type() { return _type; }
  }
}
