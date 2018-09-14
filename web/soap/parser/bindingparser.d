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
import diamond.web.soap.messageoperation;
import diamond.errors.exceptions.soapexception;

package(diamond.web.soap.parser):
/**
* Parses the bindings of the wsdl file.
* Params:
*   root =       The root node of the wsdl file.
*   operations = The message operations.
*/
string parseBinding(XmlNode root, SoapMessageOperation[][string] operations)
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

%s
}
  };

  static const bindingOperationFormat = "\t@SoapOperation(\"%s\") %s %s(%s) { mixin SoapBindingMethod!(%s); mixin(executeSoapBinding()); }\r\n";

/*private string parameters(alias T)()
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
}*/

  string result = q{
private mixin template SoapBindingMethod(alias f)
{
  string executeSoapBinding()
  {
    return "return new SoapClient.sendRequestFromFunctionDefinition!(" ~ __stdtraits.fullyQualifiedName!f ~ ")(" ~ __stdtraits.ParameterIdentifierTuple!f ~ ");";
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

      auto bindingOperations = operations.get(typeName, null);

      string operationsResult = "";

      if (bindingOperations && bindingOperations.length)
      {
        foreach (bindingOperation; bindingOperations)
        {
          auto bindingOperationNodes = bindingType.getByAttribute("name", bindingOperation.name);
          auto bindingOperationNode = bindingOperationNodes && bindingOperationNodes.length ? bindingOperationNodes[0] : null;

          if (bindingOperationNode && (bindingOperationNode.name == "wsdl:operation" || bindingOperationNode.name == "xs:operation" || bindingOperationNode.name == "xsd:operation" || bindingOperationNode.name == "operation"))
          {
            auto soapOperations = bindingOperationNode.getByTagName("soap:operation");
            auto soapOperation = soapOperations && soapOperations.length ? soapOperations[0] : null;

            auto action = soapOperation && soapOperation.hasAttribute("soapAction") ? soapOperation.getAttribute("soapAction").value : bindingOperation.action;

            if (!action)
            {
              action = "";
            }

            operationsResult ~= bindingOperationFormat.format(action, bindingOperation.returnType, bindingOperation.name, bindingOperation.parameters, "I" ~ typeName ~ "." ~ bindingOperation.name);
          }
        }
      }

      result ~= bindingClassFormat.format(name.value, typeName, operationsResult);
    }
  }

  return result;
}
