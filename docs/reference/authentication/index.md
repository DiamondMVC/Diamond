[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Authentication

Authentication can be done easily in Diamond using attributes in your controllers.

To use authentication you must have a class that implements *IControllerAuth* which can be found in the module *diamond.controllers.authentication* or the *diamond.controllers* package.

The class that implements the interface must be available from the *controllers* package, so make sure you import the module to it from there (Just like you would with controllers normally.)

```
final class TestAuth : IControllerAuth
{
  public:
  AuthStatus isAuthenticated(HttpClient client)
  {
      ...
  }

  void authenticationFailed(AuthStatus status)
  {
      ...
  }
}
```

### AuthStatus isAuthenticated(HttpClient client);

This function is used to validate the authentication of a request.

*AuthStatus* is a class that is used internally to handle the authentication status returned.

It takes the following parameters in its constructor:

```
this(HttpClient client, bool authenticated, string message = null)
```

If there's no instance of *AuthStatus* returned or if *authenticated* is set to false then *authenticationFailed* will be triggered.

### void authenticationFailed(AuthStatus status);

This function is called when authentication has failed for a request.

Note: The status passed to *authenticationFailed* is the status returned by *isAuthenticated*.

*authenticationFailed* should be used to handle failed authentications.

Example of IControllerAuth implementation:

```
final class TestAuth : IControllerAuth
{
  public:
  final:
  AuthStatus isAuthenticated(HttpClient client)
  {
    return new AuthStatus(
        request,
        client.cookies.has("loginCookie"),
        "Invalid username or password."
    );
  }

  void authenticationFailed(AuthStatus status)
  {
    import std.stdio : writefln;

    writefln("Failed auth: %s", status.message);
  }
}
```

To use authentication for a controller, the controller must have the attribute *@HttpAuthentication* which takes a single value as the name of the class that is to be used for authentication. The class name given must be the one that implements *IControllerAuth*.

```
@HttpAuthentication(TestAuth.stringof) final class HomeController(TView) : Controller!TView
{
    ...
}
```

Authentication will be enabled for all mapped actions within the controller, including the default action.

However authentication can easily be disabled for specific actions (Including the default action.) using the attribute *@HttpDisableAuth*

```
  /// Can be accessed without authentication
  @HttpDisableAuth @HttpDefault Status home()
  {
    return Status.success;
  }

  /// Must be authenticated to access this
  @HttpAction(HttpGet) Status test()
  {
    return jsonString(q{{ "success": true }});
  }

  /// Can be accessed without authentication
  @HttpDisableAuth @HttpAction(HttpGet) Status test2()
  {
    return jsonString(q{{ "success": true }});
  }
```
