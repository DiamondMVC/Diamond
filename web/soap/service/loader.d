/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.loader;

/**
* Loads soap definitions from a wsdl file.
* The wsdl file can be a physical file or a remote url.
* Params:
*   name =       The name of the soap service.
*   wsdl =       The path to the wsdl.
*   moduleName = The name of the resulting service module.
*/
package(diamond) void loadSoapDefinition(string name, string wsdl, string moduleName)
{
  auto originalWsdl = wsdl;

  import std.file : readText, exists;

  import diamond.security.validation.url : isValidUrl;
  import diamond.dom;
  import diamond.xml;
  import diamond.web.soap.service.parser;
  import diamond.errors.exceptions;

  if (isValidUrl(originalWsdl))
  {
    import std.net.curl : get;

    wsdl = cast(string)get(originalWsdl);
  }
  else if (exists(originalWsdl))
  {
    wsdl = readText(originalWsdl);
  }
  else
  {
    throw new SoapException("The wsdl file was not found remote or locally.");
  }

  auto document = parseDom!XmlDocument(wsdl, new XmlParserSettings);

  if (document.root.name != "definitions" && document.root.name != "wsdl:definitions" && document.root.name != "xs:definitions" && document.root.name != "xsd:definitions")
  {
    throw new SoapException("The wsdl file does not contain 'definitions' as root element.");
  }

  parseWsdl(name, originalWsdl, document, moduleName);
}
