/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.performinggroup;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/PerformingGroup
  final class PerformingGroup : Organization
  {
    private:


    public:
    final:
    /// Creates a new performing group.
    this()
    {
      super("PerformingGroup");
    }

    @property
    {
    }
  }
}
