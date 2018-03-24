/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.hidden;

import diamond.web.elements.input;

/// Wrapper around a hidden input.
final class Hidden : Input
{
  public:
  final:
  /// Creates a new hidden input.
  this()
  {
    super();

    addAttribute("type", "hidden");
  }
}
