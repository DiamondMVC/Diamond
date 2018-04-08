/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.recyclingcenter;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/RecyclingCenter
  final class RecyclingCenter : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new recycling center.
    this()
    {
      super("RecyclingCenter");
    }

    @property
    {
    }
  }
}
