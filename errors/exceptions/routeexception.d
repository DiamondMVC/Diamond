/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.exceptions.routeexception;

import diamond.core.apptype;

static if (isWeb)
{
  class RouteException : Exception
  {
    public:
    /**
    * Creates a new route exception.
    * Params:
    *   message =   The message.
    *   fn =        The file.
    *   ln =        The line.
    */
    this(string message, string fn = __FILE__, size_t ln = __LINE__)
    {
      super(message, fn, ln);
    }
  }
}
