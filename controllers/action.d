/**
* Copyright © DiamondMVC 2016-2017
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
    import diamond.controllers.basecontroller;
    /// Wrapper for a controller's generate action
    class GenerateControllerAction
    {
      import diamond.controllers.basecontroller;
      import diamond.http : Route;
      import vibe.d : HTTPServerRequest, HTTPServerResponse;

      private:
      /// The associated delegate.
      BaseController delegate(HTTPServerRequest,HTTPServerResponse,Route) _delegate;

      /// The associated function pointer.
      BaseController function(HTTPServerRequest,HTTPServerResponse,Route) _functionPointer;

      public:
      /**
      *   Creates a new generate controler action.
      *   Params:
      *       d = The delegate.
      */
      this(BaseController delegate(HTTPServerRequest,HTTPServerResponse,Route) d)
      {
          _delegate = d;
      }

      /**
      *   Creates a new generate controler action.
      *   Params:
      *       f = The function pointer..
      */
      this(BaseController function(HTTPServerRequest,HTTPServerResponse,Route) f)
      {
          _functionPointer = f;
      }

      /**
      *   Operator overload for using the wrapper as a call.
      *   Params:
      *     request =   The request
      *     response =  The response
      *     route =     The route
      *   Returns:
      *     The controller.
      */
      BaseController opCall(HTTPServerRequest request, HTTPServerResponse response, Route route)
      {
          if (_delegate)
          {
            return _delegate(request, response, route);
          }
          else if (_functionPointer)
          {
            return _functionPointer(request, response, route);
          }

          return null;
      }
    }
  }
}
