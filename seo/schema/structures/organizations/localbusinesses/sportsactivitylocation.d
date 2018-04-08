/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.sportsactivitylocation;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/SportsActivityLocation
  final class SportsActivityLocation : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new sports activity location.
    this()
    {
      super("SportsActivityLocation");
    }

    @property
    {
    }
  }
}
