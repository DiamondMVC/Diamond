/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.files;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse,
                  HTTPStatusException, HTTPStatus,
                  HTTPServerRequestDelegateS;

  import diamond.http : Route;

  /**
  * The handler for static file requests.
  * Params:
  *   request =     The request.
  *   response =    The response.
  *   route =       The route.
  *   staticFile =  The static file handler.
  */
  package(diamond.init) void handleStaticFiles
  (
    HTTPServerRequest request, HTTPServerResponse response,
    Route route,
    HTTPServerRequestDelegateS staticFile
  )
  {
    import diamond.authentication;

    auto role = getRole(request);

    if (hasRoles && !hasAccess(role, request.method, route.toString()))
    {
      throw new HTTPStatusException(HTTPStatus.unauthorized);
    }

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.staticFileExtension, q{
      if (!{{extensionEntry}}.handleStaticFile(request, response))
      {
        return;
      }
    });
    emitExtension();

    import diamond.core.webconfig;

    foreach (headerKey,headerValue; webConfig.defaultHeaders.staticFiles)
    {
      response.headers[headerKey] = headerValue;
    }

    import std.array : split, join;
    request.path = "/" ~ request.path.split("/")[2 .. $].join("/");

    import diamond.core.websettings;

    if (webSettings)
    {
      webSettings.onStaticFile(request, response);
    }

    staticFile(request, response);
  }
}
