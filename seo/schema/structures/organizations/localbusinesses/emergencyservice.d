/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.emergencyservice;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/EmergencyService
  final class EmergencyService : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new emergency service.
    this()
    {
      super("EmergencyService");
    }

    @property
    {
    }
  }
}
