/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.authentication;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest;

  /// Wrapper for an authentication status.
  final class AuthStatus
  {
    private:
    /// The request.
    HTTPServerRequest _httpRequest;

    /// Boolean determining whether the authentication was successful or not.
    bool _authenticated;

    /// The message of the authentication.
    string _message;

    public:
    /**
    * Creates a new authentcation status.
    * Params:
    *   request =       The request that was authenticated.
    *   authenticated = Boolean determining whehter the authentication was successful or not.
    *   message =       (optional) The message of the authentication status.
    */
    this(HTTPServerRequest request, bool authenticated, string message = null)
    {
      _httpRequest = request;
      _authenticated = authenticated;
      _message = message;
    }

    @property
    {
      /// Gets the request that was authenticated.
      HTTPServerRequest httpRequest() { return _httpRequest; }

      /// Gets a boolean determining whether the authentication was successful or not.
      bool authenticated() { return _authenticated; }

      /// Gets the message of the authentication status.
      string message() { return _message; }
    }
  }

  /// Interface to implement authentication.
  interface IControllerAuth
  {
    /**
    * Function called to validate authentication for a request.
    * Params:
    *   request = The request to validate for authentication.
    * Returns:
    *   True if the request is authenticated.
    */
    AuthStatus isAuthenticated(HTTPServerRequest request);

    /**
    * Function called when authentication fails.
    * Params:
    *   status = The status of the failed authentication.
    */
    void authenticationFailed(AuthStatus status);
  }

  // TODO: Implement basic auth + digest auth wrappers.
}
