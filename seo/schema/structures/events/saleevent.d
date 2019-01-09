/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.saleevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/SaleEvent
  final class SaleEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new sale event.
    this()
    {
      super("SaleEvent");
    }

    @property
    {
    }
  }
}
