/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.porttypeparser;

import std.array : split, join;
import std.string : format;

import diamond.dom;
import diamond.xml;
import diamond.web.soap.message;
import diamond.web.soap.messageoperation;
import diamond.errors.exceptions.soapexception;

package(diamond.web.soap.parser):
/**
* Parses the port types of the wsdl file.
* Params:
*   root =              The root node of the wsdl file.
*   inputs =            The input messages.
*   outputs =           The output messages.
*   messageOperations = The message operations.
*/
string parsePortTypes(XmlNode root, SoapMessage[string] inputs, SoapMessage[string] outputs, out SoapMessageOperation[][string] messageOperations)
{
  static const portTypeInterfaceFormat = q{
interface I%s
{
  public:
%s
}
  };

  static const portTypeOperationFormat = "\t@SoapAction(\"%s\") %s %s(%s);\r\n";

  string result = "";

  auto portTypes = root.getByTagName("wsdl:portType");

  if (!portTypes || !portTypes.length)
  {
    portTypes = root.getByTagName("xs:portType");
  }

  if (!portTypes || !portTypes.length)
  {
    portTypes = root.getByTagName("xsd:portType");
  }

  if (!portTypes || !portTypes.length)
  {
    portTypes = root.getByTagName("portType");
  }

  if (portTypes && portTypes.length)
  {
    foreach (portType; portTypes)
    {
      auto name = portType.getAttribute("name");

      if (!name)
      {
        throw new SoapException("Missing name for portType.");
      }

      SoapMessageOperation[] portMessageOperations;

      auto operations = portType.getByTagName("wsdl:operation");

      if (!operations || !operations.length)
      {
        operations = portType.getByTagName("xs:operation");
      }

      if (!operations || !operations.length)
      {
        operations = portType.getByTagName("xsd:operation");
      }

      if (!operations || !operations.length)
      {
        operations = portType.getByTagName("operation");
      }

      string[] operationsResult;

      if (operations && operations.length)
      {
        foreach (operation; operations)
        {
          auto operationName = operation.getAttribute("name");

          if (!operationName)
          {
            throw new SoapException("Missing operation name.");
          }

          auto inputTags = operation.getByTagName("wsdl:input");

          if (!inputTags || !inputTags.length)
          {
            inputTags = operation.getByTagName("xs:input");
          }

          if (!inputTags || !inputTags.length)
          {
            inputTags = operation.getByTagName("xsd:input");
          }

          if (!inputTags || !inputTags.length)
          {
            inputTags = operation.getByTagName("input");
          }

          if (!inputTags || !inputTags.length)
          {
            throw new SoapException("Missing input from operation.");
          }

          auto outputTags = operation.getByTagName("wsdl:output");

          if (!outputTags || !outputTags.length)
          {
            outputTags = operation.getByTagName("xs:output");
          }

          if (!outputTags || !outputTags.length)
          {
            outputTags = operation.getByTagName("xsd:output");
          }

          if (!outputTags || !outputTags.length)
          {
            outputTags = operation.getByTagName("output");
          }

          if (!outputTags || !outputTags.length)
          {
            throw new SoapException("Missing output for operation.");
          }

          auto input = inputTags[0];
          auto output = outputTags[0];

          auto inputName = input.getAttribute("message").value;

          if (inputName.split(":").length == 2)
          {
            inputName = inputName.split(":")[1];
          }

          auto inputParameters = inputs.get(inputName, null);

          auto outputName = output.getAttribute("message").value;

          if (outputName.split(":").length == 2)
          {
            outputName = outputName.split(":")[1];
          }

          auto outputParameters = outputs.get(outputName, null);

          if (!outputParameters || !outputParameters.output)
          {
            throw new SoapException("Missing output parameters.");
          }

          auto action = input.getAttribute("wsaw:action");

          if (!action)
          {
            action = input.getAttribute("wsdl:action");
          }

          if (!action)
          {
            action = input.getAttribute("xs:action");
          }

          if (!action)
          {
            action = input.getAttribute("xsd:action");
          }

          if (!action)
          {
            action = input.getAttribute("action");
          }

          if (!action)
          {
            action = output.getAttribute("wsaw:action");
          }

          if (!action)
          {
            action = output.getAttribute("wsdl:action");
          }

          if (!action)
          {
            action = output.getAttribute("xs:action");
          }

          if (!action)
          {
            action = output.getAttribute("xsd:action");
          }

          if (!action)
          {
            action = output.getAttribute("action");
          }

          auto returnType = outputParameters.output.type;

          string[] parameters;

          if (inputParameters && inputParameters.input && inputParameters.input.length)
          {
            foreach (inputParameter; inputParameters.input)
            {
              parameters ~= "%s %s".format(inputParameter.type, inputParameter.name);
            }
          }

          auto portMessageOperation = new SoapMessageOperation(action ? action.value : "", operationName.value, returnType,  parameters ? parameters.join(",") : "");

          portMessageOperations ~= portMessageOperation;

          operationsResult ~= portTypeOperationFormat.format(portMessageOperation.action, portMessageOperation.returnType, portMessageOperation.name, portMessageOperation.parameters);
        }
      }

      if (portMessageOperations)
      {
        messageOperations[name.value] = portMessageOperations;
      }

      result ~= portTypeInterfaceFormat.format(name.value, operationsResult ? operationsResult.join("\r\n") : "");
    }
  }

  return result;
}
