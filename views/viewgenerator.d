/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewgenerator;

import diamond.core.apptype;

static if (!isWebApi)
{
  /// Mixin template for the view generator.
  mixin template GenerateViews()
  {
    import diamond.core.webconfig;
    import diamond.views.viewparser;

    struct ViewResult
    {
      string name;
      string source;
    }

    /**
    * Generates the strings of the view classes to use with mixin.
    * Returns:
    *   An array consisting of the generated classes of the views.
    *   The first element of the array is the routable data.
    */
    private ViewResult[] generateViews()
    {
      ViewResult[] viewGenerations = [];

      string routableViewsMixin = "private static __gshared string[string] _routableViews;
      @property string[string] routableViews()
      {
        if (_routableViews) return _routableViews;
";

      mixin LoadViewData;

      foreach (viewName,viewContent; getViewData)
      {
        import diamond.templates.parser : parseTemplate;

        auto parts = parseTemplate(viewContent);

        string route;
        viewGenerations ~= ViewResult(viewName, parseViewParts(parts, viewName, route));

        if (route && route.length)
        {
          import std.string : format;
          routableViewsMixin ~= "_routableViews[\"%s\"] = \"%s\";".format(route, viewName);
        }
      }

      routableViewsMixin ~= "return _routableViews;
      }";

      return [ViewResult("__routes", routableViewsMixin)] ~ viewGenerations;
    }

    /// The result of the generated views.
    enum generateViewsResult = generateViews();
  }
}
