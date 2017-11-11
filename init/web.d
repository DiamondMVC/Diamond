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
  import diamond.unittesting;

  static if (isWebServer)
  {
    public import diamond.views;
  }

  import vibe.d : HTTPServerRequestDelegateS, HTTPServerSettings, HTTPServerRequest,
                  HTTPServerResponse, HTTPServerErrorInfo, listenHTTP,
                  HTTPMethod, HTTPStatus, HTTPStatusException,
                  serveStaticFiles, URLRouter;

  /// Entry point for the web application.
  shared static this()
  {
    try
    {
      loadWebConfig();

      defaultPermission = true;
      requirePermissionMethod(HttpMethod.GET, PermissionType.readAccess);
      requirePermissionMethod(HttpMethod.POST, PermissionType.writeAccess);
      requirePermissionMethod(HttpMethod.PUT, PermissionType.updateAccess);
      requirePermissionMethod(HttpMethod.DELETE, PermissionType.deleteAccess);

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

      static if (isTesting)
      {
        import vibe.core.core;

        runTask({ initializeTests(); });
      }
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

  static if (isWebApi)
  {
    import diamond.controllers;

    /// A compile-time constant of the controller data.
    private enum controllerData = generateControllerData();

    mixin GenerateControllers!(controllerData);
  }


  private:
  /// The static file handlers.
  __gshared HTTPServerRequestDelegateS[string] _staticFiles;

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

    auto router = new URLRouter;
    
    handleWebSockets(router);

    router.any("*", &handleHTTPListen);

    listenHTTP(settings, router);
  }

  /**
  * Handler for http requests.
  * Params:
  *   request =   The http request.
  *   response =  The http response.
  */
  void handleHTTPListen(HTTPServerRequest request, HTTPServerResponse response)
  {
    auto client = new HttpClient(request, response);

    try
    {
      auto routes = hasRoutes ?
        handleRoute(client.ipAddress == "127.0.0.1", request.path) :
        [request.path];

      if (!routes)
      {
        client.error(HttpStatus.unauthorized);
      }

      foreach (i; 0 .. routes.length)
      {
        auto route = routes[i];

        client.isLastRoute = i == (routes.length - 1);

        client.rawRequest.path = route[0] == '/' ? route : "/" ~ route;

        client.route = new Route(route);

        handleHTTPListenInternal(client);
      }
    }
    catch (Throwable t)
    {
      static if (loggingEnabled)
      {
        import diamond.core.logging;

        if (client.statusCode == HttpStatus.notFound)
        {
          executeLog(LogType.notFound, client);
        }
        else
        {
          executeLog(LogType.error, client, t.toString());
        }
      }

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

  /**
  * Internal handler for http clients.
  * Params:
  *   client = The client to handle.
  */
  private void handleHTTPListenInternal(HttpClient client)
  {
    static if (loggingEnabled)
    {
      import diamond.core.logging;
      executeLog(LogType.before, client);
    }

    static if (isTesting)
    {
      if (!testsPassed && client.ipAddress != "127.0.0.1")
      {
        client.error(HttpStatus.serviceUnavailable);
      }
    }

    validateGlobalRestrictedIPs(client);

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.httpRequest, q{
      if (!{{extensionEntry}}.handleRequest(client))
      {
        return;
      }
    });
    emitExtension();

    if (webSettings && !webSettings.onBeforeRequest(client))
    {
      client.error(HttpStatus.badRequest);
    }

    if (hasRoles)
    {
      import std.array : split;

      auto hasRootAccess = hasAccess(
        client.role, client.method,
        client.route.name.split(webConfig.specialRouteSplitter)[0]
      );

      if
      (
        !hasRootAccess ||
        (
          client.route.action &&
          !hasAccess(client.role, client.method, client.route.name ~ "/" ~ client.route.action)
        )
      )
      {
        client.error(HttpStatus.unauthorized);
      }
    }

    auto staticFile = _staticFiles.get(client.route.name, null);

    if (staticFile)
    {
      import diamond.init.files;
      handleStaticFiles(client, staticFile);

      static if (loggingEnabled)
      {
        import diamond.core.logging;

        executeLog(LogType.staticFile, client);
      }
      return;
    }

    static if (isWebServer)
    {
      import diamond.init.server;
      handleWebServer(client);
    }
    else
    {
      import diamond.init.api;
      handleWebApi(client);
    }

    if (webSettings)
    {
      webSettings.onAfterRequest(client);
    }

    static if (loggingEnabled)
    {
      import diamond.core.logging;
      executeLog(LogType.after, client);
    }
  }
}
