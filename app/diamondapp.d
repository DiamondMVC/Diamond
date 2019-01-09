/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamondapp;

import diamond.core : isWeb;

public import diamond.app.web;

// static if (isWeb)
// {
//
// }
// else
// {
//   import diamond.views;
//
//   mixin GenerateViews;
//
//   static foreach (viewResult; generateViewsResult)
//   {
//     mixin("#line 1 \"view: " ~ viewResult.name ~ "\"\n" ~ viewResult.source);
//   }
//
//   mixin GenerateGetView;
//
//   /// Shared static constructor for stand-alone applications.
//   shared static this()
//   {
//     // ...
//   }
// }
