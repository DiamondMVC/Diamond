/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.extensions.extensionmanager;

import diamond.extensions.extensiontype;
import diamond.extensions.extensionemitinfo;

/**
* Gets extensions based on an extension type.
* Params:
*   extensionType = The type of the extensions to get.
* Returns:
*   An array of the extensions emit info.
*/
ExtensionEmitInfo[] getExtensions(ExtensionType extensionType)
{
  import std.string : strip;
  import std.array : replace, split, array;
  import std.algorithm : filter;

  import diamond.core.io : handleCTFEFile;

  ExtensionEmitInfo[] extensions;

  mixin handleCTFEFile!("extensions.config", q{
    auto lines = __fileResult.replace("\r", "").split("\n");

    foreach (line; lines)
    {
      if (!line || !line.strip().length)
      {
        continue;
      }

      auto data = line.split("|");

      if (data.length != 3)
      {
        continue;
      }

      extensions ~= new ExtensionEmitInfo(cast(ExtensionType)data[0], data[1], data[2]);
    }
  });
  handle();

  return extensions.filter!(e => e.type == extensionType).array;
}
