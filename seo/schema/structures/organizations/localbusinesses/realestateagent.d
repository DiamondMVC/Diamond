/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.realestateagent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/RealEstateAgent
  final class RealEstateAgent : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new real estate agent.
    this()
    {
      super("RealEstateAgent");
    }

    @property
    {
    }
  }
}
