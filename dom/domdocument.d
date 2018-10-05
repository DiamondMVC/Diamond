/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.dom.domdocument;

import diamond.dom.domnode;

/// A dom document.
abstract class DomDocument
{
  protected:
  /// Creates a new dom document.
  this() @safe
  {
  }

  /**
  * Parses the elements from the dom to the document.
  * Params:
  *   elements = The parsed dom elements.
  */
  abstract void parseElements(DomNode[] elements) @safe;
}
