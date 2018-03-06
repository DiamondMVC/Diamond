/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.action;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.controllers.status;

  /// Wrapper for a controller action
  class Action
  {
      private:
      /// The associated delegate.
      Status delegate() _delegate;

      /// The associated function pointer.
      Status function() _functionPointer;

      public:
      /**
      *   Creates a new controler action.
      *   Params:
      *       d = The delegate.
      */
      this(Status delegate() d)
      {
          _delegate = d;
      }

      /**
      *   Creates a new controler action.
      *   Params:
      *       f = The function pointer..
      */
      this(Status function() f)
      {
          _functionPointer = f;
      }

      /**
      *   Operator overload for using the wrapper as a call.
      *   Returns:
      *       The status of the call.
      */
      Status opCall()
      {
          if (_delegate)
          {
            return _delegate();
          }
          else if (_functionPointer)
          {
            return _functionPointer();
          }

          return Status.notFound;
      }
  }

  static if (isWebApi)
  {
    /// Wrapper for a controller's generate action
    class GenerateControllerAction
    {
      import diamond.controllers.basecontroller;
      import diamond.http;

      private:
      /// The associated delegate.
      BaseController delegate(HttpClient) _delegate;

      /// The associated function pointer.
      BaseController function(HttpClient) _functionPointer;

      public:
      /**
      *   Creates a new generate controler action.
      *   Params:
      *       d = The delegate.
      */
      this(BaseController delegate(HttpClient) d)
      {
          _delegate = d;
      }

      /**
      *   Creates a new generate controler action.
      *   Params:
      *       f = The function pointer..
      */
      this(BaseController function(HttpClient) f)
      {
          _functionPointer = f;
      }

      /**
      *   Operator overload for using the wrapper as a call.
      *   Params:
      *     client =   The client
      *   Returns:
      *     The controller.
      */
      BaseController opCall(HttpClient client)
      {
          if (_delegate)
          {
            return _delegate(client);
          }
          else if (_functionPointer)
          {
            return _functionPointer(client);
          }

          return null;
      }
    }
  }
}
