/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.medicalorganization;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/MedicalOrganization
  final class MedicalOrganization : Organization
  {
    private:


    public:
    final:
    /// Creates a new medical organization.
    this()
    {
      super("MedicalOrganization");
    }

    @property
    {
    }
  }
}
