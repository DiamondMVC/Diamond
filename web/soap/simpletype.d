/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.simpletype;

import diamond.web.soap.soaptype;

package(diamond.web.soap):
/// Enumeration of simple type definitions.
enum SoapSimpleTypeDefinition
{
  /// A restricted simple type.
  restriction,
  /// A list.
  list
}

/// Wrapper around a simple type.
final class SoapSimpleType : SoapType
{
  private:
  /// The type name.
  string _typeName;
  /// The definition.
  SoapSimpleTypeDefinition _definition;

  public:
  final:
  /**
  * Creates a new simple type.
  * Params:
  *   name =       The name.
  *   typeName =   The type name.
  *   definition = The definition.
  */
  this(string name, string typeName, SoapSimpleTypeDefinition definition)
  {
    super(name);

    _typeName = typeName;
    _definition = definition;
  }

  @property
  {
    /// Gets the type name.
    string typeName() { return _typeName; }

    /// Gets the definition.
    SoapSimpleTypeDefinition definition() { return _definition; }
  }
}
