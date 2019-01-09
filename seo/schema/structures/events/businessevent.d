/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.businessevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/BusinessEvent
  final class BusinessEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new business event.
    this()
    {
      super("BusinessEvent");
    }

    @property
    {
    }
  }
}
