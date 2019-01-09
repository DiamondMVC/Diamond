/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.dentist;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/Dentist
  final class Dentist : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new dentist.
    this()
    {
      super("Dentist");
    }

    @property
    {
    }
  }
}
