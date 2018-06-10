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
  class ViewException : Exception
  {
    private:
    /// The view name.
    string _viewName;
    /// The actual exception thrown.
    Exception _exception;

    public:
    /**
    * Creates a new view exception.
    * Params:
    *   viewName =  The name of the view that threw the error.
    *   exception =     The exception.
    *   fn =        The file.
    *   ln =        The line.
    */
    this(string viewName, Exception exception, string fn = __FILE__, size_t ln = __LINE__)
    {
      _viewName = viewName;
      _exception = exception;

      super("...", fn, ln);
    }

    /**
    * Retrieves a string equivalent to the exception text.
    * Returns:
    *   A string equivalent to the exception text.
    */
    override string toString()
    {
      return "view: " ~ _viewName ~ "\r\n\r\n" ~ _exception.toString();
    }
  }

  /// Error thrown by a view.
  class ViewError : Error
  {
    private:
    /// The view name.
    string _viewName;
    /// The actual error thrown.
    Throwable _error;

    public:
    /**
    * Creates a new view error.
    * Params:
    *   viewName =  The name of the view that threw the error.
    *   error =     The error.
    *   fn =        The file.
    *   ln =        The line.
    */
    this(string viewName, Throwable error, string fn = __FILE__, size_t ln = __LINE__)
    {
      _viewName = viewName;
      _error = error;

      super("...", fn, ln);
    }

    /**
    * Retrieves a string equivalent to the error text.
    * Returns:
    *   A string equivalent to the error text.
    */
    override string toString()
    {
      return "view: " ~ _viewName ~ "\r\n\r\n" ~ _error.toString();
    }
  }
}
