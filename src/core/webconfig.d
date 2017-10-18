/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.webconfig;

import diamond.core.apptype;

static if (isWebApi)
{
  /**
  * Generates the controller data.
  * Returns:
  *   An array with the names of the controllers to handle.
  */
  string[] generateControllerData()
  {
    import std.array : replace, split, array;
    import std.string : strip;
    import std.algorithm : filter;

    return import("controllers.config")
      .replace("\r", "").split("\n").filter!(c => c && c.strip().length).array;
  }
}

static if (!isWebApi)
{
  /// Mixin template to load view data (name + content)
  mixin template LoadViewData(bool namesOnly = false)
  {
    /// Generates the functon "getViewData()" which gives you an AA like content[viewName]
    private string generateViewData()
    {
      import std.string : strip;
      import std.array : split, replace;

      enum viewConfig = import("views.config");

      string viewDataString = "string[string] getViewData()
      {
        string[string] viewData;
      ";

      foreach (line; viewConfig.split("\n"))
      {
        if (!line)
        {
          continue;
        }

        line = line.strip().replace("\r", "");

        if (!line && line.length)
        {
          continue;
        }

        auto data = line.split("|");

        if (data.length != 2)
        {
          continue;
        }

        static if (namesOnly)
        {
          auto viewName = data[0].strip();

          viewDataString ~= "  viewData[\"" ~ viewName ~ "\"] = \"" ~ viewName  ~ "\";";
        }
        else
        {
          viewDataString ~= "  viewData[\"" ~ data[0].strip() ~ "\"] = import(\"" ~ data[1].strip() ~ "\");";
        }
      }

      viewDataString ~= "  return viewData;
      }";

      return viewDataString;
    }

    mixin(generateViewData);
  }
}

static if (isWeb)
{
  /// Web configurations.
  class WebConfig
  {
    /// The name of the web application.
    string name;
    /// The routes that are mapped to static files.
    string[] staticFileRoutes;
    /// The route that's mapped to the home page.
    string homeRoute;
    /// Boolean determining whether views can be accessed by their file name.
    bool allowFileRoute;
    /// An array of addresses the web application is accessible by.
    WebAddress[] addresses;
    /// The default headers the web application uses.
    WebHeaders defaultHeaders;
    /// Boolean determining whether the access log should be redirected to the console.
    bool accessLogToConsole;
  }

  /// A web address.
  class WebAddress
  {
    /// An array of ip addresses that the web address is bound to.
    string[] ipAddresses;
    /// The port the web address is bound to.
    ushort port;
  }

  /// Web headers.
  class WebHeaders
  {
    /// Headers used for general purpose.
    string[string] general;
    /// Headers used for static files.
    string[string] staticFiles;
    /// Headers used for 404 responses.
    string[string] notFound;
    /// Headers used for error responses.
    string[string] error;
  }

  /// The web configuration.
  private static __gshared WebConfig _webConfig;

  /// Gets the web configuration.
  @property WebConfig webConfig() { return _webConfig; }

  /// Loads the web configuration.
  void loadWebConfig()
  {
    import vibe.d : deserializeJson;
    import std.file : readText;

    _webConfig = deserializeJson!WebConfig(readText("config/web.json"));
  }
}
