/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.client;

import diamond.core.apptype;

static if (isWeb)
{
  /// Wrapper around the client's request aand response.
  final class HttpClient
  {
    import std.conv : to;

    import vibe.d : HTTPServerRequest, HTTPServerResponse,
                    HTTPStatusException;

    import diamond.authentication;
    import diamond.http.sessions;
    import diamond.http.cookies;
    import diamond.http.method;
    import diamond.http.status;
    import diamond.http.route;
    import diamond.errors.checks;

    private:
    /// The request.
    HTTPServerRequest _request;

    /// The response.
    HTTPServerResponse _response;

    /// The session.
    HttpSession _session;

    /// The cookies.
    HttpCookies _cookies;

    /// The route.
    Route _route;

    /// The role.
    Role _role;

    /// The ip address.
    string _ipAddress;

    /// Boolean determnining whether the client has been redirected or not.
    bool _redirected;

    final:
    package(diamond)
    {
      /**
      * Createsa  new http client.
      * Params:
      *   request =   The request.
      *   response =  The response.
      *   route =     The route.
      */
      this(HTTPServerRequest request, HTTPServerResponse response, Route route)
      {
        _request = enforceInput(request, "Cannot create a client without a request.");
        _response = enforceInput(response, "Cannot create a client without a response.");
        _route = enforceInput(route, "Cannot create a client without a route.");

        addContext("__D_RAW_HTTP_CLIENT", this);
      }
    }

    public:
    @property
    {
      /// Gets the raw vibe.d request.
      HTTPServerRequest rawRequest() { return _request; }

      /// Gets the raw vibe.d response.
      HTTPServerResponse rawResponse() { return _response; }

      /// Gets the route.
      Route route() { return _route; }

      /// Sets the route.
      package(diamond) void route(Route newRoute)
      {
        _route = newRoute;
      }

      /// Gets the method.
      HttpMethod method() { return cast(HttpMethod)_request.method; }

      /// Gets the session.
      HttpSession session()
      {
        if (_session)
        {
          return _session;
        }

        _session = getSession(this);

        return _session;
      }

      /// Gets the cookies.
      HttpCookies cookies()
      {
        if (_cookies)
        {
          return _cookies;
        }

        _cookies = new HttpCookies(this);

        return _cookies;
      }

      /// Gets the ip address.
      string ipAddress()
      {
        if (_ipAddress)
        {
          return _ipAddress;
        }

        _ipAddress = _request.clientAddress.toAddressString();

        return _ipAddress;
      }

      /// Gets the raw request stream.
      auto requestStream() { return _request.bodyReader; }

      /// Gets the raw response stream.
      auto responseStream() { return _response.bodyWriter; }

      /// Gets a boolean determnining whether the response is connected or not.
      bool connected() { return _response.connected; }

      /// Gets the raw path. Recommended to use the "route" property instead.
      string path() { return _request.path; }

      /// Gets the query string.
      string queryString() { return _request.queryString; }

      /// Gets a mapped query of the query string.
      auto query() { return _request.query; }

      /// Gets the generic http parameters.
      auto httpParams() { return _request.params; }

      /// Gets the files from the request.
      auto files() { return _request.files; }

      /// Gets the form from the request.
      auto form() { return _request.form; }

      /// Gets the full url from the request.
      auto fullUrl() { return _request.fullURL; }

      /// Gets the json from the request.
      auto json() { return _request.json; }

      /// Gets the content type from the request.
      string contentType() { return _request.contentType; }

      /// Gets the content type parameters from the request.
      string contentTypeParameters() { return _request.contentTypeParameters; }

      /// Gets the host from the request.
      string host() { return _request.host; }

      /// Gets the headers from the request.
      auto headers() { return _request.headers; }

      /// Gets a boolean determnining whether the request was done over a secure tls protocol.
      bool tls() { return _request.tls; }

      /// Gets the raw client address of the request.
      auto clientAddress() { return _request.clientAddress; }

      /// Gets the client certificate from the request.
      auto clientCertificate() { return _request.clientCertificate; }

      /// Boolean determining whether the client has been redirected or not.
      bool redirected() { return _redirected; }

      /// Gets the role associated with the client.
      Role role()
      {
        if (_role)
        {
          return _role;
        }

        if (!_role)
        {
          validateAuthentication(this);
        }

        _role = getRole(this);

        return _role;
      }
    }

    /// Gets a model from the request's json.
    T getModelFromJson(T, CTORARGS...)(CTORARGS args)
    {
      import vibe.data.json;

      static if (is(T == struct))
      {
        T value;

        value.deserializeJson(_request.json);

        return value;
      }
      else static if (is(T == class))
      {
        auto value = new T(args);

        value.deserializeJson(_request.json);

        return value;
      }
      else
      {
        static assert(0);
      }
    }

    /**
    * Adds a generic context value to the client.
    * Params:
    *   name =  The name of the value.
    *   value = The value.
    */
    void addContext(T)(string name, T value)
    {
      _request.context[name] = value;
    }

    /**
    * Gets a value from the client's context.
    * Params:
    *   name =          The name of the value to retrieve.
    *   defaultValue =  The default value to retrieve if the value wasn't found in the context.
    * Returns:
    *   The value if found, defaultValue otherwise.
    */
    T getContext(T)(string name, lazy T defaultValue = T.init)
    {
      import std.variant : Variant;
      Variant value = _request.context.get(name, Variant.init);

      if (!value.hasValue)
      {
        return defaultValue;
      }

      return value.get!T;
    }

    /**
    * Checks whether a value is present n the client's context or not.
    * Params:
    *   name = The name to check for existence.
    * Returns:
    *   True if the value is present, false otherwise.
    */
    bool hasContext(string name)
    {
      import std.variant : Variant;

      return _request.context.get(name, Variant.init).hasValue;
    }

    /**
    * Redirects the client.
    * Params:
    *   url =    The url to redirect the client to.
    *   status = The status of the redirection.
    */
    void redirect(string url, HttpStatus status = HttpStatus.found)
    {
      _response.redirect(url, status);

      import diamond.core.webconfig;
      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        _response.headers[headerKey] = headerValue;
      }

      _redirected = true;
    }

    /**
    * Throws a http status exception.
    * Params:
    *   status = The status.
    * Throws:
    *   Always throws HTTPStatusException.
    */
    void error(HttpStatus status)
    {
      throw new HTTPStatusException(status);
    }

    /// Sends a 404 status.
    void notFound()
    {
      error(HttpStatus.notFound);
    }

    /**
    * Logs the client in.
    * Params:
    *   loginTime = The time the client should be logged in.
    *   role =      The role the client should be after being logged in.
    */
    void login(long loginTime, Role role)
    {
      import diamondauth = diamond.authentication;
      diamondauth.login(this, loginTime, role);
    }

    /// Logs the client out.
    void logout()
    {
      import diamondauth = diamond.authentication;
      diamondauth.logout(this);
    }
  }
}
