/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.products.someproducts;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.product;

  /// http://schema.org/SomeProducts
  final class SomeProducts : Product
  {
    private:


    public:
    final:
    /// Creates a new some products.
    this()
    {
      super("SomeProducts");
    }

    @property
    {
    }
  }
}
