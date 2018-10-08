/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.client.soapclient;

import diamond.http;
import diamond.web.soap.client.envelope;

/// Wrapper around a soap client.
final class SoapClient
{
  public:
  final:
  /// Creates a new soap client.
  this() { }

  /**
  * Sends a soap envelope to the specified url over HTTP.
  * Params:
  *   url =        The url of the soap method.
  *   envelope =   The envelope to send.
  *   soapAction = The soap action.
  */
  void sendHttp(string url, SoapEnvelope envelope, string soapAction = null)
  {
    sendHttp(HttpMethod.POST, url, envelope, soapAction);
  }

  /**
  * Sends a soap envelope to the specified url over HTTP.
  * Params:
  *   method =     The http method to send the soap envelope over.
  *   url =        The url of the soap method.
  *   envelope =   The envelope to send.
  *   soapAction = The soap action.
  */
  void sendHttp(HttpMethod method, string url, SoapEnvelope envelope, string soapAction = null)
  {
    remoteRequest(url, method,
      (scope responder)
      {
        // TODO: Convert the response into a proper soap response object ...
        // TODO: Callback for the response creation
        // TODO: Callback for the request creation
      },
      (scope requester)
      {
        import std.string : toLower;

        requester.contentType = "application/soap+xml; charset=" ~ envelope.xmlEncoding.toLower();

        if (soapAction && soapAction.length)
        {
          requester.headers["SOAPAction"] = soapAction;
        }

        requester.bodyWriter.write(envelope.toString);
      }
    );
  }
}
