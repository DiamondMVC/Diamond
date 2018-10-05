/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.typeparser;

import std.string : toLower, strip, format;
import std.array : split;
import std.algorithm : endsWith;

import diamond.dom;
import diamond.xml;
import diamond.web.soap.soaptype;
import diamond.web.soap.complextype;
import diamond.web.soap.simpletype;
import diamond.web.soap.element;
import diamond.web.soap.aliastype;
import diamond.errors.exceptions.soapexception;

package(diamond.web.soap.parser):
/**
* Parses a schema.
* Params:
*   schema =    The schema to parse.
* Returns:
*   The parsed soap types from the schema.
*/
SoapType[] parseSchema(XmlNode schema)
{
  auto elementFormDefaultAttribute = schema.getAttribute("elementFormDefault");
  auto elementFormDefault = elementFormDefaultAttribute ? elementFormDefaultAttribute.value : "";

  auto targetNamespaceAttribute = schema.getAttribute("targetNamespace");
  auto targetNamespace = targetNamespaceAttribute ? targetNamespaceAttribute.value : "";

  if (!schema.children || !schema.children.length)
  {
    return null;
  }

  SoapType[] result;

  foreach (child; schema.children)
  {
    switch (child.name.toLower())
    {
      case "xs:complextype":
      case "xsd:complextype":
      {
        result ~= parseComplexType(child);
        break;
      }

      case "xs:simpletype":
      case "xsd:simpletype":
      {
        result ~= parseSimpleType(child);
        break;
      }

      case "xs:attribute": break; // Although unsupported, attributes such as unions shouldn't break parsing.
      case "xsd:attribute": break; // Although unsupported, attributes such as unions shouldn't break parsing.

      case "xs:element":
      case "xsd:element":
      {
        auto elementType = parseElementType(child);

        if (elementType)
        {
          result ~= elementType;
        }
        break;
      }

      default:
      {
        throw new SoapException("Unsupported type definition.");
      }
    }
  }

  return result;
}

/**
* Parses an element type.
* Params:
*   elementTypeNode = The element node.
* Returns:
*   A soap type equivalent to the parsed element type.
*/
SoapType parseElementType(XmlNode elementTypeNode)
{
  auto nameAttribute = elementTypeNode.getAttribute("name");
  auto name = nameAttribute ? nameAttribute.value.strip() : null;

  if (!name || !name.length)
  {
    throw new SoapException("Expected an element type name.");
  }

  if (!elementTypeNode.children || !elementTypeNode.children.length)
  {
    // The type might use an alias ...

    auto aliasType = elementTypeNode.getAttribute("type");

    if (aliasType && aliasType.value.split(":").length == 2)
    {
      return new SoapAliasType(name, aliasType.value.split(":")[1]);
    }

    return null;
  }

  auto type = elementTypeNode.children[0];

  if (type.name.toLower() != "xs:complextype" && type.name.toLower() != "xs:simpletype" && type.name.toLower() != "xsd:complextype" && type.name.toLower() != "xsd:simpletype")
  {
    throw new SoapException("Expected a simple or complex type for '%s'.".format(name));
  }

  final switch (type.name.toLower())
  {
    case "xs:complextype":
    case "xsd:complextype":
    {
      if (!type.hasAttribute("name"))
      {
        type.addAttribute("name", name);
      }

      auto complexType = parseComplexType(type);

      return complexType;
    }

    case "xs:simpletype":
    case "xsd:simpletype":
    {
      if (!type.hasAttribute("name"))
      {
        type.addAttribute("name", name);
      }

      auto simpleType = parseSimpleType(type);

      return simpleType;
    }
  }
}

/**
* Parses a simple type.
* Params:
*   simpleTypeNode = The simple type node.
* Returns:
*   The simple typed parsed.
*/
SoapSimpleType parseSimpleType(XmlNode simpleTypeNode)
{
  auto nameAttribute = simpleTypeNode.getAttribute("name");
  auto name = nameAttribute ? nameAttribute.value.strip() : null;

  if (!name || !name.length)
  {
    throw new SoapException("Expected a simple type name.");
  }

  if (!simpleTypeNode.children || simpleTypeNode.children.length != 1)
  {
    throw new SoapException("'%s' is either an empty simple type or has too many defintions.".format(name));
  }

  auto type = simpleTypeNode.children[0];

  switch (type.name.toLower())
  {
    case "xs:restriction":
    case "xsd:restriction":
    {
      auto baseAttribute = type.getAttribute("base");
      auto base = baseAttribute ? baseAttribute.value.strip() : null;

      if (!base || base.split(":").length != 2)
      {
        throw new SoapException("'%s' has no valid base type.");
      }

      base = base.split(":")[1];

      return new SoapSimpleType(name, base, SoapSimpleTypeDefinition.restriction);
    }

    case "xs:list":
    case "xsd:list":
    {
      auto itemTypeAttribute = type.getAttribute("itemType");
      auto itemType = itemTypeAttribute ? itemTypeAttribute.value.strip() : null;

      if (!itemType || itemType.split(":").length != 2)
      {
        throw new SoapException("'%s' has no valid item type.");
      }

      itemType = itemType.split(":")[1];

      return new SoapSimpleType(name, itemType, SoapSimpleTypeDefinition.list);
    }

    default:
    {
      throw new SoapException("Unsupported simple type definition.");
    }
  }
}

/**
* Parses a complex type.
* Params:
*   complexTypeNode = The complex node.
* Returns:
*   The complex node parsed.
*/
SoapComplexType parseComplexType(XmlNode complexTypeNode)
{
  auto nameAttribute = complexTypeNode.getAttribute("name");
  auto name = nameAttribute ? nameAttribute.value.strip() : null;

  if (!name || !name.length)
  {
    throw new SoapException("Expected a complex type name.");
  }

  if (!complexTypeNode.children || !complexTypeNode.children.length)
  {
    throw new SoapException("'%s' is an empty complex type.".format(name));
  }

  auto sequence = complexTypeNode.children[0];

  if (sequence.name.toLower() != "xs:sequence" && sequence.name.toLower() != "xsd:sequence")
  {
    throw new SoapException("Expected a sequence element for '%s'.".format(name));
  }

  auto complexType = new SoapComplexType(name);

  auto elements = sequence.getByTagName("xs:element");

  if (!elements)
  {
    elements = sequence.getByTagName("xsd:element");
  }

  if (elements && elements.length)
  {
    foreach (elementNode; elements)
    {
      auto element = parseElement(elementNode);

      complexType.addElement(element);
    }
  }

  return complexType;
}

/**
* Parses an element.
* Params:
*   elementNode = The element.
* Returns:
*   A soap element equivalent to the element node.
*/
SoapElement parseElement(XmlNode elementNode)
{
  auto nameAttribute = elementNode.getAttribute("name");
  auto name = nameAttribute ? nameAttribute.value.strip() : null;

  if (!name || !name.length)
  {
    throw new SoapException("Expected an element name.");
  }

  auto typeAttribute = elementNode.getAttribute("type");
  auto type = typeAttribute ? typeAttribute.value.strip() : null;

  if (!type || type.split(":").length != 2)
  {
    throw new SoapException("Element '%s' has no type.".format(name));
  }

  type = type.split(":")[1];

  if (elementNode.hasAttribute("maxOccurs") && elementNode.getAttribute("maxOccurs").value.strip().toLower() == "unbounded" && type != "string")
  {
    type ~= "[]";
  }

  return new SoapElement(name, type);
}

/**
* Parses an array of soap types into d types.
* Params:
*   soapTypes = The array of soap types.
* Returns:
*   A string equivalent to all the d types.
*/
string parseDTypes(SoapType[] soapTypes)
{
  if (!soapTypes || !soapTypes.length)
  {
    return "";
  }

  string result;

  enum classTypeFormat = q{
final class %s : SoapEnvelopeType
{
  public:
  final:
  this() {}

%s}
  };

  enum classTypeElementFormat = "  %s %s;\r\n";

  enum aliasTypeFormat = "public alias %s = %s;\r\n";

  foreach (type; soapTypes)
  {
    auto complex = cast(SoapComplexType)type;

    if (complex)
    {
      string elementResult = "";

      if (complex.elements)
      {
        foreach (element; complex.elements)
        {
          if (complex.elements.length == 1 && element.type.endsWith("[]"))
          {
            elementResult ~= classTypeElementFormat.format(element.type, "_array_");
            elementResult ~= classTypeElementFormat.format("alias", "_array_ this");
          }
          else if (element.type == element.name)
          {
            elementResult ~= classTypeElementFormat.format(element.type, "_%s_".format(element.name));
          }
          else
          {
            elementResult ~= classTypeElementFormat.format(element.type, element.name);
          }
        }
      }

      result ~= classTypeFormat.format(complex.name, elementResult);
      continue;
    }

    auto simpleType = cast(SoapSimpleType)type;

    if (simpleType)
    {
      final switch (simpleType.definition)
      {
        case SoapSimpleTypeDefinition.restriction:
        {
          result ~= aliasTypeFormat.format(simpleType.name, simpleType.typeName);
          break;
        }

        case SoapSimpleTypeDefinition.list:
        {
          auto listTypeResult = classTypeElementFormat.format(simpleType.typeName, "_value_");
          listTypeResult ~= classTypeElementFormat.format("alias", "_value_ this");

          result ~= classTypeFormat.format(simpleType.name, listTypeResult);
          break;
        }
      }
      continue;
    }

    auto aliasType = cast(SoapAliasType)type;

    if (aliasType)
    {
      result ~= aliasTypeFormat.format(aliasType.name, aliasType.aliasName);
      continue;
    }
  }

  return result ? result : "";
}
