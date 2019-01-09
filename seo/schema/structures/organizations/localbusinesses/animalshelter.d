/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.animalshelter;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/AnimalShelter
  final class AnimalShelter : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new animal shelter.
    this()
    {
      super("AnimalShelter");
    }

    @property
    {
    }
  }
}
