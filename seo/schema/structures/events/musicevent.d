/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.musicevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/MusicEvent
  final class MusicEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new music event.
    this()
    {
      super("MusicEvent");
    }

    @property
    {
    }
  }
}
