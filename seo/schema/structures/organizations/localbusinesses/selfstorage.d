/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.selfstorage;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/SelfStorage
  final class SelfStorage : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new self storage.
    this()
    {
      super("SelfStorage");
    }

    @property
    {
    }
  }
}
