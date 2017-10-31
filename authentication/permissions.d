/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.authentication.permissions;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.http;
  import diamond.http.method; // Bug: Cannot get acess to members from this module through "diamond.http"
  import diamond.authentication.roles;

  /// Enumeration of permission types.
  enum PermissionType
  {
    readAccess,
    writeAccess,
    updateAccess,
    deleteAccess
  }

  /// Wrapper around permissions.
  final class Permission
  {
    private:
    /// The resource.
    string _resource;

    /// Boolean determining the read-access.
    bool _readAccess;

    /// Boolean determining the write-access.
    bool _writeAccess;

    /// Boolean determining the update-access.
    bool _updateAccess;

    /// Boolean determining the delete-access.
    bool _deleteAccess;

    public:
    final:
    /**
    * Creates a new permission.
    * Params:
    *   resource =      The resource.
    *   readAccess =    Boolean determining the read-access.
    *   writeAccess =   Boolean determining the write-access.
    *   updateAccess =  Boolean determining the update-access.
    *   deleteAccess =  Boolean determining the delete-access.
    */
    this(string resource, bool readAccess, bool writeAccess, bool updateAccess, bool deleteAccess)
    {
      _resource = resource;
      _readAccess = readAccess;
      _writeAccess = writeAccess;
      _updateAccess = updateAccess;
      _deleteAccess = deleteAccess;
    }

    @property
    {
      /// Gets the resource.
      string resource() { return _resource; }

      /// Gets a boolean determining the read-access.
      bool readAccess() { return _readAccess; }

      /// Gets a boolean determining the write-access.
      bool writeAccess() { return _writeAccess; }

      /// Gets a boolean determining the update-access.
      bool updateAccess() { return _updateAccess; }

      /// Gets a boolean determining the delete-access.
      bool deleteAccess() { return _deleteAccess; }
    }
  }

  /// The permissions for http methods.
  private static __gshared PermissionType[][HttpMethod] permissions;

  /// Boolean for the default permission access.
  public static __gshared bool defaultPermission;

  /// The default permissions for http methods.
  private static __gshared PermissionType[] defaultPermissions = [];

  /**
  * Unrequires a permission for a http method.
  * Params:
  *   method =     The method.
  *   permission = The permission.
  */
  void unrequirePermissionMethod(HttpMethod method, PermissionType permission)
  {
    import std.algorithm : filter;
    import std.array : array;

    permissions[method] = permissions[method].filter!(p => p != permission).array;
  }

  /**
  * Requires a permission for a http method.
  * Params:
  *   method =     The method.
  *   permission = The permission.
  */
  void requirePermissionMethod(HttpMethod method, PermissionType permission)
  {
    permissions[method] ~= permission;
  }

  /**
  * Checks whether a specific role has access with a specific method's permissions on a resource.
  * Params:
  *   role =      The role.
  *   method =    The method.
  *   resourcce = The resource.
  * Returns:
  *   Returns true if the role has access, false otherwise.
  */
  bool hasAccess(Role role, HttpMethod method, string resource)
  {
    bool access = true;
    auto accessPermissions = permissions.get(method, defaultPermissions);

    foreach (permission; accessPermissions)
    {
      if (!role.hasPermission(resource, permission))
      {
        access = false;
        break;
      }
    }

    return access;
  }
}
