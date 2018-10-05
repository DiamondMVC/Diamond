/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.dom.domparser;

import std.uni : isWhite;
import std.string : format, strip, toLower, indexOf;

import diamond.dom.domdocument;
import diamond.dom.domnode;
import diamond.dom.domattribute;
import diamond.dom.domexception;
import diamond.dom.domparsersettings;
import diamond.errors.checks;

/**
* Parses a string of dom into an dom document.
* Params:
*   dom =            The dom string to parse.
*   parserSettings = The settings used for parsing.
* Returns:
*   The parsed dom document.
*/
TDocument parseDom(TDocument : DomDocument)(string dom, DomParserSettings parserSettings) @safe
{
  enforce(parserSettings !is null, "Missing parsing settings.");

  auto doc = new TDocument;

  auto elements = parseDomElements(dom, parserSettings);

  doc.parseElements(elements);

  return doc;
}

/**
* Parses an dom string into an array of dom nodes.
* Params:
*   dom =           The dom string to parse.
*   parserSettings = The settings used for parsing.
* Returns:
*   An array of the parsed dom nodes. Null if the string is not dom.
*/
package(diamond.dom) DomNode[] parseDomElements(string dom, DomParserSettings parserSettings) @safe
{
  enforce(parserSettings !is null, "Missing parsing settings.");

  if (!dom || !dom.length)
  {
    return null;
  }

  dom = dom.strip();

  if (dom.length < 2)
  {
    return null;
  }

  if (dom[0] != '<' && dom[$-1] != '>')
  {
    return null;
  }

  DomNode[] elements;
  DomNode currentNode;
  bool isHeader;
  bool evaluated;
  string attributeName;
  string attributeValue;
  DomAttribute attribute;
  string text;
  bool comment;
  char headerChar;

  foreach (ref i; 0 .. dom.length)
  {
    char last = i > 0 ? dom[i - 1] : '\0';
    char current = dom[i];
    char next =  i < (dom.length - 1) ? dom[i + 1] : '\0';

    if (currentNode && evaluated && parserSettings.isFlexibleTag(currentNode.name))
    {
      string content = "";
      bool inString;
      char stringChar;

      auto j = i;

      while (j < (dom.length - 1))
      {
        last = j > 0 ? dom[j - 1] : '\0';
        current = dom[j];
        next =  j < (dom.length - 1) ? dom[j + 1] : '\0';

        if ((current == '\"' || current == '\'') && !inString)
        {
          stringChar = current;
          inString = true;
        }
        else if (current == stringChar && inString)
        {
          inString = false;
        }

        if (current == '<' && next == '/' && !inString)
        {
          auto endIndex = dom[j .. $].indexOf('>');

          auto fromLen = j + 2;
          auto toLen = fromLen + (endIndex - 2);

          if (endIndex >= 0 && dom[fromLen .. (toLen > $ ? $ : toLen)].toLower() == currentNode.name)
          {
            j = toLen;
            break;
          }
        }

        content ~= current;
        j++;
      }

      i = j + 1;

      currentNode.rawText = content;

      if (currentNode.parent)
      {
        currentNode.parent.addChild(currentNode);
      }
      else
      {
        elements ~= currentNode;
      }

      currentNode = currentNode.parent;
      continue;
    }

    if (!current || current == '\r' || (current == '\n' && !evaluated))
    {
      continue;
    }

    if (comment)
    {
      if (current == '-' && next == '-' && i < (dom.length - 2))
      {
        auto afterNext = dom[i + 2];

        if (afterNext == '>')
        {
          comment = false;
           i += 3;
        }
      }

      continue;
    }

    if (current == '<')
    {
      if (next == '!' && i < (dom.length - 3))
      {
        auto afterNext = dom[i + 2];
        auto nextAfterNext = dom[i + 3];

        if (afterNext == '-' && nextAfterNext == '-')
        {
          comment = true;
          i += 4;
          continue;
        }
      }

      if (currentNode && text && text.length)
      {
        currentNode.rawText = text;
        text = null;
      }

      if (currentNode && next == '/')
      {
        while (current != '>' && i < (dom.length - 1))
        {
          i++;

          if (i < (dom.length - 1))
          {
            last = i > 0 ? dom[i - 1] : '\0';
            current = dom[i];
            next =  i < (dom.length - 1) ? dom[i + 1] : '\0';
          }
        }

        if (currentNode.parent)
        {
          currentNode.parent.addChild(currentNode);
        }
        else
        {
          elements ~= currentNode;
        }

        currentNode = currentNode.parent;
      }
      else
      {
        if (next == '?' || next == '!')
        {
          isHeader = true;
          headerChar = next;
          i++;
        }

        currentNode = new DomNode(currentNode);
        currentNode.parserSettings = parserSettings;
        evaluated = false;
      }
    }
    else if (currentNode && (current == '?' || current == '!') && isHeader)
    {
      continue;
    }
    else if (currentNode && current == '/' && next == '>')
    {
      i++;

      if (currentNode.parent)
      {
        currentNode.parent.addChild(currentNode);
      }
      else
      {
        elements ~= currentNode;
      }

      currentNode = currentNode.parent;
    }
    else if (current == '>')
    {
      if (currentNode && last == '/')
      {
        if (currentNode.parent)
        {
          currentNode.parent.addChild(currentNode);
        }
        else
        {
          elements ~= currentNode;
        }

        currentNode = currentNode.parent;
      }
      else if (currentNode && isHeader && headerChar == '!')
      {
        headerChar = '\0';
        elements ~= currentNode;
        isHeader = false;
        currentNode = null;
      }
      else if (currentNode && isHeader && last == '?')
      {
        elements ~= currentNode;
        isHeader = false;
        currentNode = null;
      }
      else if (currentNode)
      {
        evaluated = true;
      }
    }
    else if (currentNode && !currentNode.name)
    {
      string name;

      while (i < (dom.length - 1))
      {
        if (!current.isWhite)
        {
          name ~= current;
        }

        i++;

        if (i < (dom.length - 1))
        {
          last = i > 0 ? dom[i - 1] : '\0';
          current = dom[i];
          next =  i < (dom.length - 1) ? dom[i + 1] : '\0';
        }

        if (current.isWhite || current == '>' || current == '/')
        {
          if (current == '>')
          {
            evaluated = true;
          }

          if (current == '/')
          {
            evaluated = true;
            i--;
          }
          break;
        }
      }

      currentNode.name = name;
    }
    else if (currentNode && !evaluated)
    {
      if (!attribute && current == '\"')
      {
        auto j = i;
        DomAttribute tempAttribute;

        while (j < (dom.length - 1))
        {
          j++;

          if (dom[j] == '\"')
          {
            tempAttribute = new DomAttribute(dom[i .. j + 1], null);
            currentNode.addAttribute(tempAttribute);
            break;
          }
        }

        if (tempAttribute)
        {
          i = j;

          continue;
        }
      }

      if ((next.isWhite || next == '>') && !attribute && attributeName && attributeName.length)
      {
        attributeName ~= current;

        attribute = new DomAttribute(attributeName, null);

        currentNode.addAttribute(attribute);

        attribute = null;
        attributeName = null;
        attributeValue = null;
        continue;
      }

      if ((current == '\"' && (attributeValue || last == '\"')) || (current == '=' && !attribute))
      {
        if (!attribute)
        {
          attribute = new DomAttribute(attributeName, null);
        }
        else
        {
          attribute.value = attributeValue;

          currentNode.addAttribute(attribute);

          attribute = null;
          attributeName = null;
          attributeValue = null;
        }
      }
      else if (!attribute)
      {
        attributeName ~= current;
      }
      else if (((current == '\"' && last != '=') || current != '\"'))
      {
        attributeValue ~= current;
      }
    }
    else if (currentNode && evaluated)
    {
      text ~= current;
    }
    else if (parserSettings.strictParsing)
    {
      throw new DomException("Encountered unexpected character: '%s' at index: '%d'.".format(current, i));
    }
  }

  return elements;
}
