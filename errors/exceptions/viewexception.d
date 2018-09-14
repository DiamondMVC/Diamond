/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.exceptions.viewexception;

import diamond.core.apptype;

static if (isWebServer)
{
  /// Exception thrown by a view.
  final class ViewException : Exception
  {
    private:
    /// The view name.
    string _viewName;

    public:
    /**
    * Creates a new view exception.
    * Params:
    *   viewName =  The name of the view that threw the error.
    *   throwable =     The throwable.
    *   fn =        The file.
    *   ln =        The line.
    */
    this(string viewName, Throwable throwable, string fn = __FILE__, size_t ln = __LINE__)
    {
      _viewName = viewName;

      super("...", fn, ln, throwable);
    }

    /**
    * Retrieves a string equivalent to the exception text.
    * Returns:
    *   A string equivalent to the exception text.
    */
    override string toString()
    {
      return "view: " ~ _viewName ~ "\r\n\r\n" ~ super.toString();
    }
  }

  /// Error thrown by a view.
  final class ViewError : Error
  {
    private:
    /// The view name.
    string _viewName;

    public:
    /**
    * Creates a new view error.
    * Params:
    *   viewName =  The name of the view that threw the error.
    *   throwable =     The throwable.
    *   fn =        The file.
    *   ln =        The line.
    */
    this(string viewName, Throwable throwable, string fn = __FILE__, size_t ln = __LINE__)
    {
      _viewName = viewName;

      super("...", fn, ln, throwable);
    }

    /**
    * Retrieves a string equivalent to the error text.
    * Returns:
    *   A string equivalent to the error text.
    */
    override string toString()
    {
      return "view: " ~ _viewName ~ "\r\n\r\n" ~ super.toString();
    }
  }
}
