/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xml.xmlnode;

import std.string : strip;

import diamond.errors.checks;
import diamond.xml.xmlattribute;
import diamond.xml.xmldocument;
import diamond.xml.xmlexception;

/// An XML node.
final class XmlNode
{
  private:
  /// The associated xml document.
  XmlDocument _document;
  /// The name of the node.
  string _name;
  /// The parent of the node.
  XmlNode _parent;
  /// The text of the node.
  string _text;
  /// The attributes of the node.
  XmlAttribute[string] _attributes;
  /// The children of the node.
  XmlNode[] _children;

  public:
  final:
  /**
  * Creates a new xml node.
  * Params:
  *   parent = The parent node.
  */
  this(XmlNode parent) @safe
  {
    _parent = parent;
  }

  @property
  {
    /// Gets the document associated with the node.
    XmlDocument document() @safe { return _document; }

    /// Sets the document assocaited with the node.
    package(diamond.xml) void document(XmlDocument newDocument) @safe
    {
      _document = newDocument;
    }

    /// Gets the name of the node.
    string name() @safe { return _name; }

    /// Sets the name of the node.
    void name(string newName) @safe
    {
      enforce(newName !is null, "The name cannot be null.");

      _name = newName.strip();
    }

    /// Gets the text of the node.
    string text() { return _text; }

    /// Sets the text of the node. If the text contains xml, then it'll be parsed.
    void text(string newText) @safe
    {
      import diamond.xml.xmlparser;

      auto elements = parseXmlElements(newText, _document);

      if (elements && elements.length)
      {
        foreach (element; elements)
        {
          element._parent = this;
        }

        _children = elements;
      }
      else if (newText)
      {
        _text = newText.strip();
        _children = null;
      }
    }

    /// Sets the raw text of the node.
    package(diamond.xml) void rawText(string text) @safe
    {
      enforce(text !is null, "There must be a text specified.");

      _text = text.strip();
    }

    /// Gets the parent of the node.
    XmlNode parent() @safe { return _parent; }

    /// Gets the children of the node.
    XmlNode[] children() @safe { return _children; }
  }

  /**
  * Adds an attribute to the node.
  * Params:
  *   attribute = The attribute to add.
  */
  void addAttribute(XmlAttribute attribute) @safe
  {
    if (!attribute)
    {
      throw new XmlException("Cannot add a null attribute.");
    }

    _attributes[attribute.name] = attribute;
  }

  /**
  * Adds an attribute to the node.
  * Params:
  *   name = The name of the attribute.
  *   value = The value of the attribute.
  */
  void addAttribute(string name, string value) @safe
  {
    enforce(name !is null, "The name cannot be null.");

    name = name.strip();

    _attributes[name] = new XmlAttribute(name, value);
  }

  /**
  * Removes an attribute from the node.
  * Params:
  *   name = The name of the attribute to remove.
  */
  void removeAttribute(string name) @safe
  {
    if (!name)
    {
      return;
    }

    name = name.strip();

    _attributes.remove(name);
  }

  /**
  * Gets an attribute from the node.
  * Params:
  *   name = The name of the attribute to retrieve.
  * Returns:
  *   The attribute if present, otherwise null.
  */
  XmlAttribute getAttribute(string name) @safe
  {
    if (!name)
    {
      return null;
    }

    name = name.strip();

    return _attributes.get(name, null);
  }

  /**
  * Checks whether an attribute is present within the node or not.
  * Params:
  *   The name of the attribute.
  * Returns:
  *   True if the attribute is present, false otherwise.
  */
  bool hasAttribute(string name) @trusted
  {
    if (!name)
    {
      return false;
    }

    name = name.strip();

    return cast(bool)(name in _attributes);
  }

  /// Clears the attributes of the node.
  void clearAttributes()
  {
    if (_attributes)
    {
      _attributes.clear();
    }
  }

  /**
  * Adds a child to the xml node.
  * Params:
  *   child = The child to add.
  */
  void addChild(XmlNode child) @safe
  {
    if (!child)
    {
      throw new XmlException("Cannot add a null child.");
    }

    _children ~= child;
  }

  /**
  * Gets all nodes by a tag name.
  * Params:
  *   tagName =        The tag name to retrieve nodes by.
  *   searchChildren = If set to true, then it'll perform a nested search through children.
  * Returns:
  *   An array of the nodes found.
  */
  XmlNode[] getByTagName(string tagName, bool searchChildren = false) @safe
  {
    enforce(tagName !is null, "The tag cannot be null.");

    XmlNode[] elements;

    tagName = tagName.strip();

    foreach (child; _children)
    {
      if (child.name == tagName)
      {
        elements ~= child;
      }

      if (searchChildren)
      {
        elements ~= child.getByTagName(tagName, searchChildren);
      }
    }

    return elements;
  }

  /**
  * Gets all nodes by an attribute.
  * Params:
  *   name =           The attribute name to retrieve nodes by.
  *   value =          The value to retrieve nodes by.
  *   searchChildren = If set to true, then it'll perform a nested search through children.
  * Returns:
  *   An array of the nodes found.
  */
  XmlNode[] getByAttribute(string name, string value, bool searchChildren = false) @safe
  {
    enforce(name !is null, "The name cannot be null.");
    enforce(value !is null, "The value cannot be null.");

    XmlNode[] elements;

    name = name.strip();
    value = value.strip();

    foreach (child; _children)
    {
      auto attribute = child.getAttribute(name);

      if (attribute && value == (attribute.value ? attribute.value.strip() : attribute.value))
      {
        elements ~= child;
      }

      if (searchChildren)
      {
        elements ~= child.getByAttribute(name, value, searchChildren);
      }
    }

    return elements;
  }

  /**
  * Gets all nodes by an attribute name.
  * Params:
  *   name =           The attribute name to retrieve nodes by.
  *   searchChildren = If set to true, then it'll perform a nested search through children.
  * Returns:
  *   An array of the nodes found.
  */
  XmlNode[] getByAttributeName(string name, bool searchChildren = false) @safe
  {
    enforce(name !is null, "The name cannot be null.");

    XmlNode[] elements;

    name = name.strip();

    foreach (child; _children)
    {
      if (child.hasAttribute(name))
      {
        elements ~= child;
      }

      if (searchChildren)
      {
        elements ~= child.getByAttributeName(name, searchChildren);
      }
    }

    return elements;
  }

  /**
  * Converts the node to a properly formatted xml node-string.
  * Params:
  *   index = The tab index of the node.
  * Returns:
  *   A string equivalent to the properly formatted xml node-string.
  */
  string toString(size_t index) @trusted
  {
    import std.string : format;
    import std.algorithm : map;
    import std.array : array, join;

    string tabs = "";

    foreach (i; 0 .. index)
    {
      tabs ~= '\t';
    }

    string attributes;
    if (_attributes && _attributes.length)
    {
      attributes = " ";

      attributes ~= _attributes.values.map!(a => "%s=\"%s\"".format(a.name, a.value)).array.join(" ");
    }

    if (_children && _children.length)
    {
      string result = "%s<%s%s>\r\n".format(tabs, _name, attributes);

      foreach (child; _children)
      {
        result ~= child.toString(index + 1);
      }

      result ~= "%s</%s>\r\n".format(tabs, _name);

      return result;
    }
    else if (_text)
    {
      return "%s<%s%s>%s</%s>\r\n".format(tabs, _name, attributes, _text, _name);
    }
    else
    {
      return "%s<%s%s />\r\n".format(tabs, _name, attributes);
    }
  }

  /**
  * Converts the node to a properly formatted xml node-string.
  * Returns:
  *   A string equivalent to the properly formatted xml node-string.
  */
  override string toString() @safe
  {
    return toString(0);
  }
}
