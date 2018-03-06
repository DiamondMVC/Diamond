/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.network;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.core.webconfig;
  import diamond.http;

  /**
  * Validates the client ip against the "restrictedIPs" field in the web configuration file.
  * Params:
  *   client = The client to validate the ip of.
  */
  void validateRestrictedIPs(HttpClient client)
  {
    if (webConfig.restrictedIPs)
    {
      validateRestrictedIPs(webConfig.restrictedIPs, client);
    }
  }

  /**
  * Validates the client ip against the "globalRestrictedIPs" field in the web configuration file.
  * Params:
  *   client = The client to validate the ip of.
  */
  void validateGlobalRestrictedIPs(HttpClient client)
  {
    if (webConfig.globalRestrictedIPs)
    {
      validateRestrictedIPs(webConfig.globalRestrictedIPs, client);
    }
  }

  /**
  * Validates the client ip against the passed restricted ips.
  * Params:
  *   restrictedIPs = The restricted ips to validate with.
  *   client =       The client to validate the ip of.
  */
  private void validateRestrictedIPs
  (
    const(string[]) restrictedIPs, HttpClient client
  )
  {
    bool allowed;

    foreach (ip; restrictedIPs)
    {
      if (client.ipAddress == ip)
      {
        allowed = true;
        break;
      }
    }

    if (!allowed)
    {
      client.error(HttpStatus.unauthorized);
    }
  }
}
