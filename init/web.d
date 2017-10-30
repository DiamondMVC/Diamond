/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.web;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.core;
  import diamond.http;
  import diamond.errors;
  import diamond.authentication;
  import diamond.security;

  static if (isWebServer)
  {
    public import diamond.views;
  }

  import vibe.d : HTTPServerRequestDelegateS, HTTPServerSettings, HTTPServerRequest,
                  HTTPServerResponse, HTTPServerErrorInfo, listenHTTP,
                  HTTPStatusException, HTTPStatus,
                  HTTPMethod,
                  serveStaticFiles;

  /// Entry point for the web application.
  shared static this()
  {
    try
    {
      loadWebConfig();

      defaultPermission = true;
      requirePermissionMethod(HTTPMethod.GET, PermissionType.readAccess);
      requirePermissionMethod(HTTPMethod.POST, PermissionType.writeAccess);
      requirePermissionMethod(HTTPMethod.PUT, PermissionType.updateAccess);
      requirePermissionMethod(HTTPMethod.DELETE, PermissionType.deleteAccess);

      import diamond.extensions;
      mixin ExtensionEmit!(ExtensionType.applicationStart, q{
        {{extensionEntry}}.onApplicationStart();
      });
      emitExtension();

      import websettings;
      initializeWebSettings();

      if (webSettings)
      {
        webSettings.onApplicationStart();
      }

      loadStaticFiles();

      foreach (address; webConfig.addresses)
      {
        loadServer(address.ipAddresses, address.port);
      }

      print("The %s %s is now running.",
        isWebServer ? "web-server" : "web-api", webConfig.name);
    }
    catch (Throwable t)
    {
      handleUnhandledError(t);
      throw t;
    }
  }

  static if (isWebServer)
  {
    mixin GenerateViews;

    import std.array : join;
    mixin(generateViewsResult.join(""));

    mixin GenerateGetView;
  }

  private:
  /// The static file handlers.
  __gshared HTTPServerRequestDelegateS[string] _staticFiles;

  static if (isWebApi)
  {
    import diamond.controllers;

    /// A compile-time constant of the controller data.
    private enum controllerData = generateControllerData();

    mixin GenerateControllers!(controllerData);
  }

  /// Loads the static file handlers.
  void loadStaticFiles()
  {
    foreach (staticFileRoute; webConfig.staticFileRoutes)
    {
      _staticFiles[staticFileRoute] = serveStaticFiles(staticFileRoute);
    }
  }

  /**
  * Loads the server with a specific range of ip addresses and the specified port.
  * Params:
  *   ipAddresses = The range of ip addresses to bind the server to.
  *   port =        The port to bind the server to.
  */
  void loadServer(string[] ipAddresses, ushort port)
  {
    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = ipAddresses;
    settings.accessLogToConsole = webConfig.accessLogToConsole;
    settings.errorPageHandler = (HTTPServerRequest request, HTTPServerResponse response, HTTPServerErrorInfo error)
    {
      import diamond.extensions;
      mixin ExtensionEmit!(ExtensionType.handleError, q{
        if (!{{extensionEntry}}.handleError(request, response, error))
        {
          return;
        }
      });
      emitExtension();

      auto e = cast(Exception)error.exception;

      if (e)
      {
        handleUserException(e,request,response,error);
      }
      else
      {
        handleUserError(error.exception,request,response,error);

        if (error.exception)
        {
          throw error.exception;
        }
      }
    };

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.httpSettings, q{
      {{extensionEntry}}.handleSettings(setting);
    });
    emitExtension();

    listenHTTP(settings, &handleHTTPListen);
  }

  /**
  * Handler for http requests.
  * Params:
  *   request =   The http request.
  *   response =  The http response.
  */
  void handleHTTPListen(HTTPServerRequest request, HTTPServerResponse response)
  {
    try
    {
      validateGlobalRestrictedIPs(request);

      createSession(request, response);

      import diamond.extensions;
      mixin ExtensionEmit!(ExtensionType.httpRequest, q{
        if (!{{extensionEntry}}.handleRequest(request, response))
        {
          return;
        }
      });
      emitExtension();

      if (webSettings && !webSettings.onBeforeRequest(request, response))
      {
        throw new HTTPStatusException(HTTPStatus.badRequest);
      }

      auto route = new Route(request);

      if (hasRoles)
      {
        validateAuthentication(request, response);

        auto role = getRole(request);

        import std.array : split;

        auto hasRootAccess = hasAccess(role, request.method, route.name.split(webConfig.specialRouteSplitter)[0]);

        if
        (
          !hasRootAccess ||
          (
            route.action &&
            !hasAccess(role, request.method, route.name ~ "/" ~ route.action)
          )
        )
        {
          throw new HTTPStatusException(HTTPStatus.unauthorized);
        }
      }

      auto staticFile = _staticFiles.get(route.name, null);

      if (staticFile)
      {
        import diamond.init.files;
        handleStaticFiles(request, response, route, staticFile);
        return;
      }

      static if (isWebServer)
      {
        import diamond.init.server;
        handleWebServer(request, response, route);
      }
      else
      {
        import diamond.init.api;
        handleWebApi(request, response, route);
      }

      if (webSettings)
      {
        webSettings.onAfterRequest(request, response);
      }
    }
    catch (Throwable t)
    {
      auto e = cast(Exception)t;

      if (e)
      {
        handleUserException(e,request,response,null);
      }
      else
      {
        handleUserError(t,request,response,null);
        throw t;
      }
    }
  }
}
