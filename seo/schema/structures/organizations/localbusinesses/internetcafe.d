/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.internetcafe;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/InternetCafe
  final class InternetCafe : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new internet cafe.
    this()
    {
      super("InternetCafe");
    }

    @property
    {
    }
  }
}
