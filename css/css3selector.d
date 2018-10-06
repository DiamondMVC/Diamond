/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.css.css3selector;

import std.uni : isWhite;
import std.string : format, strip, stripLeft, stripRight, toLower, indexOf;

/// Wrapper around a css3 selection query.
final class Css3SelectionQuery
{
  private:
  /// The parent.
  Css3SelectionQuery _parent;
  /// The selector.
  string _selector;
  /// The selections.
  Css3Selection[] _selections;
  /// The next selection query.
  Css3SelectionQuery _nextSelection;
  /// The operator.
  Css3SelectorOperator _operator;

  public:
  final:
  /// Creates a new css3 selection query.
  this() @safe { }

  @property
  {
    /// Gets the parent.
    Css3SelectionQuery parent() @safe { return _parent; }

    /// Gets the selections.
    Css3Selection[] selections() @safe { return _selections; }

    /// Gets the next selection.
    Css3SelectionQuery nextSelection() @safe { return _nextSelection; }

    /// Gets the operator.
    Css3SelectorOperator operator() @safe { return _operator; }
  }
}

/// Enumeration around css3 selector operators.
enum Css3SelectorOperator
{
  /// No selection.
  none,
  /// This is the ">" operator.
  firstChild,
  /// This is the "+" operator.
  firstSibling,
  /// This is a space.
  allChildren,
  /// This is the "~" operator.
  allSiblings
}

/// Wrapper around a css3 selection.
final class Css3Selection
{
  private:
  /// Boolean determining whether the selection has a wildcard or not.
  bool _hasWildcard;
  /// Tag names.
  string[] _tagNames;
  /// Ids.
  string[] _ids;
  /// Class names.
  string[] _classNames;
  /// States.
  string[] _states;
  /// The attribute selection.
  Css3AttributeSelection _attributeSelection;
  /// The attribute selector.
  public string _attributeSelector;

  public:
  final:
  /// Creates a new css3 selection.
  this() @safe { }

  @property
  {
    /// Gets a boolean determining whether the selection hs a wildcard or not.
    bool hasWildcard() @safe { return _hasWildcard; }

    /// Gets the tag names.
    string[] tagNames() @safe { return _tagNames; }

    /// Gets the ids.
    string[] ids() @safe { return _ids; }

    /// Gets the class names.
    string[] classNames() @safe { return _classNames; }

    /// Gets the states.
    string[] states() @safe { return _states; }

    /// Gets the attribute selection.
    Css3AttributeSelection attributeSelection() @safe { return _attributeSelection; }
  }
}

/// Wrapper around a css3 attribute selection.
final class Css3AttributeSelection
{
  private:
  /// The name.
  string _name;
  /// The value.
  string _value;
  /// The attribute operator.
  Css3SelectorAttributeOperator _operator;

  public:
  final:
  /// Creates a new css3 attribute selection.
  this() @safe { }

  @property
  {
    /// Gets the name.
    string name() @safe { return _name; }

    /// Gets the value.
    string value() @safe { return _value; }

    /// Gets the operator.
    Css3SelectorAttributeOperator operator() @safe { return _operator; }
  }
}

/// Enumeration o dom selector attribute operators.
enum Css3SelectorAttributeOperator
{
  /// No operation.
  none,
  /// This is the "=" operator.
  equals,
  /// This is the "~=" operator.
  containsWord,
  /// This is the "|=" operator.
  listStartsWith,
  /// This is the "^=" operator.
  startsWith,
  /// This is the "$=" operator.
  endsWith,
  /// This is the "*=" operator.
  contains
}

/**
* Parses a css3 selector into a css3 selection query.
* Params:
*   selector = The selector to parse.
* Returns:
*   The css3 selection query.
*/
Css3SelectionQuery parseCss3Selector(string selector) @safe
{
  auto query = parseParts(selector);

  Css3SelectionQuery current = query;

  while (current)
  {
    current._selections ~= parsePart(current._selector);

    if (current._selections)
    {
      foreach (selection; current._selections)
      {
        selection._attributeSelection = parseAttribute(selection._attributeSelector);
      }
    }

    current = current._nextSelection;
  }

  return query;
}

private:
/**
* Parses the css3 parts.
* Params:
*   selector = The selector.
* Returns:
*   The css3 selection query with its parsed parts.
*/
Css3SelectionQuery parseParts(string selector) @safe
{
  if (!selector || !selector.length)
  {
    return null;
  }

  bool inAttribute;
  Css3SelectionQuery root = new Css3SelectionQuery;
  Css3SelectionQuery currentQuery = root;

  foreach (ref i; 0 .. selector.length)
  {
    char last = i > 0 ? selector[i - 1] : '\0';
    char current = selector[i];
    char next =  i < (selector.length - 1) ? selector[i + 1] : '\0';

    if (current == '[' && !inAttribute)
    {
      inAttribute = true;
      currentQuery._selector ~= current;
    }
    else if (current == ']' && inAttribute)
    {
      inAttribute = false;
      currentQuery._selector ~= current;
    }
    else if (currentQuery._selector && currentQuery._selector.length && !inAttribute && (current == '>' || current == '+' || current == '~' || (current.isWhite && (next != '>' && next != '+' && next != '~'))))
    {
      auto temp = new Css3SelectionQuery;
      temp._parent = currentQuery;

      switch (current)
      {
        case '>':
          currentQuery._operator = Css3SelectorOperator.firstChild;

          currentQuery._nextSelection = temp;
          currentQuery = temp;
          break;

        case '+':
          currentQuery._operator = Css3SelectorOperator.firstSibling;

          currentQuery._nextSelection = temp;
          currentQuery = temp;
          break;

        case '~':
          currentQuery._operator = Css3SelectorOperator.allSiblings;

          currentQuery._nextSelection = temp;
          currentQuery = temp;
          break;

        default:
        {
          if (current.isWhite)
          {
            currentQuery._operator = Css3SelectorOperator.allChildren;

            currentQuery._nextSelection = temp;
            currentQuery = temp;
          }
          break;
        }
      }
    }
    else if (!current.isWhite || inAttribute)
    {
      currentQuery._selector ~= current;
    }
  }

  return root;
}

/**
* Parses a selection part.
* Params:
*   selector = The selector part to parse.
* Returns:
*   An array of the part's selections.
*/
Css3Selection[] parsePart(string selector) @safe
{
  if (!selector || !selector.length)
  {
    return null;
  }

  Css3Selection[] selections;

  auto selection = new Css3Selection;
  string currentAttributeSelector;
  string identifier;
  string state;
  bool isClass;
  bool isId;
  bool isState;

  void finalizeSelection() @safe
  {
    if (identifier && identifier.length && selection)
    {
      if (isClass)
      {
        selection._classNames ~= identifier;
      }
      else if (isId)
      {
        selection._ids ~= identifier;
      }
      else if (identifier.strip() == "*")
      {
        selection._hasWildcard = true;
      }
      else
      {
        selection._tagNames ~= identifier;
      }
    }

    if (state && state.length && selection)
    {
      selection._states ~= state;
    }

    isState = false;
    isClass = false;
    isId = false;
    identifier = null;
    state = null;
  }

  foreach (i; 0 .. selector.length)
  {
    char last = i > 0 ? selector[i - 1] : '\0';
    char current = selector[i];
    char next =  i < (selector.length - 1) ? selector[i + 1] : '\0';

    if (current == '[' && !currentAttributeSelector)
    {
      finalizeSelection();

      currentAttributeSelector = "";
    }
    else if (current == ']' && currentAttributeSelector)
    {
      selection._attributeSelector = currentAttributeSelector;
      currentAttributeSelector = null;

      selections ~= selection;
      selection = new Css3Selection;
    }
    else if (currentAttributeSelector)
    {
      currentAttributeSelector ~= current;
    }
    else if (current == '.')
    {
      finalizeSelection();

      isClass = true;
    }
    else if (current == '#')
    {
      finalizeSelection();

      isId = true;
    }
    else if (current == ':')
    {
      isState = true;
    }
    else if (isState)
    {
      state ~= current;
    }
    else
    {
      identifier ~= current;
    }
  }

  finalizeSelection();

  if (selection._tagNames || selection._ids || selection._classNames || selection._attributeSelector || selection._states)
  {
    selections ~= selection;
  }

  return selections;
}

/**
* Parses an attribute selector.
* Params:
*   selector = The attribute selector to parse.
* Returns:
*   THe css3 attribute selection.
*/
Css3AttributeSelection parseAttribute(string selector) @safe
{
  auto attribute = new Css3AttributeSelection;
  string name;
  string value;

  foreach (i; 0 .. selector.length)
  {
    char last = i > 0 ? selector[i - 1] : '\0';
    char current = selector[i];
    char next =  i < (selector.length - 1) ? selector[i + 1] : '\0';

    if (attribute._operator)
    {
      value ~= current;
    }
    else if (current == '=')
    {
      switch (last)
      {
        case '~':
          attribute._operator = Css3SelectorAttributeOperator.containsWord;
          break;

        case '|':
          attribute._operator = Css3SelectorAttributeOperator.listStartsWith;
          break;

        case '^':
          attribute._operator = Css3SelectorAttributeOperator.startsWith;
          break;

        case '$':
          attribute._operator = Css3SelectorAttributeOperator.endsWith;
          break;

        case '*':
          attribute._operator = Css3SelectorAttributeOperator.contains;
          break;

        default:
          attribute._operator = Css3SelectorAttributeOperator.equals;
          break;
      }
    }
    else if (current != '=' && current != '~' && current != '|' && current != '^' && current != '$' && current != '*')
    {
      name ~= current;
    }
  }

  if (name && name.length)
  {
    attribute._name = name.strip().stripLeft("'").stripRight("'").stripLeft("\"").stripRight("\"");
  }

  if (value && value.length)
  {
    attribute._value = value.strip().stripLeft("'").stripRight("'").stripLeft("\"").stripRight("\"");
  }

  return attribute;
}
