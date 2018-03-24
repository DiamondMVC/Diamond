/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.paragraph;

import diamond.web.elements.block;

/// Wrapper around a paragraph.
final class Paragraph : Block!()
{
  public:
  final:
  /// Creates a new paragraph.
  this()
  {
    super("p");
  }
}
