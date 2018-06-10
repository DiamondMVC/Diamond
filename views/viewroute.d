/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewroute;

import diamond.core.apptype;

static if (!isWebApi)
{
  /// Mixin template for generating the getView() function.
  mixin template GenerateGetView()
  {
    import diamond.core.apptype;
    import std.string : format;
    import diamondapp;

    static if (isWebServer)
    {
      import diamond.http;

      /**
      * Generates the getView() function.
      * Returns:
      *   The resulting string of the getView() function to use in a mixin.
      */
      string generateGetView()
      {
        string getViewMixin = "
          View getView(HttpClient client, Route route, bool checkRoute, bool keepRoute = false)
          {
            auto viewName =
              routableViews.get(route.name, checkRoute ? null : route.name);

            if (!viewName)
            {
              import diamond.http.routing;
              viewName = getViewNameFromRoute(route.name);
            }

            if (!viewName)
            {
              return null;
            }

            switch (viewName)
            {
        ";

        mixin LoadViewData!true;

        foreach (viewName; getViewData().keys)
        {
          getViewMixin ~= format(q{
            case "%s":
            {
              if (!keepRoute)
              {
                client.route = route;
              }

              return new view_%s(client, "%s");
            }
          }, viewName, viewName, viewName);
        }

        getViewMixin ~= "
              default: return null; // 404 ...
            }
          }
        ";

        return getViewMixin;
      }
    }
    else
    {
      /**
      * Generates the getView() function.
      * Returns:
      *   The resulting string of the getView() function to use in a mixin.
      */
      string generateGetView()
      {
        string getViewMixin = "
          View getView(string viewName)
          {
            if (!viewName || !viewName.length)
            {
              return null;
            }

            switch (viewName)
            {
        ";

        mixin LoadViewData!true;

        foreach (viewName; getViewData().keys)
        {
          getViewMixin ~= format(q{
            case "%s":
            {
              return new view_%s("%s");
            }
          }, viewName, viewName, viewName);
        }

        getViewMixin ~= "
              default: return null; // 404 ...
            }
          }
        ";

        return getViewMixin;
      }
    }

    mixin(generateGetView);
  }
}
