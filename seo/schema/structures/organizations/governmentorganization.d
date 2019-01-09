/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.governmentorganization;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/GovernmentOrganization
  final class GovernmentOrganization : Organization
  {
    private:


    public:
    final:
    /// Creates a new government organization.
    this()
    {
      super("GovernmentOrganization");
    }

    @property
    {
    }
  }
}
