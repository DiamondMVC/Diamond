/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.element;

/// Wrapper around a html element.
abstract class Element
{
  private:
  /// The attributes of the element.
  string[string] _attributes;
  /// The tag name.
  string _tagName;
  /// Inner text representation.
  string _inner;
  /// The id of the element.
  string _id;
  /// The name of the element.
  string _name;

  protected:
  /// Generates the appropriate html for the element.
  abstract string generateHtml();

  public:
  final:
  /**
  * Creates a new html element.
  * Params:
  *   tagName = The name of the tag.
  */
  this(string tagName)
  {
    _tagName = tagName;
  }

  @property
  {
    /// Gets the tag name.
    string tagName() { return _tagName; }

    /// Gets the inner text representation.
    string inner() { return _inner; }

    /// Sets the inner text representation.
    void inner(string newInner)
    {
      _inner = newInner;
    }

    /// Gets the id of the element.
    string id() { return _id; }

    /// Sets the id of the element.
    void id(string newId)
    {
      _id = newId;
    }

    /// Gets the name of the element.
    string name() { return _name; }

    /// Sets the name of the element.
    void name(string newName)
    {
      _name = newName;
    }
  }

  /**
  * Adds an attribute to the html element.
  * Params:
  *   name =  The name of the attribute to add.
  *   value = The value of the attribute.
  */
  void addAttribute(T)(string name, T value)
  {
    import std.conv : to;

    _attributes[name] = to!string(value);
  }

  /**
  * Gets an attribute from the html element.
  * Params:
  *   name =          The name of the attribute.
  *   defaultValue =  The default value to return when the attribute wasn't found.
  * Returns:
  *   Returns the attribute's value if found, else the specified default value.
  */
  T getAttribute(T)(string name, T defaultValue = T.init)
  {
    auto value = _attributes.get(name, null);

    if (!value)
    {
      return defaultValue;
    }

    return to!T(value);
  }

  /// Gets the html representation of the element.
  override string toString()
  {
    return generateHtml();
  }

  /// Gets the attribute html.
  protected string attributeHtml()
  {
    import std.string : format;
    import std.array : join;

    string[] result;

    foreach (key,value; _attributes)
    {
      if (value)
      {
        result ~= "%s=\"%s\"".format(key,value);
      }
      else
      {
        result ~= key;
      }
    }

    return result ? result.join(" ") : "";
  }
}
