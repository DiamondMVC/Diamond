/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.xml.xmldocument;

import diamond.xml.xmlexception;
import diamond.dom.domdocument;
import diamond.dom.domnode;
import diamond.xml.xmlnode;

/// An XML document.
final class XmlDocument : DomDocument
{
  private:
  /// The version of the xml document.
  string _xmlVersion;
  /// The encoding of the xml document.
  string _encoding;
  /// The root node of the document.
  XmlNode _root;

  public:
  final:
  /// Creates a new xml document.
  this() @safe
  {
    super();
  }

  /**
  * Parses the elements from the dom to the document.
  * Params:
  *   elements = The parsed dom elements.
  */
  override void parseElements(DomNode[] elements) @safe
  {
    if (!elements || elements.length != 2)
    {
      throw new XmlException("No xml header found or no root element found.");
    }

    auto header = elements[0];
    _root = elements[1];

    auto versionAttribute = header.getAttribute("version");
    auto encodingAttribute = header.getAttribute("encoding");

    import std.string : strip;

    _xmlVersion = versionAttribute ? versionAttribute.value.strip() : null;
    _encoding = encodingAttribute ? encodingAttribute.value.strip() : "UTF-8";
  }

  @property
  {
    /// Gets the version of the xml document.
    string xmlVersion() @safe { return _xmlVersion; }

    /// Sets the version of the xml document.
    void xmlVersion(string newXmlVersion) @safe
    {
      _xmlVersion = newXmlVersion;

      if (!_xmlVersion || !_xmlVersion.length)
      {
        throw new XmlException("No xml version found.");
      }
    }

    /// Gets the encoding of the xml document.
    string encoding() @safe { return _encoding; }

    /// Sets the encoding of the xml document.
    void encoding(string newEncoding) @safe
    {
      _encoding = newEncoding;

      if (!_encoding || !_encoding.length)
      {
        throw new XmlException("Empty encoding specified.");
      }
    }

    /// Gets the root of the xml document.
    XmlNode root() @safe { return _root; }

    /// Sets the root node of the xml document.
    void root(XmlNode newRoot) @safe
    {
      _root = newRoot;
    }
  }

  /**
  * Converts the xml document to a properly formatted xml document-string.
  * Returns:
  *   A string equivalent to the properly formatted xml document-string.
  */
  override string toString() @safe
  {
    import std.string : format;

    return "<?xml version=\"%s\" encoding=\"%s\"?>\r\n%s".format(_xmlVersion, _encoding && _encoding.length ? _encoding : "UTF-8", _root ? _root.toString() : "");
  }
}
