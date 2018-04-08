/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.educationevent;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/EducationEvent
  final class EducationEvent : Event
  {
    private:


    public:
    final:
    /// Creates a new education event.
    this()
    {
      super("EducationEvent");
    }

    @property
    {
    }
  }
}
