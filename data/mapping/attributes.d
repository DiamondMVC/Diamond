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
