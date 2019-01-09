/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.ngo;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/Ngo
  final class Ngo : Organization
  {
    private:


    public:
    final:
    /// Creates a new ngo.
    this()
    {
      super("Ngo");
    }

    @property
    {
    }
  }
}
