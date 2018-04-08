/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.educationalorganization;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/EducationalOrganization
  final class EducationalOrganization : Organization
  {
    private:


    public:
    final:
    /// Creates a new educational organization.
    this()
    {
      super("EducationalOrganization");
    }

    @property
    {
    }
  }
}
