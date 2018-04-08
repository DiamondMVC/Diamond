/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.lodgingbusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/LodgingBusiness
  final class LodgingBusiness : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new lodging business.
    this()
    {
      super("LodgingBusiness");
    }

    @property
    {
    }
  }
}
