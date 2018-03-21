/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.authentication.auth;

import diamond.core.apptype;

static if (isWeb)
{
  import core.time : minutes;
  import std.datetime : Clock;

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
  package(diamond) void initializeAuth()
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
    Role function(string,HttpClient) f;

    /// Delegate.
    Role delegate(string,HttpClient) d;

    /**
    * Validates the token.
    * Params:
    *   token =    The token to validate.
    *   client =   The client.
    * Returns:
    *   The role to associate with the token.
    */
    Role validate(string token, HttpClient client)
    {
      if (f) return f(token, client);
      else if (d) return d(token, client);

      return null;
    }
  }

  /// Wrapper for the token setter.
  private class TokenSetter
  {
    /// Function pointer.
    string function(HttpClient) f;

    /// Delegate.
    string delegate(HttpClient) d;

    /**
    * Sets the token and gets the result.
    * Params:
    *   client = The client.
    * Returns:
    *   Returns the token result. This should be the generated token.
    */
    string getAndSetToken(HttpClient client)
    {
      if (f) return f(client);
      else if (d) return d(client);

      return null;
    }
  }

  /// Wrapper for the token invalidator.
  private class TokenInvalidator
  {
    /// Function pointer.
    void function(string,HttpClient) f;

    /// Delegate.
    void delegate(string,HttpClient) d;

    /**
    * Invalidates the token.
    * Params:
    *   token =    The token to invalidate.
    *   client =   The client.
    */
    void invalidate(string token, HttpClient client)
    {
      if (f) f(token, client);
      else if (d) d(token, client);
    }
  }

  /**
  * Sets the token validator.
  * Params:
  *   validator = The validator.
  */
  void setTokenValidator(Role function(string,HttpClient) validator)
  {
    tokenValidator.f = validator;
    tokenValidator.d = null;
  }

  /// ditto.
  void setTokenValidator(Role delegate(string,HttpClient) validator)
  {
    tokenValidator.f = null;
    tokenValidator.d = validator;
  }

  /**
  * Sets the token setter.
  * Params:
  *   setter = The setter.
  */
  void setTokenSetter(string function(HttpClient) setter)
  {
    tokenSetter.f = setter;
    tokenSetter.d = null;
  }

  /// Ditto.
  void setTokenSetter(string delegate(HttpClient) setter)
  {
    tokenSetter.f = null;
    tokenSetter.d = setter;
  }

  /**
  * Sets the token invalidator.
  * Params:
  *   invalidator = The invalidator.
  */
  void setTokenInvalidator(void function(string,HttpClient) invalidator)
  {
    tokenInvalidator.f = invalidator;
    tokenInvalidator.d = null;
  }

  /// Ditto.
  void setTokenInvalidator(void delegate(string,HttpClient) invalidator)
  {
    tokenInvalidator.f = null;
    tokenInvalidator.d = invalidator;
  }

  /**
  * Validates the authentication.
  * This also sets the role etc.
  * Params:
  *   client = The client.
  */
  void validateAuthentication(HttpClient client)
  {
    if (setRoleFromSession(client, true))
    {
      return;
    }

    enforce(tokenValidator.f !is null || tokenValidator.d !is null, "No token validator found.");

    auto token = client.cookies.get(authCookieKey);
    Role role;

    if (token)
    {
      role = tokenValidator.validate(token, client);
    }

    if (!role)
    {
      role = getRole("");
    }

    setRole(client, role);
  }

  /**
  * Logs the user in.
  * Params:
  *   client =   The client.
  *   loginTime = The time the user can be logged in. (In minutes)
  *   role =      The role to login as. (If the role is null then the session won't have a role, causing every request to be authenticated.)
  */
  void login(HttpClient client, long loginTime, Role role)
  {
    enforce(tokenSetter.f !is null || tokenSetter.d !is null, "No token setter found.");

    if (role !is null)
    {
      setSessionRole(client, role);
    }

    client.session.updateEndTime(Clock.currTime() + loginTime.minutes);

    auto token = enforceInput(tokenSetter.getAndSetToken(client), "Could not set token.");

    client.cookies.create(HttpCookieType.functional, authCookieKey, token, loginTime * 60);

    validateAuthentication(client);
  }

  /**
  * Logs the user out.
  * Params:
  *   client =  The client.
  */
  void logout(HttpClient client)
  {
    enforce(tokenInvalidator.f !is null || tokenInvalidator.d !is null, "No token invalidator found.");

    client.session.clearValues();
    client.cookies.remove(authCookieKey);
    setRoleFromSession(client, false);

    auto token = client.cookies.get(authCookieKey);

    if (token)
    {
      tokenInvalidator.invalidate(token, client);
    }
  }

  /**
  * Gets the auth cookie from a client.
  * Params:
  *   client = The client to get the auth cookie from.
  * Returns:
  *   Returns the auth cookie.
  */
  string getAuthCookie(HttpClient client)
  {
    return client.cookies.get(authCookieKey);
  }

  /**
  * Checks whether the client has the auth cookie or not.
  * Params:
  *   client = The client.
  * Returns:
  *   True if the client has the auth cookie, false otherwise.
  */
  bool hasAuthCookie(HttpClient client)
  {
    return client.cookies.has(authCookieKey);
  }
}
