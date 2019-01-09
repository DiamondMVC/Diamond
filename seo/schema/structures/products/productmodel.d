/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.products.productmodel;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.product;

  /// http://schema.org/ProductModel
  final class ProductModel : Product
  {
    private:


    public:
    final:
    /// Creates a new product model.
    this()
    {
      super("ProductModel");
    }

    @property
    {
    }
  }
}
