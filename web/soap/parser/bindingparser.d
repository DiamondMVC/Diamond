/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.bindingparser;

import std.array : split, join;
import std.string : format;

import diamond.xml;
import diamond.web.soap.message;
import diamond.errors.exceptions.soapexception;

package(diamond.web.soap.parser):
/**
* Parses the bindings of the wsdl file.
* Params:
*   root =       The root node of the wsdl file.
*   inputs =     The input messages.
*   outputs =    The output messages.
*/
string parseBinding(XmlNode root, SoapMessage[string] inputs, SoapMessage[string] outputs)
{
  // TODO:
  /*
  1. Create a class with the name attribute which inherits interface from type attribute
  2. Loop through operation tags
  3. Create the method with parameters.
  4. Body has to create the soap envelop message and call using soap client.
  5. Ignore everything else, because it's verbose information we already havve extracted and got.
  */

  static const bindingClassFormat = q{
final class %s : SoapBinding, I%s
{
  public:
  final:
  this()
  {
    super();
  }

  import __stdtraits = std.traits;

  static foreach (member; __traits(derivedMembers, I%s))
  {
    mixin
    (
      mixin("(__stdtraits.ReturnType!" ~ member ~ ").stringof") ~
      " " ~
      member ~
      "(" ~
        mixin("parameters!" ~ member) ~
      ") { mixin SoapBindingMethod!(); mixin(executeSoapBinding()); }"
    );
  }
}
  };

  static const bindingOperationFormat = "\t%s %s(%s);";

  string result = q{
private string parameters(alias T)()
{
  import __stdtraits = std.traits;
  import std.array : join;

  string[] result;
  enum paramsId = [__stdtraits.ParameterIdentifierTuple!T];

  static foreach (i; 0 .. paramsId.length)
  {
      result ~= __stdtraits.Parameters!T[i].stringof ~ " " ~ paramsId[i];
  }

  return result.join(",");
}

private mixin template SoapBindingMethod()
{
  string executeSoapBinding()
  {
    // TODO: Execute the soap binding ...
    // TODO: Requires the soap client to be implemented.

    return "return null;";
  }
}
  };

  auto bindingTypes = root.getByTagName("wsdl:binding");

  if (!bindingTypes || !bindingTypes.length)
  {
    bindingTypes = root.getByTagName("xs:binding");
  }

  if (!bindingTypes || !bindingTypes.length)
  {
    bindingTypes = root.getByTagName("xsd:binding");
  }

  if (!bindingTypes || !bindingTypes.length)
  {
    bindingTypes = root.getByTagName("binding");
  }

  if (bindingTypes && bindingTypes.length)
  {
    foreach (bindingType; bindingTypes)
    {
      auto name = bindingType.getAttribute("name");

      if (!name)
      {
        throw new SoapException("Missing name for binding.");
      }

      auto type = bindingType.getAttribute("type");

      if (!type)
      {
        throw new SoapException("Missing type for binding.");
      }

      auto typeName = type.value.split(":").length == 2 ? type.value.split(":")[1] : type.value;

      result ~= bindingClassFormat.format(name.value, typeName, typeName);
    }
  }

  return result;
}
