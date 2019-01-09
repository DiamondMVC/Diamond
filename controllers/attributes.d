/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.attributes;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.http.method;

  /// Attribute for default http actions.
  struct HttpDefault {}

  /// Attribute for mandatory http actions.
  struct HttpMandatory {}

  /// Attribute for http actions.
  struct HttpAction
  {
    /// The http method of the action.
    HttpMethod method;

    /// The name of the action. Equivalent to /route/{action}
    string action;
  }

  /// Attribute for a no-action handler.
  struct HttpNoAction {}

  /// Attribute for authentication.
  struct HttpAuthentication
  {
    /// The class to use for authentcation. It must implement IControllerAuth.
    string authenticationClass;
  }

  /// Attribute for restricting controller actions to the restricted ips.
  struct HttpRestricted {}

  /// Attribute for disabling authentication.
  struct HttpDisableAuth { }

  /// Attribute for version-control.
  struct HttpVersion
  {
    /// The version name.
    string versionName;

    /// The controller to use for the version.
    string versionControllerClass;
  }

  static if (isWebApi)
  {
    /// Attribute for declaring routes.
    struct HttpRoutes
    {
      /// The routes.
      string[] routes;

      /**
      * Creates a new http routes attribute.
      * Params:
      *   route = The route.
      */
      this(string route)
      {
        routes = [route];
      }

      /**
      * Creates a new http routes attribute.
      * Params:
      *   routes = The routes.
      */
      this(string[] routes)
      {
        this.routes = routes;
      }

      /// Dsiabling the regular struct constructor.
      @disable this();
    }
  }

  /// Attribute for retrieving controller data from the form body.
  struct HttpForm { }

  /// Attribute for retrieving controller data from the query string.
  struct HttpQuery { }

  /// Attribute for sanitizing html tags from inputs by replacing them with their &gt; and &lt;
  struct HttpSanitize { }
}
