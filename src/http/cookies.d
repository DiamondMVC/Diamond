/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.cookies;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, Cookie;

  import diamond.errors.checks;
  import diamond.core.senc;

  /**
  * Creates a cookie.
  * Params:
  *   response = The response to create a cookie for.
  *   name =     The name of the cookie.
  *   value =    The value of the cookie.
  *   maxAge =   The max-age of the cookie. (Seconds the cookie will be alive.)
  *   path =     The path of the cookie. (Default: "/")
  */
  void createCookie
  (
    HTTPServerResponse response,
    string name, string value,
    long maxAge,
    string path = "/"
  )
  {
    enforce(response, "Cannot create a cookie without a response.");

    auto cookie = new Cookie;
    cookie.path = path;
    cookie.maxAge = maxAge;
    cookie.setValue(value, Cookie.Encoding.none);

    response.cookies[name] = cookie;
  }

  /**
  * Creates a cookie.
  * Params:
  *   response =  The response to create a cookie for.
  *   name =      The name of the cookie.
  *   buffer =    The buffer to encode into a SENC encoded cookie string.
  *   maxAge =    The max-age of the cookie. (Seconds the cookie will be alive.)
  *   path =      The path of the cookie. (Default: "/")
  */
  void createBufferedCookie
  (
    HTTPServerResponse response,
    string name, ubyte[] buffer,
    long maxAge,
    string path = "/"
  )
  {
    return createCookie(response, name, SENC.encode(buffer), maxAge, path);
  }

  /**
  * Gets a cookie.
  * Params:
  *   request = The request to get the cookie from.
  *   name =    The name of the cookie.
  * Returns:
  *   Returns the cookie if found, null otherwise.
  */
  string getCookie(HTTPServerRequest request, string name)
  {
    enforce(request, "Cannot retrieve a cookie without a request.");

    return request.cookies.get(name);
  }

  /**
  * Gets a buffered cookie encoded as a SENC encoded string.
  * Params:
  *   request = The request.
  *   name =    The name.
  * Returns:
  *   Returns the buffer.
  */
  ubyte[] getBufferedCookie(HTTPServerRequest request, string name)
  {
    return SENC.decode(getCookie(request, name));
  }

  /**
  * Removes a cookie.
  * Params:
  *   response = The response to remove the cookie from.
  *   name =     The name of the cookie to remove.
  */
  void removeCookie(HTTPServerResponse response, string name)
  {
    auto cookie = new Cookie;
    cookie.path = "/";
    cookie.maxAge = 1;
    cookie.setValue(null, Cookie.Encoding.none);

    response.cookies[name] = cookie;
  }
}
