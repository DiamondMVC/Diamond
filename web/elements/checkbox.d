/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.checkbox;

import diamond.web.elements.input;

/// Wrapper around a checkbox input.
final class CheckBox : Input
{
  public:
  final:
  /// Creates a new checkbox input.
  this()
  {
    super();

    addAttribute("type", "checkbox");
  }
}
