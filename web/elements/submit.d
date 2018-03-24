/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.submit;

import diamond.web.elements.input;

/// Wrapper around a submit input.
final class Submit : Input
{
  public:
  final:
  /// Creates a new submit input.
  this()
  {
    super();

    addAttribute("type", "submit");
  }
}
