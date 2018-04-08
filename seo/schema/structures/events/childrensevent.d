/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.childrensevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/ChildrensEvent
  final class ChildrensEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new childrens event.
    this()
    {
      super("ChildrensEvent");
    }

    @property
    {
    }
  }
}
