/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.client;

import diamond.core.apptype;

static if (isWeb)
{
  /// The name of the language session key.
  private static __gshared const languageSessionKey = "__D_LANGUAGE";

  /// The name of the cookie consent's cookie.
  private static const __gshared consentCookieName = "__D_COOKIE_CONSENT";

  /// The name of the privacy key.
  private static __gshared const privacySessionKey = "__D_PRIVACY_CONFIG";

  /// Wrapper around the client's request aand response.
  final class HttpClient
  {
    import std.conv : to;
    import std.typecons : Nullable;
    import std.array : Appender, appender;

    import vibe.d : HTTPServerRequest, HTTPServerResponse,
                    HTTPStatusException;

    import diamond.authentication;
    import diamond.http.sessions;
    import diamond.http.cookies;
    import diamond.http.method;
    import diamond.http.status;
    import diamond.http.routing;
    import diamond.http.privacy;
    import diamond.errors.checks;
    import diamond.core.webconfig;

    private:
    /// The request.
    HTTPServerRequest _request;

    /// The response.
    HTTPServerResponse _response;

    /// The session.
    HttpSession _session;

    /// The cookies.
    HttpCookies _cookies;

    /// The cookie consent of a user.
    Nullable!HttpCookieConsent _cookieConsent;

    /// The route.
    Route _route;

    /// The role.
    Role _role;

    /// The ip address.
    string _ipAddress;

    /// Boolean determnining whether the client has been redirected or not.
    bool _redirected;

    static if (loggingEnabled)
    {
      /// The data written to the response.
      Appender!(ubyte[]) _data;
    }

    /// the status code for the response.
    HttpStatus _statusCode;

    /// The language of the client.
    string _language;

    /// Boolean determining whether the client's route is the last route to handle.
    bool _isLastRoute;

    /// The path.
    string _path;

    /// The privacy collection.
    PrivacyCollection _privacyCollection;

    /// Boolean determining whether the client is handling the request or not.
    bool _handlingRequest;

    /// Force the request as a web-api request.
    bool _forceApi;

    final:
    package(diamond)
    {
      /**
      * Createsa  new http client.
      * Params:
      *   request =   The request.
      *   response =  The response.
      */
      this(HTTPServerRequest request, HTTPServerResponse response)
      {
        _request = enforceInput(request, "Cannot create a client without a request.");
        _response = enforceInput(response, "Cannot create a client without a response.");

        addContext("__D_RAW_HTTP_CLIENT", this);

        _path = request.requestPath.toString();

        static if (loggingEnabled)
        {
          _data = appender!(ubyte[]);
        }
      }
    }

    public:
    @property
    {
      /// Gets the raw vibe.d request.
      package(diamond) HTTPServerRequest rawRequest() { return _request; }

      /// Gets the raw vibe.d response.
      package(diamond) HTTPServerResponse rawResponse() { return _response; }

      /// Gets the route.
      Route route() { return _route; }

      /// Sets the route.
      package(diamond) void route(Route newRoute)
      {
        _route = newRoute;
      }

      /// Gets a boolean determining whether it's the client's last route to handle.
      package(diamond) bool isLastRoute() { return _isLastRoute; }

      /// Sets a boolean determining whether it's the client's last route to handle.
      package(diamond) void isLastRoute(bool isLastRouteState)
      {
        _isLastRoute = isLastRouteState;
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

      /// Gets the cookie consent of a user.
      HttpCookieConsent cookieConsent()
      {
        if (_cookieConsent.isNull)
        {
          auto consent = cookies.get(consentCookieName);

          if (!consent || !consent.length)
          {
            cookieConsent = HttpCookieConsent.all;
          }
          else
          {
            _cookieConsent = cast(HttpCookieConsent)consent;
          }
        }

        return _cookieConsent.get;
      }

      /// Sets the cookie consent of a user.
      void cookieConsent(HttpCookieConsent newCookieConsent)
      {
        _cookieConsent = newCookieConsent;

        cookies.remove(consentCookieName);
        cookies.create(HttpCookieType.session, consentCookieName, cast(string)_cookieConsent.get, 60 * 60 * 24 * 14);
      }

      /// Gets the ip address.
      string ipAddress()
      {
        if (!_ipAddress)
        {
          if (webConfig.ipHeader && webConfig.ipHeader.length)
          {
            _ipAddress = _request.headers[webConfig.ipHeader];
          }
          else
          {
             auto ip = _request.headers.get("X-Real-IP", null);

             if (!ip || !ip.length)
             {
               ip = _request.headers.get("X-Forwarded-For", null);
             }

            _ipAddress = ip && ip.length ? ip : _request.clientAddress.toAddressString();
          }
        }

        return _ipAddress;
      }

      /// Gets the raw request stream.
      auto requestStream() { return _request.bodyReader; }

      /// Gets the raw response stream.
      auto responseStream() { return _response.bodyWriter; }

      /// Gets a boolean determnining whether the response is connected or not.
      bool connected() { return _response.connected; }

      /// Gets the current path.
      string path()
      {
        return _path;
      }

      /// Sets the path of the client.
      package(diamond) void path(string newPath)
      {
        _path = newPath;
      }

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

      /// Gets the status code of the response.
      HttpStatus statusCode() { return _statusCode; }

      /// Gets the language of the client.
      string language()
      {
        if (_language is null)
        {
          import diamond.data.i18n.messages : _defaultLanguage;

          _language = session.getValue!string(languageSessionKey, _defaultLanguage);
        }

        return _language;
      }

      /// Sets the language of the client.
      void language(string newLanguage)
      {
        _language = newLanguage;
        session.setValue(languageSessionKey, _language);
      }

      /// Gets the privacy collection of the client.
      PrivacyCollection privacy()
      {
        if (_privacyCollection is null)
        {
          _privacyCollection = session.getValue!PrivacyCollection(privacySessionKey, null);

          if (_privacyCollection is null)
          {
            _privacyCollection = new PrivacyCollection;

            session.setValue(privacySessionKey, _privacyCollection);
          }
        }

        return _privacyCollection;
      }

      /// Sets a boolean determining whether the client is handling the request or not.
      package(diamond) void handlingRequest(bool isHandlingRequest)
      {
        _handlingRequest = isHandlingRequest;
      }

      /// Sets a boolean determining whether the request should be forced as an api request or not.
      void forceApi(bool shouldForceApi)
      {
        _forceApi = shouldForceApi;
      }

      /// Gets a boolean determining whether the request should be forced as an api request or not.
      bool forceApi() { return _forceApi; }
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
    * Does an internal redirect.
    * Params:
    *   path = The path.
    */
    void internalRedirect(string path)
    {
      if (_handlingRequest)
      {
        return;
      }

      _path = path;
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
      _statusCode = status;
      _response.statusCode = _statusCode;

      throw new HTTPStatusException(status);
    }

    /// Sends a 404 status.
    void notFound()
    {
      error(HttpStatus.notFound);
    }

    /// Sends an unauthorized error
    void unauthorized()
    {
      error(HttpStatus.unauthorized);
    }

    /// Sends a forbidden error
    void forbidden()
    {
      error(HttpStatus.forbidden);
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

    /**
    * Writes data to the response stream.
    * Params:
    *   data = The data to write.
    */
    void write(string data)
    {
      static if (loggingEnabled)
      {
        _data ~= cast(ubyte[])data;
      }

      _response.bodyWriter.write(data);
    }

    /**
    * Writes data to the response stream.
    * Params:
    *   data = The data to write.
    */
    void write(ubyte[] data)
    {
      static if (loggingEnabled)
      {
        _data ~= data;
      }

      _response.bodyWriter.write(data);
    }

    static if (loggingEnabled)
    {
      /// Gets the body data from the response stream.
      package(diamond) ubyte[] getBody()
      {
        return _data.data;
      }
    }
  }
}
