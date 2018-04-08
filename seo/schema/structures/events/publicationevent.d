/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.publicationevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/PublicationEvent
  final class PublicationEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new publication event.
    this()
    {
      super("PublicationEvent");
    }

    @property
    {
    }
  }
}
