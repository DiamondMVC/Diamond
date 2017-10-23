/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.authentication.auth;

import diamond.core.apptype;

static if (isWeb)
{
  import core.time : minutes;
  import std.datetime : Clock;

  import vibe.d : HTTPServerRequest, HTTPServerResponse;

  import diamond.http;
  import diamond.errors.checks;
  import diamond.authentication.roles;

  /// The token validator.
  private static __gshared TokenValidator tokenValidator;

  /// The token setter.
  private static __gshared TokenSetter tokenSetter;

  /// The token invalidator.
  private static __gshared TokenInvalidator tokenInvalidator;

  /// Static constructor for the module.
  shared static this()
  {
    tokenValidator = new TokenValidator;
    tokenSetter = new TokenSetter;
    tokenInvalidator = new TokenInvalidator;
  }

  /// The cookie key for auth tokens.
  private static const __gshared authCookieKey = "__D_AUTH_TOKEN";

  /// Wrapper for the token validator.
  private class TokenValidator
  {
    /// Function pointer.
    Role function(string,HTTPServerRequest,HTTPServerResponse) f;

    /// Delegate.
    Role delegate(string,HTTPServerRequest,HTTPServerResponse) d;

    /**
    * Validates the token.
    * Params:
    *   token =    The token to validate.
    *   request =  The request.
    *   response = The response.
    * Returns:
    *   The role to associate with the token.
    */
    Role validate(string token, HTTPServerRequest request, HTTPServerResponse response)
    {
      if (f) return f(token, request, response);
      else if (d) return d(token, request, response);

      return null;
    }
  }

  /// Wrapper for the token setter.
  private class TokenSetter
  {
    /// Function pointer.
    string function(HTTPServerRequest,HTTPServerResponse) f;

    /// Delegate.
    string delegate(HTTPServerRequest,HTTPServerResponse) d;

    /**
    * Sets the token and gets the result.
    * Params:
    *   request = The request.
    *   response = The response.
    * Returns:
    *   Returns the token result. This should be the generated token.
    */
    string getAndSetToken(HTTPServerRequest request, HTTPServerResponse response)
    {
      if (f) return f(request, response);
      else if (d) return d(request, response);

      return null;
    }
  }

  /// Wrapper for the token invalidator.
  private class TokenInvalidator
  {
    /// Function pointer.
    void function(string,HTTPServerRequest,HTTPServerResponse) f;

    /// Delegate.
    void delegate(string,HTTPServerRequest,HTTPServerResponse) d;

    /**
    * Invalidates the token.
    * Params:
    *   token =    The token to invalidate.
    *   request =  The request.
    *   response = The response.
    */
    void invalidate(string token, HTTPServerRequest request, HTTPServerResponse response)
    {
      if (f) f(token, request, response);
      else if (d) d(token, request, response);
    }
  }

  /**
  * Sets the token validator.
  * Params:
  *   validator = The validator.
  */
  void setTokenValidator(Role function(string,HTTPServerRequest,HTTPServerResponse) validator)
  {
    tokenValidator.f = validator;
    tokenValidator.d = null;
  }

  /// ditto.
  void setTokenValidator(Role delegate(string,HTTPServerRequest,HTTPServerResponse) validator)
  {
    tokenValidator.f = null;
    tokenValidator.d = validator;
  }

  /**
  * Sets the token setter.
  * Params:
  *   setter = The setter.
  */
  void setTokenSetter(string function(HTTPServerRequest,HTTPServerResponse) setter)
  {
    tokenSetter.f = setter;
    tokenSetter.d = null;
  }

  /// Ditto.
  void setTokenSetter(string delegate(HTTPServerRequest,HTTPServerResponse) setter)
  {
    tokenSetter.f = null;
    tokenSetter.d = setter;
  }

  /**
  * Sets the token invalidator.
  * Params:
  *   invalidator = The invalidator.
  */
  void setTokenInvalidator(void function(string,HTTPServerRequest,HTTPServerResponse) invalidator)
  {
    tokenInvalidator.f = invalidator;
    tokenInvalidator.d = null;
  }

  /// Ditto.
  void setTokenInvalidator(void delegate(string,HTTPServerRequest,HTTPServerResponse) invalidator)
  {
    tokenInvalidator.f = null;
    tokenInvalidator.d = invalidator;
  }

  /**
  * Validates the authentication.
  * This also sets the role etc.
  * Params:
  *   request = The request.
  *   response = The response.
  */
  void validateAuthentication(HTTPServerRequest request, HTTPServerResponse response)
  {
    enforce(request, "No request found.");
    enforce(response, "No response found.");

    if (setRoleFromSession(request, response, true))
    {
      return;
    }

    enforce(tokenValidator.f !is null || tokenValidator.d !is null, "No token validator found.");

    auto token = request.getCookie(authCookieKey);
    Role role;

    if (token)
    {
      role = tokenValidator.validate(token, request, response);
    }

    if (!role)
    {
      role = getRole("");
    }

    setRole(request, role);
  }

  /**
  * Logs the user in.
  * Params:
  *   request =   The request.
  *   responsse = The response.
  *   loginTime = The time the user can be logged in. (In minutes)
  *   role =      The role to login as.
  */
  void login(HTTPServerRequest request, HTTPServerResponse response, long loginTime, Role role)
  {
    enforce(request, "No request found.");
    enforce(response, "No response found.");
    enforce(tokenSetter.f !is null || tokenSetter.d !is null, "No token setter found.");

    setSessionRole(request, response, role);
    updateSessionEndTime(request, response, Clock.currTime() + loginTime.minutes);

    auto token = enforceInput(tokenSetter.getAndSetToken(request, response), "Could not set token.");

    response.createCookie(authCookieKey, token, loginTime * 60);

    validateAuthentication(request, response);
  }

  /**
  * Logs the user out.
  * Params:
  *   request =  The request.
  *   response = The response.
  */
  void logout(HTTPServerRequest request, HTTPServerResponse response)
  {
    enforce(request, "No request found.");
    enforce(response, "No response found.");
    enforce(tokenInvalidator.f !is null || tokenInvalidator.d !is null, "No token invalidator found.");

    clearSessionValues(request, response);
    response.removeCookie(authCookieKey);
    setRoleFromSession(request, response, false);

    auto token = request.getCookie(authCookieKey);

    if (token)
    {
      tokenInvalidator.invalidate(token, request, response);
    }
  }
}
