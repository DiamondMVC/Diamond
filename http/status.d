/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.status;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPStatus;

  import diamond.core.traits;

  /// Alias to HTTPStatus.
  mixin(createEnumAlias!HTTPStatus("HttpStatus"));
}
