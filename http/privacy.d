/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.privacy;

/// Wrapper around a privacy collection.
final class PrivacyCollection
{
  private:
  /// Collection of privacy configurations.
  PrivacyConfiguration[string] _configurations;

  final:
  /// Creates a new privacy collection.
  package(diamond) this() { }

  public:
  /**
  * Operator overload for accessing privacy configurations.
  * Params:
  *   key = The key of the privacy configuration.
  * Returns:
  *   The privacy configurations tied to the key.
  */
  PrivacyConfiguration opIndex(string key)
  {
    auto config = _configurations.get(key, null);

    if (!config)
    {
      config = new PrivacyConfiguration;

      _configurations[key] = config;
    }

    return config;
  }
}

/// Wrapper around privacy configurations.
public final class PrivacyConfiguration
{
  private:
  /// Creates a new privacy configuration.
  this() { }

  public:
  /// Boolean determining whether the data is visible to the public.
  bool publicVisible;
  /// Boolean determining whether the data is visible to associates.
  bool associateVisible;
  /// Boolean determining whether the data is visible to contacts.
  bool contactVisible;
  /// Boolean determining whether the data is visible to staff.
  bool staffVisible;
  /// Boolean determining whehter the data is visible to admins.
  bool adminVisible;
}
