/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.complextype;

import diamond.web.soap.soaptype;
import diamond.web.soap.element;

package(diamond.web.soap):
/// Wrapper around a complex type.
final class SoapComplexType : SoapType
{
  private:
  /// The elements of the type.
  SoapElement[] _elements;

  public:
  final:
  /**
  * Creates a new complex type.
  * Params:
  *   name = The name of the complex type.
  */
  this(string name)
  {
    super(name);
  }

  @property
  {
    /// Gets the elements of the complex type.
    SoapElement[] elements() { return _elements; }
  }

  /**
  * Adds an element to the complex type.
  * Params:
  *   element = The element to add.
  */
  void addElement(SoapElement element)
  {
    _elements ~= element;
  }
}
