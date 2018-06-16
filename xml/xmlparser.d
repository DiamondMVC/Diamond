/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xml.xmlparser;

import std.stdio;
import std.uni : isWhite;
import std.string : format, strip;

import diamond.xml.xmldocument;
import diamond.xml.xmlnode;
import diamond.xml.xmlattribute;
import diamond.xml.xmlexception;

/**
* Parses a string of xml into an xml document.
* Params:
*   xml = The xml string to parse.
* Returns:
*   The parsed xml document.
*/
XmlDocument parseXml(string xml) @safe
{
  auto doc = new XmlDocument;

  auto elements = parseXmlElements(xml, doc);

  if (!elements || elements.length != 2)
  {
    throw new XmlException("No xml header found or no root element found.");
  }

  auto header = elements[0];
  auto root = elements[1];

  auto versionAttribute = header.getAttribute("version");
  auto encodingAttribute = header.getAttribute("encoding");

  doc.xmlVersion = versionAttribute ? versionAttribute.value.strip() : null;
  doc.encoding = encodingAttribute ? encodingAttribute.value.strip() : "UTF-8";

  doc.root = root;

  return doc;
}

/**
* Parses an xml string into an array of xml nodes.
* Params:
*   xml =      The xml string to parse.
*   document = The associated document.
* Returns:
*   An array of the parsed xml nodes. Null if the string is not xml.
*/
package(diamond.xml) XmlNode[] parseXmlElements(string xml, XmlDocument document) @safe
{
  if (!xml || !xml.length)
  {
    return null;
  }

  xml = xml.strip();

  if (xml.length < 2)
  {
    return null;
  }

  if (xml[0] != '<' && xml[$-1] != '>')
  {
    return null;
  }

  XmlNode[] elements;
  XmlNode currentNode;
  bool isHeader;
  bool evaluated;
  string attributeName;
  string attributeValue;
  XmlAttribute attribute;
  string text;
  bool comment;

  foreach (ref i; 0 .. xml.length)
  {
    char last = i > 0 ? xml[i - 1] : '\0';
    char current = xml[i];
    char next =  i < (xml.length - 1) ? xml[i + 1] : '\0';

    if (!current || current == '\r' || (current == '\n' && !evaluated))
    {
      continue;
    }

    if (comment)
    {
      if (current == '-' && next == '-' && i < (xml.length - 2))
      {
        auto afterNext = xml[i + 2];

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
      if (next == '!' && i < (xml.length - 3))
      {
        auto afterNext = xml[i + 2];
        auto nextAfterNext = xml[i + 3];

        if (afterNext && nextAfterNext == '-')
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
        while (current != '>' && i < (xml.length - 1))
        {
          i++;

          if (i < (xml.length - 1))
          {
            last = i > 0 ? xml[i - 1] : '\0';
            current = xml[i];
            next =  i < (xml.length - 1) ? xml[i + 1] : '\0';
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
        if (next == '?')
        {
          isHeader = true;
          i++;
        }

        currentNode = new XmlNode(currentNode);
        currentNode.document = document;
        evaluated = false;
      }
    }
    else if (currentNode && current == '?' && isHeader)
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

      while (i < (xml.length - 1))
      {

        if (!current.isWhite)
        {
          name ~= current;
        }

        i++;

        if (i < (xml.length - 1))
        {
          last = i > 0 ? xml[i - 1] : '\0';
          current = xml[i];
          next =  i < (xml.length - 1) ? xml[i + 1] : '\0';
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
      if ((current == '\"' && (attributeValue || last == '\"')) || (current == '=' && !attribute))
      {
        if (!attribute)
        {
          attribute = new XmlAttribute(attributeName, null);
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
    else
    {
      throw new XmlException("Encountered unexpected character: '%s' at index: '%d'.".format(current, i));
    }
  }

  return elements;
}
