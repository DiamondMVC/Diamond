/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.literaryevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/LiteraryEvent
  final class LiteraryEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new literary event.
    this()
    {
      super("LiteraryEvent");
    }

    @property
    {
    }
  }
}
