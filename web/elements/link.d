/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.link;

import diamond.web.elements.block;

/// Wrapper around a hyperlink.
final class Link : Block!()
{
  public:
  final:
  /**
  * Creates a new hyperlink.
  * Params:
  *   destination = The destination of the hyperlink.
  *   target =      The target of the hyperlink.
  */
  this(string destination, string target = null)
  {
    super("a");

    addAttribute("href", destination);

    if (target)
    {
      addAttribute("target", target);
    }
  }
}
