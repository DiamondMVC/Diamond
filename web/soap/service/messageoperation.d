/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.messageoperation;

import diamond.web.soap.service.parameter;

package(diamond.web.soap.service):
/// Wrapper around a soap message operation.
final class SoapMessageOperation
{
  private:
  string _action;
  string _name;
  string _returnType;
  string _parameters;

  public:
  final:
  /**
  * Creates a new soap message.
  * Params:
  *   action =     The action.
  *   name =       The name.
  *   returnType = The return type.
  *   parameters = The parameters.
  */
  this(string action, string name, string returnType, string parameters)
  {
    _action = action;
    _name = name;
    _returnType = returnType;
    _parameters = parameters;
  }

  @property
  {
    /// Gets the action.
    string action() { return _action; }

    /// Gets the name.
    string name() { return _name; }

    /// Gets the return type.
    string returnType() { return _returnType; }

    /// Gets the parameters.
    string parameters() { return _parameters; }
  }
}
