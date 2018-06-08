/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.exceptions.sensitivedataexception;

class SensitiveDataException : Exception
{
  public:
  /**
  * Creates a new sensitive data exception.
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
