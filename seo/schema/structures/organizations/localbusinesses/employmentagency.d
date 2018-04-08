/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.employmentagency;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/EmploymentAgency
  final class EmploymentAgency : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new employment agency.
    this()
    {
      super("EmploymentAgency");
    }

    @property
    {
    }
  }
}
