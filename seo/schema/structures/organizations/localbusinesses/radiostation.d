/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.radiostation;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/RadioStation
  final class RadioStation : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new radio station.
    this()
    {
      super("RadioStation");
    }

    @property
    {
    }
  }
}
