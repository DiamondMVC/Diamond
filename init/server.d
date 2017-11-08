/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.server;

import diamond.core.apptype;

static if (isWebServer)
{
  import diamond.http;

  /**
  * The handler for a generic webserver request.
  * Params:
  *   client = The client.
  */
  void handleWebServer(HttpClient client)
  {
    import diamond.init.web : getView;

    auto page = getView(client, client.route, true);

    if (!page)
    {
      client.notFound();
    }

    import diamond.core.webconfig;

    string pageResult;

    if (webConfig.shouldCacheViews && page.cached)
    {
      pageResult = client.session.getCachedView(page.name);
    }

    import diamond.core.webconfig;

    foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
    {
      client.rawResponse.headers[headerKey] = headerValue;
    }

    if (!pageResult)
    {
      pageResult = page.generate();

      if (client.redirected || !client.isLastRoute)
      {
        return;
      }

      if (webConfig.shouldCacheViews && pageResult && pageResult.length && page.cached)
      {
        client.session.cacheView(page.name, pageResult);
      }
    }

    if (pageResult && pageResult.length)
    {
      client.write(pageResult);
    }
    else
    {
      client.write("\n");
    }
  }
}
