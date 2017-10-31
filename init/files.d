/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.files;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequestDelegateS;

  import diamond.http;

  /**
  * The handler for static file requests.
  * Params:
  *   client =     The client.
  *   staticFile =  The static file handler.
  */
  package(diamond.init) void handleStaticFiles
  (
    HttpClient client,
    HTTPServerRequestDelegateS staticFile
  )
  {
    import diamond.authentication;

    if (hasRoles && !hasAccess(client.role, client.method, client.route.toString()))
    {
      client.error(HttpStatus.unauthorized);
    }

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.staticFileExtension, q{
      if (!{{extensionEntry}}.handleStaticFile(client))
      {
        return;
      }
    });
    emitExtension();

    import diamond.core.webconfig;

    foreach (headerKey,headerValue; webConfig.defaultHeaders.staticFiles)
    {
      client.rawResponse.headers[headerKey] = headerValue;
    }

    import std.array : split, join;
    client.rawRequest.path = "/" ~ client.path.split("/")[2 .. $].join("/");

    import diamond.core.websettings;

    if (webSettings)
    {
      webSettings.onStaticFile(client);
    }

    staticFile(client.rawRequest, client.rawResponse);
  }
}
