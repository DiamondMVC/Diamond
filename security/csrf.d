/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.csrf;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.http;
  import diamond.errors.checks;

  /// The key of the token's storage in the session.
  private static const __gshared CSRFTokenKey = "__D_CSRFTOKEN";

  /**
  * Generates a CSRF token.
  * Params:
  *   client = The client.
  * Returns:
  *   The generated csrf token. If a token already exist, the existing token is returned.
  */
  string generateCSRFToken(HttpClient client)
  {
    auto token = client.session.getValue!string(CSRFTokenKey);

    if (token)
    {
      return token;
    }

    import diamond.security.tokens.generictoken;

    token = genericToken.generate()[0 .. 64];

    client.session.setValue(CSRFTokenKey, token);

    return token;
  }

  /**
  * Clears the csrf token.
  * Params:
  *   client =  The client.
  */
  void clearCSRFToken(HttpClient client)
  {
    client.session.removeValue(CSRFTokenKey);
  }

  /**
  * Checks whether a token is a valid csrf token for the request.
  * Params:
  *   client =     The client.
  *   token =       The token to validate.
  *   removeToken = Boolean determining whether the token should be cleared after validation.
  * Returns:
  *   Returns true if the token is valid, false otherwise.
  */
  bool isValidCSRFToken
  (
    HttpClient client,
    string token, bool removeToken
  )
  {
    enforce(token && token.length == 64, "Invalid csrf token.");

    auto csrfToken = client.session.getValue!string(CSRFTokenKey);

    if (csrfToken && removeToken)
    {
      client.session.removeValue(CSRFTokenKey);
    }

    return csrfToken !is null && token == csrfToken;
  }
}
