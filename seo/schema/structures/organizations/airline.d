/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.airline;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/Airline
  final class Airline : Organization
  {
    private:


    public:
    final:
    /// Creates a new airline.
    this()
    {
      super("Airline");
    }

    @property
    {
    }
  }
}
