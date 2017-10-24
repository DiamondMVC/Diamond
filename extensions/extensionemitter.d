/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.extensions.extensionemitter;

import diamond.extensions.extensiontype;

/// Mixin template to emit extensions.
mixin template ExtensionEmit(ExtensionType extensionType, string extensionHandler)
{
  /// The function that generates the emit result.
  private static string emitGenerate()
  {
    import diamond.extensions.extensionmanager;

    string emitResult = "";

    foreach (emitEntry; getExtensions(extensionType))
    {
      import std.string : format;
      import std.array : replace;

      static if (
        extensionType == ExtensionType.applicationStart ||
        extensionType == ExtensionType.customGrammar ||
        extensionType == ExtensionType.partParser ||
        extensionType == ExtensionType.httpSettings ||
        extensionType == ExtensionType.httpRequest ||
        extensionType == ExtensionType.handleError ||
        extensionType == ExtensionType.staticFileExtension
      )
      {
        emitResult ~= q{{
          import __extension_%s = %s;

          %s
        }}.format(emitEntry.name, emitEntry.moduleName,
          extensionHandler.replace("{{extensionEntry}}", "__extension_" ~ emitEntry.name));
      }
      else
      {
        emitResult ~= q{
          import __extension_%s = %s;

          %s
        }.format(emitEntry.name, emitEntry.moduleName,
          extensionHandler.replace("{{extensionEntry}}", "__extension_" ~ emitEntry.name));
      }
    }

    return emitResult;
  }

  static if (
    extensionType == ExtensionType.applicationStart ||
    extensionType == ExtensionType.customGrammar ||
    extensionType == ExtensionType.partParser ||
    extensionType == ExtensionType.httpSettings ||
    extensionType == ExtensionType.httpRequest ||
    extensionType == ExtensionType.handleError ||
    extensionType == ExtensionType.staticFileExtension
  )
  {
    /// The function that contains the generated extension call.
    void emitExtension()
    {
      mixin(emitGenerate());
    }
  }
  else
  {
    mixin(emitGenerate());
  }
}
