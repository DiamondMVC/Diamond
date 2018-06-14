/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.apptype;

public
{
  version (Diamond_WebSite)
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
    static const bool isWebServer = true;
    /// Boolean determining whether the application is compiled as a webapi or not.
    static const bool isWebApi = true;
  }

  /// Boolean determining whether the application is web related or not.
  static const bool isWeb = true;//isWebServer || isWebApi;

  version (Diamond_UnitTesting)
  {
    /// Boolean determining whether the application is running tests or not.
    static const bool isTesting = isWeb; // Testing can only be enabled for web applications.
  }
  else
  {
    /// Boolean determining whether the application is running tests or not.
    static const bool isTesting = false;
  }

  version (Diamond_Logging)
  {
    /// Boolean determining whether the application logs or not.
    static const bool loggingEnabled = isWeb; // Testing can only be enabled for web applications.
  }
  else
  {
    /// Boolean determining whether the application logs or not.
    static const bool loggingEnabled = false;
  }

  version (Diamond_CustomMain)
  {
    /// Boolean determining whether the application uses a custom main or not.
    static const bool isCustomMain = isWeb;
  }
  else
  {
    /// Boolean determining whether the application uses a custom main or not.
    static const bool isCustomMain = false;
  }

  version (Diamond_Debug)
  {
    /// Boolean determining whether application is being debugged or not.
    static const bool debugging = true;
  }
  else
  {
    /// Boolean determining whether application is being debugged or not.
    static const bool debugging = false;
  }
}
