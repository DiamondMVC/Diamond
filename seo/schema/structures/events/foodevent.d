/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.foodevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/FoodEvent
  final class FoodEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new food event.
    this()
    {
      super("FoodEvent");
    }

    @property
    {
    }
  }
}
