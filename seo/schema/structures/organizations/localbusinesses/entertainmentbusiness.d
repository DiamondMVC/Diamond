/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.entertainmentbusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/EntertainmentBusiness
  final class EntertainmentBusiness : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new entertainment business.
    this()
    {
      super("EntertainmentBusiness");
    }

    @property
    {
    }
  }
}
