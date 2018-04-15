/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamondapp;

import diamond.core : isWeb;

static if (isWeb)
{
  public import diamond.init.web;
}
else
{
  import diamond.views;

  mixin GenerateViews;

  static foreach (viewResult; generateViewsResult)
  {
    mixin("#line 1 \"view: " ~ viewResult.name ~ "\"\n" ~ viewResult.source);
  }

  mixin GenerateGetView;

  /// Shared static constructor for stand-alone applications.
  shared static this()
  {
    // ...
  }
}
