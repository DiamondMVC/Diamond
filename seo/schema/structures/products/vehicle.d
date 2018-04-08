/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.products.vehicle;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.product;

  /// http://schema.org/Vehicle
  final class Vehicle : Product
  {
    private:


    public:
    final:
    /// Creates a new vehicle.
    this()
    {
      super("Vehicle");
    }

    @property
    {
    }
  }
}
