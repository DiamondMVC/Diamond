/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.client.envelope;

import diamond.web.soap.client.envelopebody;

/// Wrapper around a soap envelope.
final class SoapEnvelope
{
  private:
  /// The xml version of the envelope.
  string _xmlVersion;
  /// The xml encoding of the envelope.
  string _xmlEncoding;
  /// The xml soap environment.
  string _xmlSoapEnvironment;
  /// The xml xsi.
  string _xmlXsi;
  /// The xml xsd.
  string _xmlXsd;
  /// The soap body.
  SoapEnvelopeBody _body;

  public:
  final:
  /**
  * Creates a new soap envelope.
  * Params:
  *   body =               The body of the envelope.
  *   xmlVersion =         The version of the xml.
  *   xmlEncoding =        The xml encoding of the envelope.
  *   xmlSoapEnvironment = The environment of the soap specification.
  *   xmlXsi =             The xml schema instance.
  *   xmlXsd =             The xml schema.
  */
  this
  (
    SoapEnvelopeBody body,
    string xmlVersion = "1.0",
    string xmlEncoding = "UTF-8",
    string xmlSoapEnvironment = "http://www.w3.org/2003/05/soap-envelope",
    string xmlXsi = "http://www.w3.org/1999/XMLSchema-instance",
    string xmlXsd = "http://www.w3.org/1999/XMLSchema"
  )
  {
    import diamond.errors.checks;

    enforce(body !is null, "No soap body specified.");

    _body = body;
  }

  @property
  {
    /// Gets the xml version.
    string xmlVersion() { return _xmlVersion; }

    /// Gets the xml encoding of the envelope
    string xmlEncoding() { return _xmlEncoding; }

    /// Gets the soap body.
    SoapEnvelopeBody body() { return _body; }
  }

  /// Transforms the envelope into a properly formatted soap xml entry.
  override string toString()
  {
    import diamond.xml;

    auto document = new XmlDocument(new XmlParserSettings);

    document.xmlVersion = _xmlVersion;
    document.encoding = _xmlEncoding;

    auto envelope = new XmlNode(null);

    document.root = envelope;
    envelope.name = "soap:Envelope";
    envelope.addAttribute("xmlns:soap", _xmlSoapEnvironment);
    envelope.addAttribute("xmlns:xsi", _xmlXsi);
    envelope.addAttribute("xmlns:xsd", _xmlXsd);

    auto envelopeHeader = new XmlNode(envelope);
    envelopeHeader.name = "soap:Header";
    envelope.addChild(envelopeHeader);

    auto envelopeBody = new XmlNode(envelope);
    envelopeBody.name = "soap:Body";
    envelope.addChild(envelopeBody);

    auto envelopeMethod = new XmlNode(envelopeBody);
    envelopeMethod.name = "m:" ~ _body.method;
    envelopeBody.addChild(envelopeMethod);

    if (_body.parameters && _body.parameters.length)
    {
      foreach (param; _body.parameters)
      {
        auto envelopeParam = new XmlNode(envelopeMethod);
        envelopeMethod.addChild(envelopeParam);

        envelopeParam.name = "m:" ~ param.name;
        envelopeParam.text = param.value;
      }
    }

    return document.toString();
  }
}
