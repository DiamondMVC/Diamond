/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.element;

import diamond.web.soap.soaptype;

package(diamond.web.soap):
/// Wrapper around a soap element.
final class SoapElement : SoapType
{
  private:
  /// The type.
  string _type;

  public:
  final:
  /**
  * Creates a new soap element.
  * Params:
  *   name = The name.
  *   type = The type.
  */
  this(string name, string type)
  {
    super(name);

    _type = type;
  }

  @property
  {
    /// Gets the type of the element.
    string type() { return _type; }
  }
}
