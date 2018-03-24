/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.text;

import diamond.web.elements.input;

/// Wrapper around a text input.
final class Text : Input
{
  public:
  final:
  /// Creates a new text input.
  this()
  {
    super();

    addAttribute("type", "text");
  }
}
