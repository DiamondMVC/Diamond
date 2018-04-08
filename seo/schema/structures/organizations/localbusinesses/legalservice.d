/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.legalservice;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/LegalService
  final class LegalService : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new legal service.
    this()
    {
      super("LegalService");
    }

    @property
    {
    }
  }
}
