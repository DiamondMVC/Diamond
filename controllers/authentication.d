/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.authentication;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.http;

  /// Wrapper for an authentication status.
  final class AuthStatus
  {
    private:
    /// The client.
    HttpClient _client;

    /// Boolean determining whether the authentication was successful or not.
    bool _authenticated;

    /// The message of the authentication.
    string _message;

    public:
    /**
    * Creates a new authentcation status.
    * Params:
    *   client =       The client that was authenticated.
    *   authenticated = Boolean determining whehter the authentication was successful or not.
    *   message =       (optional) The message of the authentication status.
    */
    this(HttpClient client, bool authenticated, string message = null)
    {
      _client = client;
      _authenticated = authenticated;
      _message = message;
    }

    @property
    {
      /// Gets the client that was authenticated.
      HttpClient client() { return _client; }

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
    * Function called to validate authentication for a client.
    * Params:
    *   client =   The client to validate for authentication.
    * Returns:
    *   True if the client is authenticated.
    */
    AuthStatus isAuthenticated(HttpClient client);

    /**
    * Function called when authentication fails.
    * Params:
    *   status = The status of the failed authentication.
    */
    void authenticationFailed(AuthStatus status);
  }

  // TODO: Implement basic auth + digest auth wrappers.
}
