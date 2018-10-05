/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.parser.serviceparser;

import std.array : split;
import std.string : format;

import diamond.dom;
import diamond.xml;

package(diamond.web.soap.parser):
/**
* Parses the services of the wsdl file.
* Params:
*   root =       The root node of the wsdl file.
*/
string parseServices(XmlNode root)
{
  auto services = root.getByTagName("wsdl:service");

  if (!services || !services.length)
  {
    services = root.getByTagName("xs:service");
  }

  if (!services || !services.length)
  {
    services = root.getByTagName("xsd:service");
  }

  if (!services || !services.length)
  {
    services = root.getByTagName("soap:service");
  }

  if (!services || !services.length)
  {
    services = root.getByTagName("service");
  }

  auto result = q{
private static immutable(string[string]) __services;

static this()
{
%s
}
  };

  string endpoints = "";

  foreach (service; services)
  {
    auto ports = service.getByTagName("wsdl:port");

    if (!ports || !ports.length)
    {
      ports = service.getByTagName("xs:port");
    }

    if (!ports || !ports.length)
    {
      ports = service.getByTagName("xsd:port");
    }

    if (!ports || !ports.length)
    {
      ports = service.getByTagName("port");
    }

    if (!ports || !ports.length)
    {
      ports = service.getByTagName("soap:port");
    }

    foreach (port; ports)
    {
      auto bindingAttribute = port.getAttribute("binding");
      auto binding = bindingAttribute.value.split(":").length == 2 ? bindingAttribute.value.split(":")[1] : bindingAttribute.value;

      auto locations = port.getByAttributeName("location");

      if (locations && locations.length)
      {
        endpoints ~= "\t__services[\"" ~ binding ~ "\"] = \"" ~ locations[0].getAttribute("location").value ~ "\";\r\n";
      }
    }
  }

  return result.format(endpoints);
}
