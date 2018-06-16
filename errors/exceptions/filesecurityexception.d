/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.exceptions.filesecurityexception;

import diamond.core.apptype;

static if (isWeb)
{
  final class FileSecurityException : Exception
  {
    public:
    /**
    * Creates a new file security exception.
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
