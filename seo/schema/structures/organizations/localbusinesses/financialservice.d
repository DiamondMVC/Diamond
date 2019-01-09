/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusinesses.financialservice;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organizations.localbusiness;

  /// http://schema.org/FinancialService
  final class FinancialService : LocalBusiness
  {
    private:


    public:
    final:
    /// Creates a new financial service.
    this()
    {
      super("FinancialService");
    }

    @property
    {
    }
  }
}
