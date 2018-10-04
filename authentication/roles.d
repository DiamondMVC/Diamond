/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.authentication.roles;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.errors.checks;
  import diamond.authentication.permissions;
  import diamond.http;

  /// The storage key for the authentication roles.
  private static const __gshared _roleStorageKey = "__D_AUTH_ROLE";

  /**
  * Gets the role storage key based on the client's host.
  * If the host isn't found then the defauly key is used.
  * Params:
  *   client = The client to retrieve the host from.
  * Returns:
  *   The role storage key.
  */
  private string getRoleStorageKey(HttpClient client)
  {
    import diamond.core.senc;
    import diamond.core.webconfig;

    string key = "";

    if (webConfig && webConfig.mappedAuthKeys && webConfig.mappedAuthKeys.length)
    {
      key = webConfig.mappedAuthKeys.get(client.host, "");
    }

    return SENC.encode(key) ~ _roleStorageKey;
  }

  /// The roles.
  private static __gshared Role[string] _roles;

  /// The default role.
  package(diamond) static __gshared Role defaultRole;

  /// Gets a boolean determining whether there are roles or not.
  @property bool hasRoles() { return _roles.length > 0 && defaultRole !is null; }

  /// Wrapper around a role.
  final class Role
  {
    private:
    /// The name.
    string _name;

    /// The permissions.
    Permission[string] _permissions;

    /// The parent role.
    Role _parent;

    /**
    * Creates a new role.
    * Params:
    *   name = The name of the role.
    */
    this(string name)
    {
      _name = name;
    }

    /**
    * Creates a new role.
    * Params:
    *   name =   The name of the role.
    *   parent = The parent role.
    */
    this(string name, Role parent)
    {
      _name = name;
      _parent = parent;
    }

    public:
    final:
    @property
    {
      /// Gets the name.
      string name() { return _name; }

      /// Gets the parent.
      Role parent() { return _parent; }
    }

    /**
    * Adds a permission to the role.
    * Params:
    *   resource =      The resource.
    *   readAccess =    Boolean determining whether the role has read-access.
    *   writeAccess =   Boolean determining whether the role has write-access.
    *   updateAccess =  Boolean determining whether the role has update-access.
    *   deleteAccess =  Boolean determining whether the role has delete-access.
    * Returns:
    *   The role, allowing the function to be chained.
    */
    Role addPermission
    (
      string resource,
      bool readAccess, bool writeAccess,
      bool updateAccess, bool deleteAccess
    )
    {
      enforce(resource, "Found no resource to create permisions for.");

      import std.string : strip;
      import std.array : replace;

      resource = resource.strip();

      if (!resource.replace("/", "").strip().length)
      {
        import diamond.core : webConfig, firstToLower;

        resource = webConfig.homeRoute.firstToLower();
      }

      if (resource[0] == '/')
      {
        resource = resource[1 .. $];
      }

      if (resource[$-1] == '/')
      {
        resource = resource[0 .. $-1];
      }

      _permissions[resource] = new Permission(resource,
                                     readAccess, writeAccess,
                                     updateAccess, deleteAccess
      );

      return this;
    }

    /**
    * Checks whether the role has permission to a specific resource.
    * Params:
    *   resource =    The resource.
    *   permission =  The permission.
    * Returns:
    *   True if the role has permission, false otherwise.
    */
    bool hasPermission(string resource, PermissionType permission)
    {
      enforce(resource, "Found no resource to check permisions for.");

      import std.string : strip;
      import std.array : replace;

      resource = resource.strip();

      if (!resource || !resource.replace("/", "").strip().length)
      {
        import diamond.core : webConfig, firstToLower;

        resource = webConfig.homeRoute.firstToLower();
      }

      if (resource[0] == '/')
      {
        resource = resource[1 .. $];
      }

      if (resource[$-1] == '/')
      {
        resource = resource[0 .. $-1];
      }

      auto permissionResource = _permissions.get(resource, null);

      if (!permissionResource)
      {
        if (_parent)
        {
          return _parent.hasPermission(resource, permission);
        }

        return defaultPermission;
      }

      final switch (permission)
      {
        case PermissionType.readAccess: return permissionResource.readAccess;
        case PermissionType.writeAccess: return permissionResource.writeAccess;
        case PermissionType.updateAccess: return permissionResource.updateAccess;
        case PermissionType.deleteAccess: return permissionResource.deleteAccess;
      }
    }
  }

  /**
  * Gets a role by its name.
  * Params:
  *   name = The name of the role.
  * Returns:
  *   The role if found, defaultRole otherwise.
  */
  Role getRole(string name)
  {
    return _roles.get(name, defaultRole);
  }

  /**
  * Gets a role by its request.
  * Params:
  *   client = The client.
  * Returns:
  *   The role if existing, defaultRole otherwise.
  */
  Role getRole(HttpClient client)
  {
    enforce(client, "No client specified.");

    return client.getContext!Role(getRoleStorageKey(client), defaultRole);
  }

  /**
  * Sets the role.
  * Params:
  *   client =  The client.
  *   role =    The role.
  */
  package(diamond.authentication) void setRole(HttpClient client, Role role)
  {
    enforce(client, "No client specified.");
    enforce(role, "No role specified.");

    client.addContext(getRoleStorageKey(client), role);
  }

  /**
  * Sets the role from the session.
  * Params:
  *   client =           The client.
  *   defaultIsInvalid = Boolean determining whether the default role is an invalid role.
  * Returns:
  *   Returns true if the role was set from the session.
  */
  package(diamond.authentication) bool setRoleFromSession
  (
    HttpClient client,
    bool defaultIsInvalid
  )
  {
    enforce(client, "No client specified.");

    auto sessionRole = client.session.getValue!string(getRoleStorageKey(client), null);

    if (sessionRole !is null)
    {
      auto role = getRole(sessionRole);

      if (defaultIsInvalid && role == defaultRole)
      {
        return false;
      }

      setRole(client, role);
      return true;
    }

    return false;
  }

  /**
  * Sets the session role.
  * Params:
  *   client =  The client.
  *   role =     The role.
  */
  package(diamond.authentication) void setSessionRole
  (
    HttpClient client, Role role
  )
  {
    client.session.setValue(getRoleStorageKey(client), role.name);
  }

  /**
  * Sets the default role.
  * Params:
  *   role = The role.
  */
  void setDefaultRole(Role role)
  {
    enforce(role, "Cannot set the default role to null.");

    defaultRole = role;
  }

  /**
  * Adds a new role.
  * Params:
  *   name = The name of the role.
  * Returns:
  *   The role.
  */
  Role addRole(string name)
  {
    auto role = new Role(name);

    _roles[role.name] = role;

    return role;
  }

  /**
  * Adds a new role.
  * Params:
  *   name =   The name of the role.
  *   parent = The parent role.
  * Returns:
  *   The role.
  */
  Role addRole(string name, Role parent)
  {
    auto role = new Role(name, parent);

    _roles[role.name] = role;

    return role;
  }
}
