/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.visualartsevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/VisualArtsEvent
  final class VisualArtsEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new visual arts event.
    this()
    {
      super("VisualArtsEvent");
    }

    @property
    {
    }
  }
}
