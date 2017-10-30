/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.init.api;

import diamond.core.apptype;

static if (isWebApi)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse,
                  HTTPStatusException, HTTPStatus;

  import diamond.http;

  /**
  * The handler for a webapi request.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   route =     The route.
  */
  void handleWebApi
  (
    HTTPServerRequest request, HTTPServerResponse response,
    Route route
  )
  {
    import diamond.init.web : getControllerAction;

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
      import diamond.core.webconfig;

      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        response.headers[headerKey] = headerValue;
      }
    }
  }
}
