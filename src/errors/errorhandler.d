/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.errorhandler;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerErrorInfo,
                  HTTPStatus, HTTPStatusException;

  import diamond.core.io;
  import diamond.core.webconfig;
  import diamond.core.websettings;

  /**
  * Handles user exceptions.
  * Params:
  *   e =         The exception, if any.
  *   request =   The request.
  *   response =  The response.
  *   error =     The error information, if any.
  */
  void handleUserException(Exception e, HTTPServerRequest request,
    HTTPServerResponse response, HTTPServerErrorInfo error)
  {
    try
    {
      response.statusCode = error ? error.code : 500;
      auto httpStatusExcepton = cast(HTTPStatusException)e;

      if ((!httpStatusExcepton || httpStatusExcepton.status != HTTPStatus.NotFound) &&
        (response.statusCode != 404 && response.statusCode != 200)
        )
      {
        // log ...
      }

      if (httpStatusExcepton && httpStatusExcepton.status == HTTPStatus.NotFound)
      {
        response.statusCode = 404;

        foreach (headerKey,headerValue; webConfig.defaultHeaders.notFound)
        {
          response.headers[headerKey] = headerValue;
        }

        if (webSettings)
        {
          webSettings.onNotFound(request,response);
        }
        else
        {
          response.bodyWriter.write("Not found ...");
        }
        return;
      }

      foreach (headerKey,headerValue; webConfig.defaultHeaders.error)
      {
        response.headers[headerKey] = headerValue;
      }

      if (webSettings)
      {
        webSettings.onHttpError(e,request,response,error);
      }
      else
      {
        response.bodyWriter.write(e.toString);
      }
    }
    catch (Throwable) {}
  }

  /**
  * Handles unhandled exceptions.
  * Params:
  *   e = The unhandled exception.
  */
  void handleUnhandledException(Exception e)
  {
    print("unhandledException: %s", e);
  }

  /**
  * Handles user errors.
  * Params:
  *   t =         The throwable error, if any.
  *   request =   The request.
  *   response =  The response.
  *   error =     The error information, if any.
  */
  void handleUserError(Throwable t, HTTPServerRequest request, HTTPServerResponse response, HTTPServerErrorInfo error)
  {
    try
    {
      response.statusCode = error ? error.code : 500;

      if (error && error.code == 404)
      {
        response.statusCode = 404;

        foreach (headerKey,headerValue; webConfig.defaultHeaders.notFound)
        {
          response.headers[headerKey] = headerValue;
        }

        if (webSettings)
        {
          webSettings.onNotFound(request,response);
        }
        else
        {
          response.bodyWriter.write("Not found ...");
        }
        return;
      }

      foreach (headerKey,headerValue; webConfig.defaultHeaders.error)
      {
        response.headers[headerKey] = headerValue;
      }

      if (response.statusCode != 404 && response.statusCode != 200)
      {
        // log ...
      }

      if (webSettings)
      {
        webSettings.onHttpError(t,request,response,error);
      }
      else
      {
        response.bodyWriter.write(t.toString);
      }
    }
    catch (Throwable) {}
  }

  /**
  * Handles unhandled errors.
  * Params:
  *   t = The unhandled throwable error.
  */
  void handleUnhandledError(Throwable t)
  {
      print("unhandledError: %s", t);
  }
}
