/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.app.web;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.core;
  import diamond.http;
  import diamond.errors;
  import diamond.authentication;
  import diamond.security;
  import diamond.unittesting;
  import diamond.app.appcache;

  static if (isWebServer)
  {
    public import diamond.views;
  }

  import vibe.d : HTTPServerRequestDelegateS, HTTPServerSettings, HTTPServerRequest,
                  HTTPServerResponse, HTTPServerErrorInfo, listenHTTP,
                  HTTPMethod, HTTPStatus, HTTPStatusException,
                  serveStaticFiles, URLRouter, runApplication,
                  TLSContextKind, createTLSContext;

  static if (!isCustomMain)
  {
    /// Entry point for the web application.
    private void main()
    {
      runDiamond();
    }
  }

  /// Initializes the Diamond run-time. This function does not initiate the server, tests, tasks, services etc.
  void initializeDiamond()
  {
    setAppCache(new DiamondAppCache);

    loadWebConfig();

    if (webConfig.webservices && webConfig.webservices.length)
    {
      bool missingSoapDefinitions;

      foreach (service; webConfig.webservices)
      {
        import std.file : exists;

        if (!exists("__services/" ~ service.name ~ ".d"))
        {
          missingSoapDefinitions = true;

          import diamond.web.soap;
          loadSoapDefinition(service.name, service.wsdl, service.moduleName);
        }
      }

      if (missingSoapDefinitions)
      {
        import diamond.io;
        print("Must recompile the project, because of missing soap definitions.");
      //  throw new InitializationError("Must recompile the project, because of missing soap definitions.");
      }
    }

    import diamond.data.mapping.engines.mysql : initializeMySql;
    initializeMySql();

    if (webConfig.mongoDb)
    {
      import diamond.database.mongo;
      initializeMongo(webConfig.mongoDb.host, webConfig.mongoDb.port);
    }

    static if (hasMsSql)
    {
      import diamond.data.mapping.engines.mssql : initializeMsSql;
      initializeMsSql();
    }

    setDetaulfPermissions();

    loadWhiteListPaths();

    import diamond.security.validation.sensitive;

    initializeSensitiveDataValidator();

    initializeAuth();
  }

  /// Runs the diamond application.
  private void runDiamond()
  {
    try
    {
      initializeDiamond();

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

      loadSpecializedRoutes();

      foreach (address; webConfig.addresses)
      {
        loadServer(address.ipAddresses, address.port);
      }

      print("The %s %s is now running.",
        isWebServer ? "web-server" : "web-api", webConfig.name);

      static if (isTesting)
      {
        import diamond.tasks;

        executeTask({ initializeTests(); });
      }

      executeBackup();

      runApplication();
    }
    catch (Throwable t)
    {
      handleUnhandledError(t);
      throw t;
    }
  }

  /// Sets the default permissions for each http method.
  private void setDetaulfPermissions()
  {
    defaultPermission = true;
    requirePermissionMethod(HttpMethod.GET, PermissionType.readAccess);
    requirePermissionMethod(HttpMethod.POST, PermissionType.writeAccess);
    requirePermissionMethod(HttpMethod.PUT, PermissionType.updateAccess);
    requirePermissionMethod(HttpMethod.DELETE, PermissionType.deleteAccess);
  }

  /// Loads the specialized routes.
  private void loadSpecializedRoutes()
  {
    if (webConfig.specializedRoutes)
    {
      foreach (key,route; webConfig.specializedRoutes)
      {
        switch (route.type)
        {
          case "external":
            addSpecializedRoute(SpecializedRouteType.external, key, route.value);
            break;

          case "internal":
            addSpecializedRoute(SpecializedRouteType.internal, key, route.value);
            break;

          case "local":
            addSpecializedRoute(SpecializedRouteType.local, key, route.value);
            break;

          default: break;
        }
      }
    }
  }

  static if (isWebServer)
  {
    mixin(generateGlobalView());

    mixin GenerateViews;

    static foreach (viewResult; generateViewsResult)
    {
      mixin("#line 1 \"view: " ~ viewResult.name ~ "\"\n" ~ viewResult.source);
    }

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
  /// Loads the white-list paths.
  void loadWhiteListPaths()
  {
    if (webConfig.whiteListPaths)
    {
      foreach (whiteListPath; webConfig.whiteListPaths)
      {
        import diamond.io.file : addPathToWhiteList;

        addPathToWhiteList(whiteListPath);
      }
    }
  }

  /// The static file handlers.
  __gshared HTTPServerRequestDelegateS[string] _staticFiles;

  /// Loads the static file handlers.
  void loadStaticFiles()
  {
    if (webConfig.staticFileRoutes && webConfig.staticFileRoutes.length)
    {
      foreach (staticFileRoute; webConfig.staticFileRoutes)
      {
        import std.algorithm : map, filter;
        import std.path : baseName;
        import std.file : dirEntries, SpanMode;

        auto directoryNames = dirEntries(staticFileRoute, SpanMode.shallow)
          .filter!(entry => !entry.isFile)
          .map!(entry => baseName(entry.name));

        foreach (directoryName; directoryNames)
        {
          _staticFiles[directoryName] = serveStaticFiles(staticFileRoute);
        }
      }
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

    if (webConfig.sslCertificateFile && webConfig.sslPrivateKeyFile)
    {
      if (port == 80)
      {
        loadServer(ipAddresses, 443);
      }
      else if (port == 443)
      {
        settings.tlsContext = createTLSContext(TLSContextKind.server);
        settings.tlsContext.useCertificateChainFile(webConfig.sslCertificateFile);
        settings.tlsContext.usePrivateKeyFile(webConfig.sslPrivateKeyFile);
      }
    }

    settings.port = port;
    settings.bindAddresses = ipAddresses;
    settings.accessLogToConsole = webConfig.accessLogToConsole;
    settings.maxRequestSize = webConfig.maxRequestSize ? webConfig.maxRequestSize : 4000000;
    settings.maxRequestHeaderSize = webConfig.maxRequestHeaderSize ? webConfig.maxRequestHeaderSize : 8192;
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
      {{extensionEntry}}.handleSettings(settings);
    });
    emitExtension();

    auto router = new URLRouter;

    handleWebSockets(router);

    if (port == 443)
    {
      router.any("*", &handleHTTPSListen);
    }
    else
    {
      router.any("*", &handleHTTPListen);
    }

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
    handleHTTPListenWorker(request, response, false);
  }

  /**
  * Handler for https requests.
  * Params:
  *   request =   The http request.
  *   response =  The http response.
  */
  void handleHTTPSListen(HTTPServerRequest request, HTTPServerResponse response)
  {
    handleHTTPListenWorker(request, response, true);
  }

  /**
  * Handler for http requests.
  * Params:
  *   request =   The http request.
  *   response =  The http response.
  */
  void handleHTTPListenWorker(HTTPServerRequest request, HTTPServerResponse response, bool isSSL)
  {
    auto client = new HttpClient(request, response);

    try
    {
      if (!isSSL && webConfig.forceSSLUrl && webConfig.forceSSLUrl.length)
      {
        client.redirect(webConfig.forceSSLUrl);
        return;
      }

      import std.algorithm : canFind;

      if (webConfig.hostWhiteList && !webConfig.hostWhiteList.canFind(client.host))
      {
        client.forbidden();
      }

      if (handleSpecializedRoute(client))
      {
        return;
      }

      static if (loggingEnabled)
      {
        import diamond.core.logging;
        executeLog(LogType.before, client);
      }

      static if (isTesting)
      {
        if (!testsPassed || client.ipAddress != "127.0.0.1")
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

      client.handlingRequest = true;

      auto routes = hasRoutes ?
        handleRoute(client.ipAddress == "127.0.0.1", client.path) :
        [client.path];

      if (!routes)
      {
        client.error(HttpStatus.unauthorized);
      }

      foreach (i; 0 .. routes.length)
      {
        auto route = routes[i];

        client.isLastRoute = i == (routes.length - 1);

        client.path = route[0] == '/' ? route : "/" ~ route;

        client.route = new Route(route);

        handleHTTPListenInternal(client);
      }
    }
    catch (HTTPStatusException hse)
    {
      auto e = cast(Exception)hse;

      if (e)
      {
        handleUserException(e,request,response,null);
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
    if (webConfig.authenticateStaticFiles)
    {
      handleHTTPPermissions(client);
    }

    if (_staticFiles)
    {
      auto staticFile = _staticFiles.get(client.route.name, null);

      if (staticFile)
      {
        import diamond.app.files;
        handleStaticFiles(client, staticFile);

        static if (loggingEnabled)
        {
          import diamond.core.logging;

          executeLog(LogType.staticFile, client);
        }
        return;
      }
    }

    if (!webConfig.authenticateStaticFiles)
    {
      handleHTTPPermissions(client);
    }

    static if (isWebServer)
    {
      import diamond.app.server;
      auto foundPage = client.forceApi ? false : handleWebServer(client);
    }
    else
    {
      auto foundPage = false;
    }

    static if (isWebApi)
    {
      if (!foundPage)
      {
        import diamond.app.api;
        handleWebApi(client);
      }
    }
    else
    {
      if (!foundPage)
      {
        client.notFound();
      }
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

void handleHTTPPermissions(HttpClient client)
{
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
}
