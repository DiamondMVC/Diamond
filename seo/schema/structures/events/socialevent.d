/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.socialevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/SocialEvent
  final class SocialEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new social event.
    this()
    {
      super("SocialEvent");
    }

    @property
    {
    }
  }
}
