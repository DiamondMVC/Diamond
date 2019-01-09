/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.radio;

import diamond.web.elements.input;

/// Wrapper around a radio input.
final class Radio : Input
{
  public:
  final:
  /// Creates a new radio input.
  this()
  {
    super();

    addAttribute("type", "radio");
  }
}
