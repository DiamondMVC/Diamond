/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.events.courseinstance;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.event;

  /// http://schema.org/CourseInstance
  final class CourseInstance : Event
  {
    private:


    public:
    final:
    /// Creates a new course instance.
    this()
    {
      super("CourseInstance");
    }

    @property
    {
    }
  }
}
