/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamondapp;

import diamond.core : isWeb;

static if (isWeb)
{
  import diamond.core;
  import diamond.http;
  import diamond.errors;

  static if (isWebServer)
  {
    import diamond.views;
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
      import diamond.extensions;
      mixin ExtensionEmit!(ExtensionType.applicationStart, q{
        {{extensionEntry}}.onApplicationStart();
      });
      emitExtension();

      loadWebConfig();

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
      auto staticFile = _staticFiles.get(route.name, null);

      if (staticFile)
      {
        import diamond.extensions;
        mixin ExtensionEmit!(ExtensionType.staticFileExtension, q{
          if (!{{extensionEntry}}.handleStaticFile(request, response))
          {
            return;
          }
        });
        emitExtension();

        foreach (headerKey,headerValue; webConfig.defaultHeaders.staticFiles)
        {
          response.headers[headerKey] = headerValue;
        }

        import std.array : split, join;
        request.path = "/" ~ request.path.split("/")[2 .. $].join("/");

        if (webSettings)
        {
          webSettings.onStaticFile(request, response);
        }

        staticFile(request, response);
        return;
      }

      static if (isWebServer)
      {
        auto page = getView(request, response, route, true);

        if (!page)
        {
          throw new HTTPStatusException(HTTPStatus.NotFound);
        }

        foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
        {
          response.headers[headerKey] = headerValue;
        }

        auto pageResult = page.generate();

        if (pageResult && pageResult.length)
        {
          response.bodyWriter.write(pageResult);
        }
      }
      else
      {
        auto controllerAction = getControllerAction(route.name);

        if (!controllerAction)
        {
          throw new HTTPStatusException(HTTPStatus.NotFound);
        }

        auto status = controllerAction(request, response, route).handle();

        if (status == Status.notFound)
        {
          throw new HTTPStatusException(HTTPStatus.NotFound);
        }
        else if (status != Status.end)
        {
          foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
          {
            response.headers[headerKey] = headerValue;
          }
        }
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
      }
    }
  }
}
else
{
  import diamond.views;

  mixin GenerateViews;

  import std.array : join;
  mixin(generateViewsResult.join(""));

  mixin GenerateGetView;

  /// Shared static constructor for stand-alone applications.
  shared static this()
  {
    // ...
  }
}
