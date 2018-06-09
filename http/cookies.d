/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.cookies;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : Cookie;

  import diamond.errors.checks;
  import diamond.core.senc;
  import diamond.http.client;

  /// Collection of standard cookies used within Diamond.
  private CookieInformation[] _cookieInformation;

  /// Wrapper around cookie information.
  class CookieInformation
  {
    private:
    /// The cookie name.
    string _cookieName;
    /// The cookie description.
    string _cookieDescription;

    /**
    * Creates a new cookie information wrapper.
    * Params:
    *   cookieName =        The name of the cookie.
    *   cookieDescription = The description of the cookie.
    */
    this(string cookieName, string cookieDescription)
    {
      _cookieName = cookieName;
      _cookieDescription = cookieDescription;
    }

    public:
    /// Gets the name of the cookie.
    string cookieName() { return _cookieName; }

    /// Gets the description of the cookie.
    string cookieDescription() { return _cookieDescription; }
  }

  /// Gets information about all standard cookies used within Diamond.
  CookieInformation[] getCookieInformation()
  {
    if (!_cookieInformation)
    {
      _cookieInformation = [
        new CookieInformation("__D_AUTH_TOKEN", "This cookie is used to store the authentication token used by Diamond."),
        new CookieInformation("__D_COOKIE_CONSENT", "This cookie is used to store the cookie consent used by Diamond."),
        new CookieInformation("__D_SESSION", "This cookie is used to store the Diamond session id of a client.")
      ];
    }

    return _cookieInformation;
  }

  /// Enumeration of http cookie consent types.
  enum HttpCookieConsent : string
  {
    /// All cookies are allowed.
    all = "all",
    /// No third-party cookies are allowed.
    noThirdParty = "noThirdParty",
    /// Only functional required cookies are allowed. Third-party cookies etc. are not allowed.
    functional = "functional",
    /// No cookies are allowed.
    none = "none"
  }

  /// The type of cookie added.
  enum HttpCookieType
  {
    /// A general cookie used for miscellaneous functionality.
    general,
    /// A cookie required for minimum functionality.
    functional,
    /// A third-party cookie.
    thirdParty,
    /// A session cookie. Session cookies cannot be disabled.
    session
  }

  /// Wrapper around a http cookie collections.
  final class HttpCookies
  {
    private:
    /// The client.
    HttpClient _client;

    public:
    final:
    /**
    * Creates a new http cookie collection.
    * Params:
    *   client = The client.
    */
    package(diamond) this(HttpClient client)
    {
      _client = enforceInput(client, "Cannot create a cookie collection without a client.");
    }

    /**
    * Checks whether a user has consent for a specific cookie type.
    * Params:
    *   cookieType = The type of the cookie.
    * Returns:
    *   True if the user accepts the cookie, false otherwise.
    */
    private bool hasConsent(HttpCookieType cookieType)
    {
      switch (cookieType)
      {
        case HttpCookieType.general:
        {
          if
          (
            _client.cookieConsent != HttpCookieConsent.all &&
            _client.cookieConsent != HttpCookieConsent.noThirdParty
          )
          {
            return false;
          }

          break;
        }

        case HttpCookieType.functional:
        {
          if
          (
            _client.cookieConsent == HttpCookieConsent.none
          )
          {
            return false;
          }

          break;
        }

        case HttpCookieType.thirdParty:
        {
          if
          (
            _client.cookieConsent != HttpCookieConsent.all
          )
          {
            return false;
          }

          break;
        }

        default: break;
      }

      return _client.cookieConsent != HttpCookieConsent.none;
    }

    /**
    * Creates a cookie.
    * Params:
    *   cookieType = The type of the cookie.
    *   name =       The name of the cookie.
    *   value =      The value of the cookie.
    *   maxAge =     The max-age of the cookie. (Seconds the cookie will be alive.)
    *   path =       The path of the cookie. (Default: "/")
    */
    void create
    (
      HttpCookieType cookieType,
      string name, string value,
      long maxAge,
      string path = "/"
    )
    {
      if (!hasConsent(cookieType))
      {
        return;
      }

      auto cookie = new Cookie;
      cookie.path = path;
      cookie.maxAge = maxAge;
      cookie.setValue(value, Cookie.Encoding.none);

      _client.rawResponse.cookies[name] = cookie;
    }

    /**
    * Creates a cookie.
    * Params:
    *   cookieType = The type of the cookie.
    *   name =      The name of the cookie.
    *   buffer =    The buffer to encode into a SENC encoded cookie string.
    *   maxAge =    The max-age of the cookie. (Seconds the cookie will be alive.)
    *   path =      The path of the cookie. (Default: "/")
    */
    void createBuffered
    (
      HttpCookieType cookieType,
      string name, ubyte[] buffer,
      long maxAge,
      string path = "/"
    )
    {
      if (!hasConsent(cookieType))
      {
        return;
      }

      create(cookieType, name, SENC.encode(buffer), maxAge, path);
    }

    /**
    * Gets a cookie.
    * Params:
    *   name =    The name of the cookie.
    * Returns:
    *   Returns the cookie if found, null otherwise.
    */
    string get(string name)
    {
      return _client.rawRequest.cookies.get(name);
    }

    /**
    * Gets a buffered cookie encoded as a SENC encoded string.
    * Params:
    *   name =    The name.
    * Returns:
    *   Returns the buffer.
    */
    ubyte[] getBuffered(string name)
    {
      return SENC.decode(get(name));
    }

    /**
    * Removes a cookie.
    * Params:
    *   name =     The name of the cookie to remove.
    */
    void remove(string name)
    {
      auto cookie = new Cookie;
      cookie.path = "/";
      cookie.maxAge = 1;
      cookie.setValue(null, Cookie.Encoding.none);

      _client.rawResponse.cookies[name] = cookie;
    }

    /**
    * Checks whether a request has a cookie or not.
    * Params:
    *   name = The name of the cookie to check for existence.
    * Returns:
    *   True if the cookie exists, false otherwise.
    */
    bool has(string name)
    {
      return get(name) !is null;
    }

    /**
    * Gets the auth cookie.
    * Returns:
    *   Returns the auth cookie.
    */
    string getAuthCookie()
    {
      import diamondauth = diamond.authentication;

      return diamondauth.getAuthCookie(_client);
    }

    /**
    * Checks whether the auth cookie is present or not.
    * Returns:
    *   True if the auth cookie is present, false otherwise.
    */
    @property bool hasAuthCookie()
    {
      import diamondauth = diamond.authentication;

      return diamondauth.hasAuthCookie(_client);
    }
  }
}
