/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.healthandbeautybusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/HealthAndBeautyBusiness
  final class HealthAndBeautyBusiness : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new health and beauty business.
    this()
    {
      super("HealthAndBeautyBusiness");
    }

    @property
    {
    }
  }
}
