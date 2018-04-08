/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.shoppingcenter;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/ShoppingCenter
  final class ShoppingCenter : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new shopping center.
    this()
    {
      super("ShoppingCenter");
    }

    @property
    {
    }
  }
}
