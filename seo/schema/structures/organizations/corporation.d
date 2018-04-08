/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.corporation;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/Corporation
  final class Corporation : Organization
  {
    private:


    public:
    final:
    /// Creates a new corporation.
    this()
    {
      super("Corporation");
    }

    @property
    {
    }
  }
}
