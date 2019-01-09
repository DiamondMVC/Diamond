/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.extensions.extensionemitinfo;

import diamond.extensions.extensiontype;

/// Wrapper for extension emit information.
final class ExtensionEmitInfo
{
  private:
  /// The type of the extension.
  ExtensionType _type;

  /// The name of the extension.
  string _name;

  /// The name of the extension's module.
  string _moduleName;

  public:
  final:
  /**
  * Creates a new extension emit info.
  * Params:
  *   type =       The type of the extension.
  *   name =       The name of the extension.
  *   moduleName = The name of the extension's module.
  */
  this(ExtensionType type, string name, string moduleName)
  {
    _type = type;
    _name = name;
    _moduleName = moduleName;
  }

  @property
  {
    /// Gets the type of the extension.
    ExtensionType type() { return _type; }

    /// Gets the name of the extension.
    string name() { return _name; }

    /// Gets the name of the extension's module.
    string moduleName() { return _moduleName; }
  }
}
