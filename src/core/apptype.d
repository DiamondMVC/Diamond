/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.apptype;

public
{
  version (Diamond_WebServer)
  {
    /// Boolean determining whether the application is compiled as a webserver or not.
    static const bool isWebServer = true;
    /// Boolean determining whether the application is compiled as a webapi or not.
    static const bool isWebApi = false;
  }
  else version (Diamond_WebApi)
  {
    /// Boolean determining whether the application is compiled as a webserver or not.
    static const bool isWebServer = false;
    /// Boolean determining whether the application is compiled as a webapi or not.
    static const bool isWebApi = true;
  }
  else
  {
    /// Boolean determining whether the application is compiled as a webserver or not.
    static const bool isWebServer = false;
    /// Boolean determining whether the application is compiled as a webapi or not.
    static const bool isWebApi = false;
  }

  /// Boolean determining whether the application is web related or not.
  static const bool isWeb = isWebServer || isWebApi;
}
