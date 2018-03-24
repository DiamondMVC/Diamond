/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.password;

import diamond.web.elements.input;

/// Wrapper around a password input.
final class Password : Input
{
  public:
  final:
  /// Creates a new password input.
  this()
  {
    super();

    addAttribute("type", "password");
  }
}
