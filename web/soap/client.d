/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.client;

import std.traits : Parameters;

import diamond.http;

/// Wrapper around a soap client.
final class SoapClient
{
  public:
  final:
  /// Creates a new soap client.
  this() { }

  ReturnType!f sendRequestFromFunctionDefinition(alias f)(Parameters!f)
  {
    // TODO: Construct request ...
    return null;
  }

  void sendRawRequest(string url, string soapAction, string soapEnvelope)
  {
    remoteRequest(url, HttpMethod.POST,
      (scope responder)
      {
        /// ...
      },
      (scope requester)
      {
        requester.headers["SOAPAction"] = soapAction;

        requester.bodyWriter.write(soapEnvelope);
      }
    );
  }
}
