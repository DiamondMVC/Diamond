/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.aliastype;

import diamond.web.soap.service.soaptype;
import diamond.web.soap.service.element;

package(diamond.web.soap):
/// Wrapper around an alias type.
final class SoapAliasType : SoapType
{
  private:
  string _aliasName;

  public:
  final:
  /**
  * Creates a new alias type.
  * Params:
  *   name =      The name of the complex type.
  *   aliasType = The alias type.
  */
  this(string name, string aliasType)
  {
    super(name);

    _aliasName = aliasType;
  }

  @property
  {
    /// Gets the alias name of the type.
    string aliasName() { return _aliasName; }
  }
}
