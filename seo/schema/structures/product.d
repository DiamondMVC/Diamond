/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.product;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.schemaobject;

  /// http://schema.org/Product
  class Product : SchemaObject
  {
    private:

    public:
    /// Creates a new product.
    this()
    {
      super("Product");
    }

    /**
    * Creates a new product.
    * Params:
    *   productType = The type of the product.
    */
    protected this(string productType)
    {
      super(productType);
    }

    @property
    {
      final
      {

      }
    }
  }
}
