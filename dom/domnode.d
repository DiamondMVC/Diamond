/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.dom.domnode;

import std.string : strip, toLower;
import std.algorithm : filter;
import std.array : array;

import diamond.errors.checks;
import diamond.dom.domattribute;
import diamond.dom.domexception;
import diamond.dom.domparsersettings;

/// A dom node.
final class DomNode
{
  private:
  /// The name of the node.
  string _name;
  /// The parent of the node.
  DomNode _parent;
  /// The text of the node.
  string _text;
  /// The attributes of the node.
  DomAttribute[string] _attributes;
  /// The children of the node.
  DomNode[] _children;
  /// The parser settings used for the dom node.
  DomParserSettings _parserSettings;

  public:
  final:
  /**
  * Creates a new dom node.
  * Params:
  *   parent = The parent node.
  */
  this(DomNode parent) @safe
  {
    _parent = parent;
  }

  @property
  {
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

    /// Sets the text of the node. If the text contains valid dom, then it'll be parsed. To just set the text without parsing use rawText.
    void text(string newText) @safe
    {
      import diamond.dom.domparser;

      auto elements = parseDomElements(newText, _parserSettings);

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
    package(diamond.dom) void rawText(string text) @safe
    {
      enforce(text !is null, "There must be a text specified.");

      _text = text.strip();
    }

    /// Gets the parent of the node.
    DomNode parent() @safe { return _parent; }

    /// Gets the children of the node.
    DomNode[] children() @safe { return _children; }

    package(diamond.dom)
    {
      /// Gets the settings used to parse the dom node.
      DomParserSettings parserSettings() @safe { return _parserSettings; }

      /// Sets the settings used to parse the dom node.
      void parserSettings(DomParserSettings parserSettings) @safe
      {
        _parserSettings = parserSettings;
      }
    }
  }

  /**
  * Adds an attribute to the node.
  * Params:
  *   attribute = The attribute to add.
  */
  void addAttribute(DomAttribute attribute) @safe
  {
    if (!attribute)
    {
      throw new DomException("Cannot add a null attribute.");
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

    name = name.strip().toLower();

    if (!name.length)
    {
      return;
    }

    _attributes[name] = new DomAttribute(name, value);
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

    name = name.strip().toLower();

    _attributes.remove(name);
  }

  /**
  * Gets an attribute from the node.
  * Params:
  *   name = The name of the attribute to retrieve.
  * Returns:
  *   The attribute if present, otherwise null.
  */
  DomAttribute getAttribute(string name) @safe
  {
    if (!name)
    {
      return null;
    }

    name = name.strip().toLower();

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

    name = name.strip().toLower();

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
  * Gets all attributes.
  * Returns:
  *   An array of the attribute.
  */
  DomAttribute[] getAttributes() @trusted
  {
    return _attributes ? _attributes.values : [];
  }

  /**
  * Gets all attribute names.
  * Returns:
  *   An array of the attribute names.
  */
  string[] getAttributeNames() @trusted
  {
    return _attributes ? _attributes.keys : [];
  }

  /**
  * Adds a child to the dom node.
  * Params:
  *   child = The child to add.
  */
  void addChild(DomNode child) @safe
  {
    if (!child)
    {
      throw new DomException("Cannot add a null child.");
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
  DomNode[] getByTagName(string tagName, bool searchChildren = false) @safe
  {
    enforce(tagName !is null, "The tag cannot be null.");

    if (!searchChildren)
    {
      return _children ? (() @trusted { return _children.filter!(c => c.name.toLower() == tagName.toLower()).array; })() : [];
    }

    DomNode[] elements;

    tagName = tagName.strip().toLower();

    foreach (child; _children)
    {
      if (child.name.toLower() == tagName)
      {
        elements ~= child;
      }

      if (searchChildren)
      {
        elements ~= child.getByTagName(tagName, searchChildren);
      }
    }

    return elements ? elements : [];
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
  DomNode[] getByAttribute(string name, string value, bool searchChildren = false) @safe
  {
    enforce(name !is null, "The name cannot be null.");
    enforce(value !is null, "The value cannot be null.");

    DomNode[] elements;

    name = name.strip().toLower();
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
  DomNode[] getByAttributeName(string name, bool searchChildren = false) @safe
  {
    enforce(name !is null, "The name cannot be null.");

    DomNode[] elements;

    name = name.strip().toLower();

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

  DomNode[] querySelectorAll(string selector)
  {
    /// TODO: This ...
    return null;
  }

  DomNode querySelector(string selector)
  {
    /// TODO: This ...
    return null;
  }

  /**
  * Converts the node to a properly formatted dom node-string.
  * Params:
  *   index = The tab index of the node.
  * Returns:
  *   A string equivalent to the properly formatted dom node-string.
  */
  string toString(size_t index) @trusted
  {
    import std.string : format;
    import std.algorithm : map, filter;
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

      attributes ~= _attributes.values.filter!(a => a.name && a.name.strip().length).map!(a => "%s=\"%s\"".format(a.name, a.value)).array.join(" ");
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
    else if (_parserSettings && _parserSettings.isSelfClosingTag(_name))
    {
      return "%s<%s%s>\r\n".format(tabs, _name, attributes);
    }
    else
    {
      return "%s<%s%s />\r\n".format(tabs, _name, attributes);
    }
  }

  /**
  * Converts the node to a properly formatted dom node-string.
  * Returns:
  *   A string equivalent to the properly formatted dom node-string.
  */
  override string toString() @safe
  {
    return toString(0);
  }
}
