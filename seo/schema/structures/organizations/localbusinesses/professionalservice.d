/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.professionalservice;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/ProfessionalService
  final class ProfessionalService : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new professional service.
    this()
    {
      super("ProfessionalService");
    }

    @property
    {
    }
  }
}
