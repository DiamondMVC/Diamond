/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.remote;

import vibe.d : HTTPClientRequest, HTTPClientResponse, requestHTTP, HTTPMethod;

import diamond.http.method;

/**
* Creates a remote request.
* Params:
*   url =       The url of the resource.
*   method =    The http method of the request.
*   responser = Handler for managing the response of the resource.
*   requester = Handler for setting up custom request configurations.
*/
void remoteRequest
(
  string url,
  HttpMethod method,
  scope void delegate(scope HTTPClientResponse) responder = null,
  scope void delegate(scope HTTPClientRequest) requester = null,
)
{
  return requestHTTP
  (
    url,
    (scope request)
    {
      request.method = cast(HTTPMethod)method;

      if (requester !is null)
      {
        requester(request);
      }
    },
    (scope response)
    {
      if (responder !is null)
      {
        responder(response);
      }
    }
  );
}

/**
* Creates a remote json request.
* Params:
*   url =       The url of the resource.
*   method =    The http method of the request.
*   responser = Handler for managing the json response.
*   requester = Handler for setting up custom request configurations.
*/
void remoteJson(T, CTORARGS...)
(
  string url,
  HttpMethod method,
  scope void delegate(T) responder = null,
  scope void delegate(scope HTTPClientRequest) requester = null,
)
{
  return fetchRemote
  (
    url, method,
    (scope response)
    {
      import vibe.data.json;

      static if (is(T == struct))
      {
        T value;

        value.deserializeJson(json);

        responder(value);
      }
      else static if (is(T == class))
      {
        auto value = new T(args);

        value.deserializeJson(json);

        responder(value);
      }
      else
      {
        static assert(0);
      }
    },
    requester
  );
}
