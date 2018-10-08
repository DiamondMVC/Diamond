/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.soaptype;

package(diamond.web.soap.service):
/// Wrapper around a soap type.
abstract class SoapType
{
  private:
  /// The name.
  string _name;

  /**
  * Creates a new soap type.
  * Params:
  *   name = The name of the soap type.
  */
  protected this(string name)
  {
    _name = name;
  }

  public:
  final
  {
    /// Gets the name of the soap type.
    string name() { return _name; }
  }
}
