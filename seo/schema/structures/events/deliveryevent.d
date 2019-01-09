/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.deliveryevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/DeliveryEvent
  final class DeliveryEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new delivery event.
    this()
    {
      super("DeliveryEvent");
    }

    @property
    {
    }
  }
}
