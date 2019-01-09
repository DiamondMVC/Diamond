/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.store;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/Store
  final class Store : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new store.
    this()
    {
      super("Store");
    }

    @property
    {
    }
  }
}
