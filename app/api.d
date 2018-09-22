/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.app.api;

import diamond.core.apptype;

static if (isWebApi)
{
  import diamond.http;

  /**
  * The handler for a webapi request.
  * Params:
  *   client = The client.
  */
  void handleWebApi(HttpClient client)
  {
    import diamond.init.web : getControllerAction;

    auto controllerAction = getControllerAction(client.route.name);

    if (!controllerAction)
    {
      client.notFound();
    }

    import diamond.controllers.status;

    auto status = controllerAction(client).handle();

    if (status == Status.notFound)
    {
      client.notFound();
    }
    else if (status != Status.end)
    {
      import diamond.core.webconfig;

      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        client.rawResponse.headers[headerKey] = headerValue;
      }
    }
  }
}
