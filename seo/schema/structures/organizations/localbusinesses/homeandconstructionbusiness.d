/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.homeandconstructionbusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/HomeAndConstructionBusiness
  final class HomeAndConstructionBusiness : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new home and construction business.
    this()
    {
      super("HomeAndConstructionBusiness");
    }

    @property
    {
    }
  }
}
