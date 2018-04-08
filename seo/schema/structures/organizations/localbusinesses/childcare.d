/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.childcare;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/ChildCare
  final class ChildCare : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new child care.
    this()
    {
      super("ChildCare");
    }

    @property
    {
    }
  }
}
