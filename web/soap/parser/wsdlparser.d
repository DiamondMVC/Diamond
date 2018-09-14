/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.wsdlparser;

import std.string : format;
import std.file : write, exists, mkdir;

import diamond.xml;

/**
* Parses a wsdl document into a d module.
* Params:
*   name =       The name of the service.
*   wsdl =       The path to the wsdl file.
*   document =   The wsdl document.
*   moduleName = The name of the resulting d module.
*/
package(diamond.web.soap) void parseWsdl(string name, string wsdl, XmlDocument document, string moduleName)
{
  import diamond.web.soap.parser.typeparser;
  import diamond.web.soap.parser.messageparser;
  import diamond.web.soap.parser.porttypeparser;
  import diamond.web.soap.parser.bindingparser;
  import diamond.web.soap.parser.serviceparser;

  auto types = document.root.getByTagName("types");

  if (!types || types.length != 1)
  {
    types = document.root.getByTagName("wsdl:types");
  }

  if (!types || types.length != 1)
  {
    types = document.root.getByTagName("xs:types");
  }

  if (!types || types.length != 1)
  {
    types = document.root.getByTagName("xsd:types");
  }

  if (!types || types.length != 1)
  {
    return;
  }

  auto schemas = types[0].getByTagName("xs:schema");

  if (!schemas || !schemas.length)
  {
    schemas = types[0].getByTagName("xsd:schema");
  }

  if (!schemas || !schemas.length)
  {
    schemas = types[0].getByTagName("wsdl:schema");
  }

  if (!schemas || !schemas.length)
  {
    schemas = types[0].getByTagName("schema");
  }

  if (!schemas || !schemas.length)
  {
    return;
  }

  string wsdlResult = q{/**
* This file was generated by Diamond MVC - https://diamondmvc.org/
* Service: %s
* Module: %s
* Wsdl: %s
*/
module %s;

import __stdtraits = std.traits;

import diamond.web.soap.datatypes;
import diamond.web.soap.client;

}.format(name, moduleName, wsdl, moduleName);

  string[] typeNames;

  foreach (schema; schemas)
  {
    auto result = parseSchema(schema);

    if (result && result.length)
    {
      import std.algorithm : filter, map;
      import std.array : array;

      typeNames ~= result.filter!(r => r.name && r.name.length).map!(r => r.name).array;

      wsdlResult ~= parseDTypes(result);
    }
  }

  import diamond.core.collections;
  import diamond.web.soap.message;

  SoapMessage[string] inputs;
  SoapMessage[string] outputs;
  parseMessages(moduleName, new HashSet!string(typeNames), document.root, inputs, outputs);

  import diamond.web.soap.messageoperation;

  SoapMessageOperation[][string] messageOperations;
  wsdlResult ~= parsePortTypes(document.root, inputs, outputs, messageOperations);

  wsdlResult ~= parseBinding(document.root, messageOperations);

  wsdlResult ~= parseServices(document.root);

  if (!exists("__services"))
  {
    mkdir("__services");
  }

  write("__services/" ~ name ~ ".d", wsdlResult);
  write("__services/" ~ name ~ ".wsdl.xml", document.toString());
}
