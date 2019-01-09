/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.exhibitionevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/ExhibitionEvent
  final class ExhibitionEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new exhibition event.
    this()
    {
      super("ExhibitionEvent");
    }

    @property
    {
    }
  }
}
