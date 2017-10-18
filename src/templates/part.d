/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.templates.part;

import diamond.templates.contentmode;
import diamond.templates.grammar;

/**
* Wrapper for a template part.
* Template parts are the aprsed parts of the view.
*/
final class Part
{
  package(diamond.templates):
  /// The name.
  immutable(string) _name;
  /// The current grammar.
  Grammar _currentGrammar;
  /// The seek index.
  size_t _seekIndex;
  /// The content.
  string _content;

  final:
  /// Creates a new template part.
  this()
  {
    _name = "html";
  }

  /// Increases the seek index.
  void increaseSeekIndex() pure nothrow
  {
    _seekIndex++;
  }

  /// Decreases the seek index.
  void decreaseSeekIndex() pure nothrow {
    _seekIndex--;
  }

  /**
  * Checks whether it's the start of the part or not.
  * Returns:
  *   True if it's start of the part, false otherwise.
  */
  auto isStart()
  {
    return _seekIndex == 1;
  }

  /**
  * Checks whether the current character will end the scope of this part.
  * Params:
  *   currentChar = The current char.
  * Returns:
  *   True if the character marks the end of the part, false otherwise.
  */
  auto isEnd(char currentChar) nothrow
  {
    return (_currentGrammar !is null &&
      currentChar == _currentGrammar.endCharacter && _seekIndex < 1);
  }

  @property
  {
    /// Sets the current grammar.
    void currentGrammar(const(Grammar) newGrammar)
    {
      _currentGrammar = cast(Grammar)newGrammar;
    }
  }

  public:
  @property
  {
    /// Gets the current grammar.
    auto currentGrammar() { return _currentGrammar; }

    /// Gets the name of the part.
    auto name() { return _currentGrammar ? _currentGrammar.name : _name; }

    /// Gets the content of the part.
    auto content() { return _content; }

    /// Gets the content mode.
    auto contentMode()
    {
      return !_currentGrammar ?
        ContentMode.appendContent : _currentGrammar.contentMode;
    }
  }
}
