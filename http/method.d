/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.method;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPMethod;

  import diamond.core.traits;

  /// Alias to HTTPMethod.
  mixin(createEnumAlias!HTTPMethod("HttpMethod"));

  public
  {
    /// Alias to be able to type "HttpGet" instead of "HttpMethod.GET"
    enum HttpGet = HttpMethod.GET;

    /// Alias to be able to type "HttpPost" instead of "HttpMethod.POST"
    enum HttpPost = HttpMethod.POST;

    /// Alias to be able to type "HttpPut" instead of "HttpMethod.PUT"
    enum HttpPut = HttpMethod.PUT;

    /// Alias to be able to type "HttpDelete" instead of "HttpMethod.DELETE"
    enum HttpDelete = HttpMethod.DELETE;
  }
}
