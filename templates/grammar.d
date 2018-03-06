/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.templates.grammar;

import diamond.templates.contentmode;
import diamond.templates.characterincludemode;

/// A wrapper around the basic template grammar for parsing a diamond template.
final class Grammar
{
  private:
  /// The name.
  string _name;
  /// The start character.
  char _startCharacter;
  /// The end character.
  char _endCharacter;
  /// The content mode.
  ContentMode _contentMode;
  /// The character include mode.
  CharacterIncludeMode _characterIncludeMode;
  /// Boolean determining whether the statement character should be included.
  bool _includeStatementCharacter;
  /// Boolean determining whether the grammar should ignore depth of characters or not.
  bool _ignoreDepth;
  /// A character that must follow the start character.
  char _mandatoryStartCharacter;

  public:
  final:
  /**
  * Creates a new template grammar.
  * Params:
  *   name =            The name of the grammar.
  *   startCharacter =  The start character.
  *   endCharacter =    The end character.
  *   contentMode =               The content mode.
  *   characterIncludeMode =      The character include mode.
  *   includeStatementCharacter = Boolean determining whether the statement character should be included.
  */
  this(string name, char startCharacter, char endCharacter,
    ContentMode contentMode, CharacterIncludeMode characterIncludeMode,
    bool includeStatementCharacter, bool ignoreDepth,
    char mandatoryStartCharacter = '\0')
  {
    _name = name;
    _startCharacter = startCharacter;
    _endCharacter = endCharacter;
    _contentMode = contentMode;
    _characterIncludeMode = characterIncludeMode;
    _includeStatementCharacter = includeStatementCharacter;
    _ignoreDepth = ignoreDepth;
    _mandatoryStartCharacter = mandatoryStartCharacter;
  }

  @property {
    /// Gets the name.
    auto name() { return _name; }

    /// Gets the start character.
    auto startCharacter() { return _startCharacter; }

    /// Gets the end character.
    auto endCharacter() { return _endCharacter; }

    /// Gets the content mode.
    auto contentMode() { return _contentMode; }

    /// Gets the character include mode.
    auto characterIncludeMode() { return _characterIncludeMode; }

    /// Gets a boolean determining whether the statement character should be included.
    auto includeStatementCharacter() { return _includeStatementCharacter; }

    /// Gets a boolean determining whether the grammar should ignore depth or not.
    auto ignoreDepth() { return _ignoreDepth; }

    /// Gets a character that must follow the start character. '\0' indicates no character.
    auto mandatoryStartCharacter() { return _mandatoryStartCharacter; }
  }
}
