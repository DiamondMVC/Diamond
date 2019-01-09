/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.form;

import diamond.core.apptype;
import diamond.http.method;
import diamond.web.elements.block;
import diamond.web.elements.input;

/// Wrapper around a form.
final class Form : Block!Input
{
  private:
  /// The action.
  string _action;
  /// The mime-type.
  string _mimeType;

  static if (isWeb)
  {
    /// The http method.
    HttpMethod _method;
  }
  else
  {
    /// The http method.
    string _method;
  }

  public:
  final:
  /// Creates a new form.
  this()
  {
    super("form");
  }

  @property
  {
    /// Gets the action.
    string action() { return _action; }

    /// Sets the action.
    void action(string newAction)
    {
      _action = newAction;

      addAttribute("action", _action);
    }

    /// Gets the mime-type.
    string mimeType() { return _mimeType; }

    /// Sets the mime-type.
    void mimeType(string newMimeType)
    {
      _mimeType = newMimeType;

      addAttribute("enctype", _mimeType);
    }

    static if (isWeb)
    {
      /// Gets the http method.
      HttpMethod method() { return _method; }

      /// Sets the http method.
      void method(HttpMethod method)
      {
        import std.conv;

        _method = method;
        addAttribute("method", to!string(method));
      }
    }
    else
    {
      /// Gets the http method.
      string method() { return _method; }

      /// Sets the http method.
      void method(string method)
      {
        _method = method;
        addAttribute("method", _method);
      }
    }
  }
}
