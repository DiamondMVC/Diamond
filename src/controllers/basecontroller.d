/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.basecontroller;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPMethod;

  import diamond.controllers.action;
  import diamond.controllers.status;

  /// Wrapper for a base controller.
  abstract class BaseController
  {
    protected:
    /// Alias for the action entry.
    alias ActionEntry = Action[string];
    /// Alias for the method entry.
    alias MethodEntry = ActionEntry[HTTPMethod];

    /// Collection of actions.
    public MethodEntry _actions;
    /// The default action for the controller.
    Action _defaultAction;
    /// The mandatory action for the controller.
    Action _mandatoryAction;

    /// Creates a new base controller.
    this() { }

    static if (isWebApi)
    {
      /// For web-api's we need to have the handle() function within here for template simplicity at compile-time.
      public abstract Status handle();
    }

    final:
    /**
    * Maps an action to a http method by a name.
    * Params:
    *     method =    The http method.
    *     action =    The action name.
    *     fun =       The controller action associated with the mapping.
    */
    void mapAction(HTTPMethod method, string action, Action fun)
    {
      _actions[method][action] = fun;
    }

    /**
    * Maps an action to a http method by a name.
    * Params:
    *     method =    The http method.
    *     action =    The action name.
    *     d =       The controller action associated with the mapping.
    */
    void mapAction(HTTPMethod method, string action, Status delegate() d)
    {
      _actions[method][action] = new Action(d);
    }

    /**
    * Maps an action to a http method by a name.
    * Params:
    *     method =    The http method.
    *     action =    The action name.
    *     f =       The controller action associated with the mapping.
    */
    void mapAction(HTTPMethod method, string action, Status function() f)
    {
      _actions[method][action] = new Action(f);
    }

    /**
    * Maps a default action for the controller.
    * Params:
    *     fun =       The controller action associated with the mapping.
    */
    void mapDefault(Action fun)
    {
      _defaultAction = fun;
    }

    /**
    * Maps a default action for the controller.
    * Params:
    *     d =       The controller action associated with the mapping.
    */
    void mapDefault(Status delegate() d)
    {
      _defaultAction = new Action(d);
    }

    /**
    * Maps a default action for the controller.
    * Params:
    *     f =       The controller action associated with the mapping.
    */
    void mapDefault(Status function() f)
    {
      _defaultAction = new Action(f);
    }

    /**
    * Maps a mandatory action for the controller.
    * Params:
    *     fun =       The controller action associated with the mapping.
    */
    void mapMandatory(Action fun)
    {
      _mandatoryAction = fun;
    }

    /**
    * Maps a mandatory action for the controller.
    * Params:
    *     d =       The controller action associated with the mapping.
    */
    void mapMandatory(Status delegate() d)
    {
      _mandatoryAction = new Action(d);
    }

    /**
    * Maps a mandatory action for the controller.
    * Params:
    *     f =       The controller action associated with the mapping.
    */
    void mapMandatory(Status function() f)
    {
      _mandatoryAction = new Action(f);
    }
  }
}
