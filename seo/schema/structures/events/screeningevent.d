/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.screeningevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/ScreeningEvent
  final class ScreeningEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new screening event.
    this()
    {
      super("ScreeningEvent");
    }

    @property
    {
    }
  }
}
