/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.exceptions.htmlexception;

final class HtmlException : Exception
{
  public:
  /**
  * Creates a new html exception.
  * Params:
  *   message =   The message.
  *   fn =        The file.
  *   ln =        The line.
  */
  this(string message, string fn = __FILE__, size_t ln = __LINE__) @safe
  {
    super(message, fn, ln);
  }
}
