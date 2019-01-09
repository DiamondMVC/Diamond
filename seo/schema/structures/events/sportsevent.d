/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.sportsevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/SportsEvent
  final class SportsEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new sports event.
    this()
    {
      super("SportsEvent");
    }

    @property
    {
    }
  }
}
