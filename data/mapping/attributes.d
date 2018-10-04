/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.attributes;

/// Attribute for excluding fields.
struct DbNoMap { }

/// Attribute for marking fields as nullable.
struct DbNull { }

/// Attribute for marking fields as db-enums.
struct DbEnum { }

/// Attribute for ids.
struct DbId { }

/// Attribute for timestamps.
struct DbTimestamp { }

// Attribute to mark data as personal. Use this to easily integrate with GDPR.
struct DbPersonal { }

/// Attribute for relationships.
struct DbRelationship
{
  /// A custom sql to retrieve the relationship data.
  string sql;
  /// An associative array of members to match when generating the sql to retrieve the relationship data.
  string[string] members;

  /// Disables the default ctor for the struct.
  @disable this();

  /**
  * Creates a db relationship with a custom sql query.
  * Params:
  *   sql = The sql query.
  */
  this(string sql)
  {
    this.sql = sql;
    this.members = null;
  }

  /**
  * Creates a db relationship with an array of members to use for the query generation.
  * Params:
  *   members = The members.
  */
  this(string[string] members)
  {
    this.sql = null;
    this.members = members;
  }
}

/// Attribute for custom data-type handling.
struct DbProxy
{
  /// The name of the custom read handler.
  string readHandler;
  /// The name of the custom write handler.
  string writeHandler;
}
