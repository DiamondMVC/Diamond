/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.network;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPStatusException, HTTPStatus;

  import diamond.core.webconfig;

  /**
  * Validates the request ip against the "restrictedIPs" field in the web configuration file.
  * Params:
  *   request = The request to validate the ip of.
  */
  void validateRestrictedIPs(HTTPServerRequest request)
  {
    if (webConfig.restrictedIPs)
    {
      validateRestrictedIPs(webConfig.restrictedIPs, request);
    }
  }

  /**
  * Validates the request ip against the "globalRestrictedIPs" field in the web configuration file.
  * Params:
  *   request = The request to validate the ip of.
  */
  void validateGlobalRestrictedIPs(HTTPServerRequest request)
  {
    if (webConfig.globalRestrictedIPs)
    {
      validateRestrictedIPs(webConfig.globalRestrictedIPs, request);
    }
  }

  /**
  * Validates the request ip against the passed restricted ips.
  * Params:
  *   restrictedIPs = The restricted ips to validate with.
  *   request =       The request to validate the ip of.
  */
  private void validateRestrictedIPs
  (
    const(string[]) restrictedIPs, HTTPServerRequest request
  )
  {
    bool allowed;
    auto clientIp = request.clientAddress.toAddressString();

    foreach (ip; restrictedIPs)
    {
      if (clientIp == ip)
      {
        allowed = true;
        break;
      }
    }

    if (!allowed)
    {
      throw new HTTPStatusException(HTTPStatus.unauthorized);
    }
  }
}
