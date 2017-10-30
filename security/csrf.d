/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.csrf;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse;

  import diamond.http.sessions;
  import diamond.errors.checks;

  /// The key of the token's storage in the session.
  private static const __gshared CSRFTokenKey = "__D_CSRFTOKEN";

  /**
  * Generates a CSRF token.
  * Params:
  *   request = The request.
  *   response = The response.
  * Returns:
  *   The generated csrf token. If a token already exist, the existing token is returned.
  */
  string generateCSRFToken(HTTPServerRequest request, HTTPServerResponse response)
  {
    auto token = getSessionValue(request, response, CSRFTokenKey);

    if (token)
    {
      return token;
    }

    import diamond.security.tokens.generictoken;

    token = genericToken.generate()[0 .. 64];

    setSessionValue(request, response, CSRFTokenKey, token);

    return token;
  }

  /**
  * Clears the csrf token.
  * Params:
  *   request =  The request.
  *   response = The response.
  */
  void clearCSRFToken(HTTPServerRequest request, HTTPServerResponse response)
  {
    removeSessionValue(request, response, CSRFTokenKey);
  }

  /**
  * Checks whether a token is a valid csrf token for the request.
  * Params:
  *   request =     The request.
  *   response =    The response.
  *   token =       The token to validate.
  *   removeToken = Boolean determining whether the token should be cleared after validation.
  * Returns:
  *   Returns true if the token is valid, false otherwise.
  */
  bool isValidCSRFToken
  (
    HTTPServerRequest request, HTTPServerResponse response,
    string token, bool removeToken
  )
  {
    enforce(token && token.length == 64, "Invalid csrf token.");

    auto csrfToken = getSessionValue(request, response, CSRFTokenKey);

    if (csrfToken && removeToken)
    {
      removeSessionValue(request, response, CSRFTokenKey);
    }

    return csrfToken !is null && token == csrfToken;
  }
}
