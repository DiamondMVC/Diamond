/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.server;

import diamond.core.apptype;

static if (isWebServer)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse,
                  HTTPStatusException, HTTPStatus;

  import diamond.http;

  /**
  * The handler for a generic webserver request.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   route =     The route.
  */
  void handleWebServer
  (
    HTTPServerRequest request, HTTPServerResponse response,
    Route route
  )
  {
    import diamond.init.web : getView;

    auto page = getView(request, response, route, true);

    if (!page)
    {
      throw new HTTPStatusException(HTTPStatus.notFound);
    }

    import diamond.core.webconfig;

    string pageResult;

    if (webConfig.shouldCacheViews && page.cached)
    {
      pageResult = getCachedViewFromSession(request, response, page.name);
    }

    import diamond.core.webconfig;

    foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
    {
      response.headers[headerKey] = headerValue;
    }

    if (!pageResult)
    {
      pageResult = page.generate();

      if (pageResult && pageResult.length && webConfig.shouldCacheViews && page.cached)
      {
        cacheViewInSession(request, response, page.name, pageResult);
      }
    }

    if (pageResult && pageResult.length)
    {
      response.bodyWriter.write(pageResult);
    }
    else
    {
      response.bodyWriter.write("\n");
    }
  }
}
