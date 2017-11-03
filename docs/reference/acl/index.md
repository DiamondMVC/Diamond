[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# ACL (Access Control List)

ACL can be implemented easily in Diamond with a user-friendly API.

It's recommended to setup your roles and permissions in the *onApplicationStart()* function located in your websetting class.

You must import *diamond.authentication* to be able to use the ACL outside of controllers.

To create a role you must use the *addRole()* function.

Example:

```
auto guest = addRole("guest");
auto user = addRole("user");
auto admin = addRole("admin");
```

When you create a role you can also pass another role to it which will serve as a parent role. If permissions aren't set for the user then the parent's permissions are used.

There are no limits on role inheritance.

```
auto administrators = addRole("administrators");

auto owner = addRole("owner", administrators);
auto superUser = addRole("super-user", administrators);
```

The role class has a function called *addPermission()* which is used to add permissions for a role. The function returns the role class instance, which means it can be chained.

The arguments of the *addPermission()* are as following: *resource*, *readAccess*, *writeAccess*, *updateAccess*, *deleteAccess*.

```
auto guest = addRole("guest")
  .addPermission("/", true, false, false, false) // Guests can view home page
  .addPermission("/user", true, true, false, false) // Guests can view user pages, as well register (POST)
  .addPermission("/login", true, true, false, false) // Guests can view login page, as well login (POST)
  .addPermission("/logout", false, false, false, false); // Guests cannot logout, because they're not logged in

auto user = addRole("user")
  .addPermission("/", true, false, false, false) // Users can view home page
  .addPermission("/user", true, false, true, false) // Users can view user pages, as well update user information (PUT)
  .addPermission("/login", false, false, false, false) // Users cannot view login page or login
  .addPermission("/logout", false, true, false, false); // Users can logout (POST)
```

To use roles you must set a default role by calling the *setDefaultRole()* function.

```
setDefaultRole(guest);
```

## Authentication using ACL

You must set 3 functions for the ACL to work with authentication.

The functions that must be set are for token validation, token invalidation and token setter.

### Token-validation

The token validation function can be set with the function *setTokenValidator()*

Example: (in *onApplicationStart()*)

```
setTokenValidator(&validateToken);
```

Example: (Function implementation)

The function must return a role which is the role set when the token is valid.

Token validation can differ from implementation, but generally a database look-up can be used.

```
Role validateToken(string token, HttpClient client)
{
  return tokenIsValidInDatabase(token) ? getRole("user") : getRole("guest");
}
```

### Token-invalidation

The token invalidation function can be set with the function *setTokenInvalidator()*

Example: (in *onApplicationStart()*)

```
setTokenInvalidator(&invalidateToken);
```

Example: (Function implementation)

The function must return a role which is the role set when the token is valid.

Token invalidation can differ from implementation, but generally you want to delete it from the database.

```
void invalidateToken(string token, HttpClient client)
{
  deleteTokenFromDatabase(token);
}
```

### Token-setter

The token setter function can be set with the function *setTokenSetter()*

Example: (in *onApplicationStart()*)

```
setTokenSetter(&setToken);
```

Example: (Function implementation)

The function must return a string that is equivalent to the token.

Token setters can differ from implementation, but generally you want to create a unique token and store it in the database. The token is used to identify the logged in user as well authenticate that the user is in fact logged in.

```
string setToken(HttpClient client)
{
  auto token = generateAuthToken();
  insertTokenToDatabase(token);

  return token;
}
```

To login you simply call the *login()* function and to logout you call the *logout()* function.

They can be accessed from *HttpClient* or with their raw versions in the *diamond.authentication* package.

Login:

```
long loginTimeInMinutes = 99999;
auto userRole = getRole("user");

client.login(loginTimeinMinutes, userRole);
```

Logout:

```
client.logout();
```

You don't need to worry about cookies, sessions etc. it's all done in the background by Diamond.

When using ACL it's preferred to check if a user is logged in by checking their role.

```
if (client.role.name == "user")
{
    // Logged in as a user ...
}
else
{
    // Not logged in as a user ...
}
```

## Default Required Permissions

You can change the default permissions for the http methods using *requirePermissionMethod()* and *unrequiredPermissionMethod()*

The default permissions are as following:

* HTTP-GET: Requires read-access
* HTTP-POST: Requires write-access
* HTTP-PUT: Requires update-access
* HTTP-DELETE: Requires delete-access

Example: (To create a 100% valid REST API. Since *PUT* should write and update.)

```
requirePermissionMethod(HttpMethod.PUT, PermissionType.writeAccess);
```

## Additional Security

By default permissions not found in the ACL will allow read, write, update and delete.

Sometimes you want to limit the default permissions for unmapped resources.

It can be done by changing the property *defaultPermission* which is a boolean.

```
defaultPermission = false; // Disallow access to resources not mapped with permissions.
```
