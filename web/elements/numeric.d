/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.numeric;

import diamond.web.elements.input;

/// Wrapper around a numeric input.
final class Numeric : Input
{
  public:
  final:
  /// Creates a new numeric input.
  this()
  {
    super();

    addAttribute("type", "number");
  }
}
