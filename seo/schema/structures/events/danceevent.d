/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.danceevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/DanceEvent
  final class DanceEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new dance event.
    this()
    {
      super("DanceEvent");
    }

    @property
    {
    }
  }
}
