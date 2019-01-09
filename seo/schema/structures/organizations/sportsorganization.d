/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.sportsorganization;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/SportsOrganization
  final class SportsOrganization : Organization
  {
    private:


    public:
    final:
    /// Creates a new sports organization.
    this()
    {
      super("SportsOrganization");
    }

    @property
    {
    }
  }
}
