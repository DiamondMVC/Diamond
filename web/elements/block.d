/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.block;

import diamond.web.elements.element;

import std.traits : BaseClassesTuple;
import std.meta : AliasSeq;

/// Wrapper around a block element. Default implementation is a div.
class Block(TElement = Element) : Element
if
(
  is(BaseClassesTuple!TElement == AliasSeq!(Element, Object)) ||
  is(TElement == Element)
)
{
  private:
  /// Collection of inner elements.
  TElement[] _elements;

  public:
  final:
  /// Creates a new block element.
  this()
  {
    super("div");
  }

  /**
  * Creates a new block element.
  * Params:
  *   tagName = The name of the block element's tag.
  */
  package(diamond.web.elements) this(string tagName)
  {
    super(tagName);
  }

  /**
  * Adds an element to the block.
  * Params:
  *   element = The element to add.
  */
  void addElement(TElement element)
  {
    _elements ~= element;
  }

  protected:
  /// Generates the appropriate html for the element.
  override string generateHtml()
  {
    import std.string : format;
    import std.array : array, join;
    import std.algorithm : map;

    string innerHtml;

    if (_elements)
    {
      innerHtml = _elements ? _elements.map!(e => e.toString()).array.join("\n") : "";
    }

    if (!innerHtml || !innerHtml.length)
    {
      innerHtml = super.inner ? super.inner : "";
    }

    return `
<%1$s %2$s>
      %3$s
</%1$s>`.format(super.tagName, super.attributeHtml(), innerHtml);
  }
}
