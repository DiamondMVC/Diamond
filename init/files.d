/**
* Copyright © DiamondMVC 2018
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

    version (VIBE_D_OLD)
    {
      client.path = "/" ~ client.path.split("/")[2 .. $].join("/");
    }
    else
    {
      client.path = "/" ~ client.path.split("/")[1 .. $].join("/");
    }

    import diamond.core.websettings;

    if (webSettings)
    {
      webSettings.onStaticFile(client);
    }

    staticFile(client.rawRequest, client.rawResponse);
  }
}
