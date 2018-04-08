/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.automotivebusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/AutoMotiveBusiness
  final class AutoMotiveBusiness : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new auto-motive business.
    this()
    {
      super("AutoMotiveBusiness");
    }

    @property
    {
    }
  }
}
