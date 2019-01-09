/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xhtml.xhtmldocument;

import diamond.xhtml.xhtmlexception;
import diamond.dom.domdocument;
import diamond.dom.domnode;
import diamond.dom.domparsersettings;
import diamond.xhtml.xhtmlnode;

/// An XHTML document.
final class XHtmlDocument : DomDocument
{
  private:
  /// The root nodes.
  XHtmlNode[] _rootNodes;
  /// The doctype node.
  XHtmlNode _doctype;
  /// The head node.
  XHtmlNode _head;
  /// The body node.
  XHtmlNode _body;

  public:
  final:
  /**
  * Creates a new xhtml document.
  * Params:
  *   parserSettings = The settings used for parsing the document.
  */
  this(DomParserSettings parserSettings) @safe
  {
    super(parserSettings);
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
        if (element.name.toLower() == "head")
        {
          _head = element;
        }
        else if (element.name.toLower() == "body")
        {
          _body = element;
        }
        else
        {
          if (element.name.toLower() == "html")
          {
            if (element.children)
            {
              foreach (child; element.children)
              {
                if (child.name.toLower() == "head")
                {
                  _head = child;
                }
                else if (child.name.toLower() == "body")
                {
                  _body = child;
                }
              }
            }
          }
        }

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

      if (!_rootNodes)
      {
        return;
      }

      foreach (element; _rootNodes)
      {
        import std.string : toLower;

        if (element.name.toLower() == "doctype")
        {
          _doctype = element;
        }
        else if (element.name.toLower() == "head")
        {
          _head = element;
        }
        else if (element.name.toLower() == "body")
        {
          _body = element;
        }
        else if (element.name.toLower() == "html")
        {
          if (element.children)
          {
            foreach (child; element.children)
            {
              if (child.name.toLower() == "head")
              {
                _head = child;
              }
              else if (child.name.toLower() == "body")
              {
                _body = child;
              }
            }
          }
        }
      }
    }

    /// Gets the head node.
    XHtmlNode head() @safe { return _head; }

    /// Gets the body node.
    XHtmlNode body() @safe { return _body; }
  }

  /**
  * Queries all dom nodes based on a css3 selector.
  * Params:
  *   selector = The css3 selector.
  * Returns:
  *   An array of all matching nodes.
  */
  XHtmlNode[] querySelectorAll(string selector)
  {
    import std.array : array;
    import std.algorithm : map, filter, sort, group;

    XHtmlNode[] elements;

    auto dummyNode = new XHtmlNode(null);

    foreach (rootNode; _rootNodes)
    {
      dummyNode.addChild(rootNode);

      elements ~= dummyNode.querySelectorAll(selector);
    }

    return elements ? elements.sort.group.map!(g => g[0]).array : [];
  }

  /**
  * Queries the first dom node based on a css3 selector.
  * Params:
  *   selector = The css3 selector.
  * Returns:
  *   The node if found, null otherwise.
  */
  XHtmlNode querySelector(string selector)
  {
    auto result = querySelectorAll(selector);

    if (!result || !result.length)
    {
      return null;
    }

    return result[0];
  }

  /**
  * Gets a dom node by an attribute named "id" matching the given value.
  * Params:
  *   id = The id of the node to retrieve.
  * Returns:
  *   The dom node if found, null otherwise.
  */
  XHtmlNode getElementById(string id) @safe
  {
    foreach (rootNode; _rootNodes)
    {
      if (rootNode.hasAttribute("id", id))
      {
        return rootNode;
      }

      auto element = rootNode.getElementById(id);

      if (element)
      {
        return element;
      }
    }

    return null;
  }

  /// XHtml documents cannot be repaired. Use HtmlDocument.repairDocument() instead.
  override void repairDocument() @safe
  {
    throw new XHtmlException("Cannot repair XHtml documents, because they're strict html. Use HtmlDocument.repairDocument() instead.");
  }

  /**
  * Converts the xhtml document to a properly formatted xhtml document-string.
  * Returns:
  *   A string equivalent to the properly formatted xhtml document-string.
  */
  override string toString() @safe
  {
    import std.array : join, array;
    import std.algorithm : map;
    import std.string : format;

    return (_doctype ? "<!%s %s>\r\n".format(_doctype.name, _doctype.getAttributes().map!(a => a.value ? "%s=\"%s\"".format(a.name, a.value) : a.name).array.join(" ")) : "") ~ (_rootNodes ? join(_rootNodes.map!(n => n.toString).array, "\r\n") : "");
  }
}
