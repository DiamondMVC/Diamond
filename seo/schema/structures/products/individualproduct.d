/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.products.individualproduct;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.product;

  /// http://schema.org/IndividualProduct
  final class IndividualProduct : Product
  {
    private:


    public:
    final:
    /// Creates a new individual product.
    this()
    {
      super("IndividualProduct");
    }

    @property
    {
    }
  }
}
