/**
* Copyright © DiamondMVC 2016-2017
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
    * Creates a cookie.
    * Params:
    *   name =     The name of the cookie.
    *   value =    The value of the cookie.
    *   maxAge =   The max-age of the cookie. (Seconds the cookie will be alive.)
    *   path =     The path of the cookie. (Default: "/")
    */
    void create
    (
      string name, string value,
      long maxAge,
      string path = "/"
    )
    {
      auto cookie = new Cookie;
      cookie.path = path;
      cookie.maxAge = maxAge;
      cookie.setValue(value, Cookie.Encoding.none);

      _client.rawResponse.cookies[name] = cookie;
    }

    /**
    * Creates a cookie.
    * Params:
    *   name =      The name of the cookie.
    *   buffer =    The buffer to encode into a SENC encoded cookie string.
    *   maxAge =    The max-age of the cookie. (Seconds the cookie will be alive.)
    *   path =      The path of the cookie. (Default: "/")
    */
    void createBuffered
    (
      string name, ubyte[] buffer,
      long maxAge,
      string path = "/"
    )
    {
      return create(name, SENC.encode(buffer), maxAge, path);
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
  }
}
