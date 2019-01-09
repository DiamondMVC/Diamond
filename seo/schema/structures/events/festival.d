/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.festival;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/Festival
  final class Festival : Event
  {
    private:


    public:
    final:
    /// Creates a new festival.
    this()
    {
      super("Festival");
    }

    @property
    {
    }
  }
}
