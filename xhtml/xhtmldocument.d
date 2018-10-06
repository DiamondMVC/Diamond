/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xhtml.xhtmldocument;

import diamond.xhtml.xhtmlexception;
import diamond.dom.domdocument;
import diamond.dom.domnode;
import diamond.xhtml.xhtmlnode;

/// An XHTML document.
final class XHtmlDocument : DomDocument
{
  private:
  /// The root nodes.
  XHtmlNode[] _rootNodes;
  /// The doctype node.
  XHtmlNode _doctype;

  public:
  final:
  /// Creates a new html document.
  this() @safe
  {
    super();
  }

  /**
  * Parses the elements from the dom to the document.
  * Params:
  *   elements = The parsed dom elements.
  */
  override void parseElements(DomNode[] elements) @safe
  {
    if (!elements)
    {
      return;
    }

    foreach (element; elements)
    {
      import std.string : toLower;

      if (element.name.toLower() == "doctype")
      {
        _doctype = element;
      }
      else
      {
        _rootNodes ~= element;
      }
    }
  }

  @property
  {
    /// Gets the root nodes of the html document.
    XHtmlNode[] rootNodes() @safe { return _rootNodes; }

    /// Sets the root nodes of the html document.
    void root(XHtmlNode[] nodes) @safe
    {
      _rootNodes = nodes;
    }
  }

  /**
  * Converts the html document to a properly formatted html document-string.
  * Returns:
  *   A string equivalent to the properly formatted html document-string.
  */
  override string toString() @safe
  {
    import std.array : join, array;
    import std.algorithm : map;
    import std.string : format;

    return (_doctype ? "<!%s %s>\r\n".format(_doctype.name, _doctype.getAttributes().map!(a => a.value ? "%s=\"%s\"".format(a.name, a.value) : a.name).array.join(" ")) : "") ~ (_rootNodes ? join(_rootNodes.map!(n => n.toString).array, "\r\n") : "");
  }
}
