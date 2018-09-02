/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.messageparser;

import std.algorithm : startsWith;
import std.array : split;

import diamond.core.collections;
import diamond.xml;
import diamond.web.soap.message;
import diamond.web.soap.parameter;
import diamond.errors.exceptions.soapexception;

package(diamond.web.soap.parser):
/**
* Parses the messages of the wsdl file.
* Params:
*   moduleName =  The name of the module.
*   typeNames =   A hashset of all type names within the wsdl file.
*   root =        The root node of the wsdl file.
*   inputs =      The input messages.
*   outputs =     The output messages.
*/
void parseMessages(string moduleName, HashSet!string typeNames, XmlNode root, out SoapMessage[string] inputs, out SoapMessage[string] outputs)
{
  auto messages = root.getByTagName("wsdl:message");

  if (!messages || !messages.length)
  {
    messages = root.getByTagName("xs:messages");
  }

  if (!messages || !messages.length)
  {
    messages = root.getByTagName("xsd:messages");
  }

  if (!messages || !messages.length)
  {
    messages = root.getByTagName("messages");
  }

  if (messages && messages.length)
  {
    foreach (i; 0 .. messages.length)
    {
      auto input = messages[i];
      auto output = (i + 1) < messages.length ? messages[i + 1] : null;

      if (!output)
      {
        break;
      }

      auto message = new SoapMessage(input.getAttribute("name").value, output.getAttribute("name").value);

      auto inputParameters = input.getByTagName("wsdl:part");

      if (!inputParameters || !inputParameters.length)
      {
        inputParameters = input.getByTagName("xs:part");
      }

      if (!inputParameters || !inputParameters.length)
      {
        inputParameters = input.getByTagName("xsd:part");
      }

      if (!inputParameters || !inputParameters.length)
      {
        inputParameters = input.getByTagName("part");
      }

      if (inputParameters && inputParameters.length)
      {
        foreach (inputParameter; inputParameters)
        {
          auto name = inputParameter.getAttribute("name");
          auto element = inputParameter.getAttribute("element");

          if (!name || !element)
          {
            throw new SoapException("Missing name or element for input message part.");
          }

          auto elementName = element.value.split(":").length == 2 ? element.value.split(":")[1] : element.value;

          if (!element.value.startsWith("tns:") || typeNames.has(elementName))
          {
            if (element.value.startsWith("tns:"))
            {
              elementName = moduleName ~ "." ~ elementName;
            }

            message.addInputParameter(name.value, elementName);
          }
        }
      }

      auto outputParameters = output.getByTagName("wsdl:part");

      if (!outputParameters || !outputParameters.length)
      {
        outputParameters = output.getByTagName("xs:part");
      }

      if (!outputParameters || !outputParameters.length)
      {
        outputParameters = output.getByTagName("xsd:part");
      }

      if (!outputParameters || !outputParameters.length)
      {
        outputParameters = output.getByTagName("part");
      }

      if (outputParameters && outputParameters.length)
      {
        if (outputParameters.length != 1)
        {
          throw new SoapException("No support for multiple output parameters.");
        }

        auto outputParameter = outputParameters[0];

        auto name = outputParameter.getAttribute("name");
        auto element = outputParameter.getAttribute("element");

        if (!name || !element)
        {
          throw new SoapException("Missing name or element for output message part.");
        }

        auto elementName = element.value.split(":").length == 2 ? element.value.split(":")[1] : element.value;

        if (!element.value.startsWith("tns:") || typeNames.has(elementName))
        {
          message.output = new SoapParameter(name.value, elementName);
        }
      }

      inputs[message.inputName] = message;
      outputs[message.outputName] = message;
    }
  }
}
