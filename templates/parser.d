/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.templates.parser;

import std.conv : to;
import std.algorithm : count;
import std.string : indexOf;

import diamond.templates.grammar;
import diamond.templates.contentmode;
import diamond.templates.characterincludemode;
import diamond.templates.part;

private
{
  // HACK: to make AA's with classes work at compile-time.
  @property grammars()
  {
    Grammar[char] grammars;
    grammars['['] = new Grammar(
      "metadata", '[', ']',
      ContentMode.metaContent, CharacterIncludeMode.none, false, false
    );

    grammars['<'] = new Grammar(
      "placeHolder", '<', '>',
      ContentMode.appendContentPlaceHolder, CharacterIncludeMode.none, false, false
    );

    grammars['{'] = new Grammar(
      "code", '{', '}',
      ContentMode.mixinContent, CharacterIncludeMode.none, false, false
    );

    grammars[':'] = new Grammar(
      "expression", ':', '\n',
      ContentMode.mixinContent, CharacterIncludeMode.none, false, true
    );

    grammars['='] = new Grammar(
      "expressionValue", '=', ';',
      ContentMode.appendContent, CharacterIncludeMode.none, false, true
    );

    grammars['('] = new Grammar(
      "escapedValue", '(', ')',
      ContentMode.appendContent, CharacterIncludeMode.none, false, false
    );

    grammars['$'] = new Grammar(
      "expressionEscaped", '$', ';',
      ContentMode.appendContent, CharacterIncludeMode.none, false, false,
      '=' // Character that must follow the first character after @
    );

    grammars['*'] = new Grammar(
      "comment", '*', '*',
      ContentMode.discardContent, CharacterIncludeMode.none, false, true
    );

    grammars['!'] = new Grammar(
      "section", '!', ':',
      ContentMode.discardContent, CharacterIncludeMode.none, false, true
    );

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.customGrammar, q{
      Grammar[char] customGrammars = {{extensionEntry}}.createGrammars();

      if (customGrammars)
      {
        foreach (key,value; customGrammars)
        {
          grammars[key] = value;
        }
      }
    });
    emitExtension();

    return grammars;
  }
}

/**
* Parses a diamond template.
* Params:
*   content = The content of the diamond template to parse.
* Returns:
*   An associative array of arrays holding the section's template parts.
*/
auto parseTemplate(string content)
{
  Part[][string] parts;

  auto current = new Part;
  size_t curlyBracketCount = 0;
  size_t squareBracketcount = 0;
  size_t parenthesisCount = 0;
  string currentSection = "";

  foreach (ref i; 0 .. content.length)
  {
    auto beforeChar = i > 0 ? content[i - 1] : '\0';
    auto currentChar = content[i];
    auto afterChar = i < (content.length - 1) ? content[i + 1] : '\0';
    auto beforeSecondaryChar = i > 1 ? content[i - 2] : '\0';

    if (currentChar == '@' && !current.currentGrammar)
    {
      if (current._content && current._content.length && afterChar != '.')
      {
        parts[currentSection] ~= current;
        current = new Part;
      }

      if (afterChar != '@' && afterChar != '.')
      {
        auto grammar = grammars.get(afterChar, null);

        if (grammar && beforeChar != '@')
        {
          current.currentGrammar = grammar;

          if (afterChar == ':')
          {
            auto searchSource = content[i .. $];
            searchSource = searchSource[0 .. searchSource.indexOf('\n')];

            curlyBracketCount += searchSource.count!(c => c == '{');
            squareBracketcount += searchSource.count!(c => c == '[');
            parenthesisCount += searchSource.count!(c => c == '(');

            curlyBracketCount -= searchSource.count!(c => c == '}');
            squareBracketcount -= searchSource.count!(c => c == ']');
            parenthesisCount -= searchSource.count!(c => c == ')');
          }
        }
        else
        {
          current._content ~= currentChar;
        }
      }
      else if (afterChar == '.')
      {
        current._content ~= currentChar;
      }
    }
    else
    {
      if (current.currentGrammar)
      {
        if (current.currentGrammar.mandatoryStartCharacter != '\0' &&
        beforeSecondaryChar == '@' &&
        beforeChar == current.currentGrammar.startCharacter &&
        currentChar == current.currentGrammar.mandatoryStartCharacter)
        {
          continue;
        }

        if (currentChar == current.currentGrammar.startCharacter &&
          (!current.currentGrammar.ignoreDepth || !current.isStart())
        )
        {
          current.increaseSeekIndex();

          if (current.isStart())
          {
            continue;
          }
        }
        else if (currentChar == current.currentGrammar.endCharacter)
        {
          current.decreaseSeekIndex();
        }
      }

      if (current.isEnd(currentChar))
      {
        switch (current.currentGrammar.characterIncludeMode)
        {
          case CharacterIncludeMode.start:
            current._content =
              to!string(current.currentGrammar.startCharacter)
              ~ current.content;
            break;

          case CharacterIncludeMode.end:
            current._content ~= current.currentGrammar.endCharacter;
            break;

          case CharacterIncludeMode.both:
            current._content =
              to!string(current.currentGrammar.startCharacter) ~
              current.content ~ to!string(current.currentGrammar.endCharacter);
            break;

          default: break;
        }

        if (current.currentGrammar &&
        current.currentGrammar.includeStatementCharacter)
        {
          current._content = "@" ~ current.content;
        }

        if (current._currentGrammar.name == "section")
        {
          import std.string : strip;

          auto sectionName = current.content ? current.content.strip() : "";

          currentSection = sectionName;
        }
        else
        {
          parts[currentSection] ~= current;
        }

        current = new Part;
      }
      else
      {
        // TODO: Simplify this ...
        if (curlyBracketCount && currentChar == '}')
        {
          curlyBracketCount--;

          parts[currentSection] ~= current;

          current = new Part;
          current.currentGrammar = grammars.get('{', null);
          current._content = "}";

          if (afterChar == ';')
          {
            current._content ~= ";";
            i++;
          }

          parts[currentSection] ~= current;

          current = new Part;
        }
        else if (squareBracketcount && currentChar == ']')
        {
          squareBracketcount--;

          parts[currentSection] ~= current;

          current = new Part;
          current.currentGrammar = grammars.get('{', null);
          current._content = "]";

          if (afterChar == ';')
          {
            current._content ~= ";";
            i++;
          }

          parts[currentSection] ~= current;

          current = new Part;
        }
        else if (parenthesisCount && currentChar == ')')
        {
          parenthesisCount--;

          parts[currentSection] ~= current;

          current = new Part;
          current.currentGrammar = grammars.get('{', null);
          current._content = ")";

          if (afterChar == ';')
          {
            current._content ~= ";";
            i++;
          }

          parts[currentSection] ~= current;

          current = new Part;
        }
        else
        {
          current._content ~= currentChar;
        }
      }
    }
  }

  parts[currentSection] ~= current;

  return parts;
}
