/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.unittesting.attributes;

import diamond.core.apptype;

static if (isWeb && isTesting)
{
  /// Attribute to define a test.
  struct HttpTest
  {
    /// The name of the test.
    string name;
  }
}
