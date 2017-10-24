/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.templates.characterincludemode;

/// Enumeration of character include modes.
enum CharacterIncludeMode
{
  /// Neither the start- or end character will be included.
  none,
  /// The start character will be included.
  start,
  /// The end character will be included.
  end,
  /// Both the start- and end character will be included.
  both
}
