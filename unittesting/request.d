/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.unittesting.request;

import diamond.core.apptype;

static if (isWeb && isTesting)
{
  import std.conv : to;

  import vibe.d : HTTPClientRequest, HTTPClientResponse, requestHTTP, HTTPMethod, Json;

  public import diamond.http.method;
  public import diamond.http.status;

  /// Wrapper around a http unittet result.
  final class HttpUnitTestResult
  {
    private:
    /// The response.
    HTTPClientResponse _response;

    /// The body data.
    string _bodyData;

    /**
    * Creates a new http unittest result.
    * Params:
    *   response = The response.
    */
    this(HTTPClientResponse response)
    {
      _response = response;
    }

    public:
    final:
    @property
    {
      /// Gets the raw vibe.d response.
      HTTPClientResponse rawResponse() { return _response; }

      /// Gets the raw vibe.d response stream.
      auto responseStream() { return _response.bodyReader; }

      /// Gets the status code.
      HttpStatus statusCode() { return cast(HttpStatus)_response.statusCode; }

      /// Gets the content type.
      string contentType() { return _response.contentType; }

      /// Gets the json.
      auto json() { return _response.readJson(); }

      /// Gets the body data.
      auto bodyData()
      {
        import vibe.stream.operations : readAllUTF8;

        if (!_bodyData)
        {
          _bodyData = _response.bodyReader.readAllUTF8();
        }

        return _bodyData;
      }
    }

    /**
    * Gets a cookie.
    * Params:
    *   name =         The name of the cookie.
    *   defaultValue = The default value.
    * Returns:
    *   The value of the cookie if present, default value otherwise.
    */
    string getCookie(string name, lazy string defaultValue = null)
    {
      if (name !in _response.cookies)
      {
        return defaultValue;
      }

      return _response.cookies[name].value;
    }

    /**
    * Checks whether a cookie is present or not.
    * Params:
    *   name = The name of the cookie.
    * Returns:
    *   True if the cookie is present, false otherwise.
    */
    bool hasCookie(string name)
    {
      return cast(bool)(name in _response.cookies);
    }

    /**
    * Gets a header.
    * Params:
    *   name = The name of the header.
    *   defaultValue = The default value.
    * Returns:
    *   The value if present, default value otherwise.
    */
    string getHeader(string name, lazy string defaultValue)
    {
      return _response.headers.get(name, defaultValue);
    }

    /**
    * Checks whether a header is present or not.
    * Params:
    *   name = The name of the header.
    * Returns:
    *   True if the header is present, false otherwise.
    */
    bool hasHeader(string name)
    {
      return getHeader(name, null) !is null;
    }

    /// Gets a model from the response's json.
    T getModelFromJson(T, CTORARGS...)(CTORARGS args)
    {
      import vibe.data.json;

      static if (is(T == struct))
      {
        T value;

        value.deserializeJson(json);

        return value;
      }
      else static if (is(T == class))
      {
        auto value = new T(args);

        value.deserializeJson(json);

        return value;
      }
      else
      {
        static assert(0);
      }
    }
  }

  /**
  * Creates an internal test request.
  * Params:
  *   route =     The route (not URL!) to call.
  *   method =    The method to use for thr request.
  *   responder = The handler for the unittest result.
  *   requester = Custom handler for the raw vibe.d request. Can be used to setup the request data etc.
  */
  void testRequest
  (
    string route, HttpMethod method,
    scope void delegate(scope HttpUnitTestResult) responder,
    scope void delegate(scope HTTPClientRequest) requester = null,
  )
  {
    import diamond.errors.checks;

    enforce(responder !is null, "No responder defined.");

    import diamond.core.webconfig;
    auto address = webConfig.addresses[0];

    if (route[0] != '/')
    {
      route = "/" ~ route;
    }

    auto ipAddress = address.ipAddresses[0];

    if (ipAddress == "::1")
    {
      ipAddress = "127.0.0.1";
    }

    auto url = "http://" ~ ipAddress ~ ":" ~ to!string(address.port) ~ route;

    requestHTTP
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
  			responder(new HttpUnitTestResult(response));
  		}
  	);
  }
}
