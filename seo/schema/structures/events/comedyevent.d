/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.comedyevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/ComedyEvent
  final class ComedyEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new comedy event.
    this()
    {
      super("ComedyEvent");
    }

    @property
    {
    }
  }
}
