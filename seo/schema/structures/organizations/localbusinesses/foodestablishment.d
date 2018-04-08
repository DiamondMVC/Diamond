/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.foodestablishment;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/FoodEstablishment
  final class FoodEstablishment : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new food establishment.
    this()
    {
      super("FoodEstablishment");
    }

    @property
    {
    }
  }
}
