/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.controller;

import diamond.core.apptype;

static if (isWeb)
{
  import std.string : strip, format;
  import std.traits : fullyQualifiedName, hasUDA, getUDAs;
  import std.array : split, array;

  public import diamond.http;
  public import diamond.controllers.authentication;
  public import diamond.authentication;

  import diamond.controllers.action;
  import diamond.controllers.status;
  import diamond.controllers.basecontroller;
  import diamond.controllers.mapattributes;
  import diamond.core.collections;
  import diamond.core.string : firstToLower;
  import diamond.errors;
  import diamond.controllers.rest;
  import diamond.security;

  package(diamond.controllers)
  {
    /// Specially mapped routes.
    RoutePart[][string] _mappedRoutes;
    /// Mapped controllers.
    HashSet!string _mappedControllers;
  }

  /// The format used for default mappings.
  enum defaultMappingFormat = q{
    static if (hasUDA!(%1$s.%2$s, HttpDefault))
    {
      mapDefault(&controller.%2$s);
    }
  };

  /// The format used for mandatory formats.
  enum mandatoryMappingFormat = q{
    static if (hasUDA!(%1$s.%2$s, HttpMandatory))
    {
      mapMandatory(&controller.%2$s);
    }
  };

  /// The format for creating the http acton member.
  enum actionNameFormat = "static HttpAction action_%2$s;\r\n";

  /// The format used for actions.
  enum actionMappingFormat = q{
    static if (hasUDA!(%1$s.%2$s, HttpAction))
    {
      static action_%2$s = getUDAs!(%1$s.%2$s, HttpAction)[0];

      if (action_%2$s.action && action_%2$s.action.strip().length)
      {
        auto routingData = _mappedRoutes.get("%2$s", null);

        if (!routingData && !_mappedControllers[fullyQualifiedName!TController])
        {
          routingData = parseRoute(action_%2$s.action);

          if (routingData && routingData.length > 1)
          {
            _mappedRoutes["%2$s"] = routingData;

            action_%2$s.action = routingData[0].identifier;
          }
        }

        if (routingData && routingData.length)
        {
          if (routingData[0].identifier == "<>")
          {
            action_%2$s.action = null;
          }
        }
      }

      mapAction(
        action_%2$s.method,
        (
          action_%2$s.action && action_%2$s.action.strip().length ?
          action_%2$s.action : "%2$s"
        ).firstToLower(),
        &controller.%2$s
      );
    }
  };

  /// The format used for disabled authentication.
  enum disableAuthFormat = q{
    static if (hasUDA!(%1$s.%2$s, HttpDisableAuth))
    {
      static if (hasUDA!(%1$s.%2$s, HttpDefault))
      {
        _disabledAuth.add("/");
      }
      else static if (hasUDA!(%1$s.%2$s, HttpAction))
      {
        _disabledAuth.add(
          (
            action_%2$s.action && action_%2$s.action.strip().length ?
            action_%2$s.action : "%2$s"
          ).firstToLower()
        );
      }
    }
  };

  /// The format used for restricted connections.
  enum restrictedFormat = q{
    static if (hasUDA!(%1$s.%2$s, HttpRestricted))
    {
      static if (hasUDA!(%1$s.%2$s, HttpDefault))
      {
        _restrictedActions.add("/");
      }
      else static if (hasUDA!(%1$s.%2$s, HttpAction))
      {
        _restrictedActions.add(
          (
            action_%2$s.action && action_%2$s.action.strip().length ?
            action_%2$s.action : "%2$s"
          ).firstToLower()
        );
      }
    }
  };
}

// WebServer's will have a view associated with the controller, the view then contains information about the request etc.
static if (isWebServer)
{
  public import diamond.views.view;

  /// Wrapper around a controller.
  class Controller(TView) : BaseController
  {
    private:
    /// The view associatedi with the controller.
    TView _view;

    /// The authentication used for the controller.
    IControllerAuth _auth;

    /// Hash set of actions with disabled authentication.
    HashSet!string _disabledAuth;

    /// Hash set of actions with restrictions.
    HashSet!string _restrictedActions;

    protected:
    /**
    * Creates a new controller.
    * Params:
    *   view =  The view associated with the controller.
    */
    this(this TController)(TView view)
    {
      super();

      _view = view;

      mixin("import diamondapp : " ~ TController.stringof.split("!")[1][1 .. $-1] ~ ";");

      import controllers;
      auto controller = cast(TController)this;

      static if (hasUDA!(TController, HttpAuthentication))
      {
        enum authenticationUDA = getUDAs!(TController, HttpAuthentication)[0];

        mixin("_auth = new " ~ authenticationUDA.authenticationClass ~ ";");
        _disabledAuth = new HashSet!string;
      }

      _restrictedActions = new HashSet!string;

      auto fullName = fullyQualifiedName!TController;

      if (!_mappedControllers)
      {
        _mappedControllers = new HashSet!string;
      }

      foreach (member; __traits(derivedMembers, TController))
      {
        static if (member != "__ctor")
        {
          mixin(defaultMappingFormat.format(TController.stringof, member));
          mixin(mandatoryMappingFormat.format(TController.stringof, member));
          mixin(actionMappingFormat.format(TController.stringof, member));
          mixin(disableAuthFormat.format(TController.stringof, member));
          mixin(restrictedFormat.format(TController.stringof, member));
        }
      }

      if (!_mappedControllers[fullName])
      {
        _mappedControllers.add(fullName);
      }
    }

    public:
    final:
    @property
    {
      /// Gets the view.
      TView view() { return _view; }
    }

    /**
    * Generates a json response.
    * Params:
    *   jsonObject =  The object to serialize as json.
    * Returns:
    *   A status of Status.end
    */
    Status json(T)(T jsonObject)
    {
      import vibe.d : serializeToJsonString;
      return jsonString(jsonObject.serializeToJsonString());
    }

    /**
    * Generates a json response from a json string.
    * Params:
    *   s =  The json string.
    * Returns:
    *   A status of Status.end
    */
    Status jsonString(string s)
    {
      import diamond.core.webconfig;
      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        _view.client.rawResponse.headers[headerKey] = headerValue;
      }

      _view.client.rawResponse.headers["Content-Type"] = "text/json; charset=UTF-8";
      _view.client.rawResponse.bodyWriter.write(s);

      return Status.end;
    }

    /**
    * Redirects the response to a specific url.
    * Params:
    *   url =     The url to redirect to.
    *   status =  The status of the redirection. (Default is HTTPStatus.Found)
    * Returns:
    *   The status required for the redirection to work properly. (Status.end)
    */
    Status redirectTo(string url, HttpStatus status = HttpStatus.found)
    {
      _view.client.redirect(url, status);

      return Status.end;
    }

    /**
    * Gets a value from the route's parameters by index.
    * Params:
    *   index =        The index.
    *   defaultValue = The default value.
    * Returns:
    *   The value from the route's parameters if found, else the default value.
    */
    T getByIndex(T)(size_t index, T defaultValue = T.init)
    {
      if (index < 0 || index >= _view.route.params.length)
      {
        return defaultValue;
      }

      return _view.route.getData!T(index);
    }

    /**
    * Handles the view's current controller action.
    * Returns:
    *     The status of the controller action.
    */
    Status handle()
    {
      if (_view.isDefaultRoute)
      {
        if (_restrictedActions["/"])
        {
          validateRestrictedIPs(view.client);
        }

        if (_auth && !_disabledAuth["/"])
        {
          auto authStatus = _auth.isAuthenticated(view.client);

          if (!authStatus || !authStatus.authenticated)
          {
            _auth.authenticationFailed(authStatus);
            return Status.end;
          }
        }

        if (_mandatoryAction)
        {
          auto mandatoryResult = _mandatoryAction();

          if (mandatoryResult != Status.success)
          {
            return mandatoryResult;
          }
        }

        if (_defaultAction)
        {
          return _defaultAction();
        }

        return Status.success;
      }

      ActionEntry methodEntries = _actions.get(_view.httpMethod, null);

      if (!methodEntries)
      {
          return Status.notFound;
      }

      auto action = methodEntries.get(_view.route.action, null);

      if (!action)
      {
        return Status.notFound;
      }

      if (_restrictedActions[_view.route.action])
      {
        validateRestrictedIPs(view.client);
      }

      if (_auth && !_disabledAuth[_view.route.action])
      {
        auto authStatus = _auth.isAuthenticated(view.client);

        if (!authStatus || !authStatus.authenticated)
        {
          _auth.authenticationFailed(authStatus);
          return Status.end;
        }
      }

      if (_mandatoryAction)
      {
        auto mandatoryResult = _mandatoryAction();

        if (mandatoryResult != Status.success)
        {
          return mandatoryResult;
        }
      }

      auto routeData = _mappedRoutes.get(_view.route.action, null);

      if (routeData)
      {
        validateRoute(routeData, view.route.params);
      }

      return action();
    }

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.controllerExtension, q{
      mixin {{extensionEntry}}.extensions;
    });
  }
}
// A webapi will not have a view associated with it, thus all information such as the request etc. is available within the controller
else static if (isWebApi)
{
  /// Wrapper around a controller.
  class Controller : BaseController
  {
    private:
    /// The client.
    HttpClient _client;

    /// The authentication used for the controller.
    IControllerAuth _auth;

    /// Hash set of actions with disabled authentication.
    HashSet!string _disabledAuth;

    /// Hash set of actions with restrictions.
    HashSet!string _restrictedActions;

    protected:
    /**
    * Creates a new controller.
    * Params:
    *   client =    The client of the controller.
    *   controller = The controller itself
    */
    this(this TController)(HttpClient client)
    {
      super();

      _client = client;

      import controllers;
      auto controller = cast(TController)this;

      static if (hasUDA!(TController, HttpAuthentication))
      {
        enum authenticationUDA = getUDAs!(TController, HttpAuthentication)[0];

        mixin("_auth = new " ~ authenticationUDA.authenticationClass ~ ";");
        _disabledAuth = new HashSet!string;
      }

      _restrictedActions = new HashSet!string;

      auto fullName = fullyQualifiedName!TController;

      if (!_mappedControllers)
      {
        _mappedControllers = new HashSet!string;
      }

      foreach (member; __traits(derivedMembers, TController))
      {
        static if (member != "__ctor")
        {
          mixin(defaultMappingFormat.format(TController.stringof, member));
          mixin(mandatoryMappingFormat.format(TController.stringof, member));
          mixin(actionMappingFormat.format(TController.stringof, member));
          mixin(disableAuthFormat.format(TController.stringof, member));
          mixin(restrictedFormat.format(TController.stringof, member));
        }
      }

      if (!_mappedControllers[fullName])
      {
        _mappedControllers.add(fullName);
      }
    }

    public:
    final:
    @property
    {
        /// Gets the client.
        auto client() { return _client; }
        /// Gets the http method.
        auto httpMethod() { return _client.method; }
        /// Gets the route.
        auto route() { return client.route; }
      }

    /**
    * Generates a json response.
    * Params:
    *   jsonObject =  The object to serialize as json.
    * Returns:
    *   A status of Status.end
    */
    Status json(T)(T jsonObject)
    {
      import vibe.d : serializeToJsonString;

      return jsonString(jsonObject.serializeToJsonString());
    }

    /**
    * Generates a json response from a json string.
    * Params:
    *   s =  The json string.
    * Returns:
    *   A status of Status.end
    */
    Status jsonString(string s)
    {
      import diamond.core.webconfig;
      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        _client.rawResponse.headers[headerKey] = headerValue;
      }

      _client.rawResponse.headers["Content-Type"] = "text/json; charset=UTF-8";
      _client.rawResponse.bodyWriter.write(s);

      return Status.end;
    }

    /**
    * Redirects the response to a specific url.
    * Params:
    *   url =     The url to redirect to.
    *   status =  The status of the redirection. (Default is HTTPStatus.Found)
    * Returns:
    *   The status required for the redirection to work properly. (Status.end)
    */
    Status redirectTo(string url, HttpStatus status = HttpStatus.found)
    {
      _client.redirect(url, status);

      return Status.end;
    }

    /**
    * Gets a value from the route's parameters by index.
    * Params:
    *   index =        The index.
    *   defaultValue = The default value.
    * Returns:
    *   The value from the route's parameters if found, else the default value.
    */
    T getByIndex(T)(size_t index, T defaultValue = T.init)
    {
      if (index < 0 || index >= route.params.length)
      {
        return defaultValue;
      }

      return route.getData!T(index);
    }

    /**
    * Handles the current controller action.
    * Returns:
    *     The status of the controller action.
    */
    final override Status handle()
    {
      if (!route.action)
      {
        if (_restrictedActions["/"])
        {
          validateRestrictedIPs(_client);
        }

        if (_auth && !_disabledAuth["/"])
        {
          auto authStatus = _auth.isAuthenticated(_client);

          if (!authStatus || !authStatus.authenticated)
          {
            _auth.authenticationFailed(authStatus);
            return Status.end;
          }
        }

        if (_mandatoryAction)
        {
          auto mandatoryResult = _mandatoryAction();

          if (mandatoryResult != Status.success)
          {
            return mandatoryResult;
          }
        }

        if (_defaultAction)
        {
          return _defaultAction();
        }

        return Status.notFound;
      }

      ActionEntry methodEntries = _actions.get(httpMethod, null);

      if (!methodEntries)
      {
        return Status.notFound;
      }

      auto action = methodEntries.get(route.action, null);

      if (!action)
      {
        return Status.notFound;
      }

      if (_restrictedActions[route.action])
      {
        validateRestrictedIPs(client);
      }

      if (_auth && !_disabledAuth[route.action])
      {
        auto authStatus = _auth.isAuthenticated(client);

        if (!authStatus || !authStatus.authenticated)
        {
          _auth.authenticationFailed(authStatus);
          return Status.end;
        }
      }

      if (_mandatoryAction)
      {
        auto mandatoryResult = _mandatoryAction();

        if (mandatoryResult != Status.success)
        {
          return mandatoryResult;
        }
      }

      auto routeData = _mappedRoutes.get(route.action, null);

      if (routeData)
      {
        validateRoute(routeData, route.params);
      }

      return action();
    }

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.controllerExtension, q{
      mixin {{extensionEntry}}.extensions;
    });
  }

  /// Mixin template for generating the controllers.
  mixin template GenerateControllers(string[] controllerInitializers)
  {
    import std.traits : hasUDA, getUDAs;
	  import controllers;

    /// Format for generating the routes for controllers.
    private enum generateFormat = q{
      static if (hasUDA!(%sController, HttpRoutes))
      {
        static const controller_%s = getUDAs!(%sController, HttpRoutes)[0];

        foreach (controllerRoute; controller_%s.routes)
        {
          import diamond.core.string : firstToLower;

          controllerCollection[controllerRoute.firstToLower()] = new GenerateControllerAction((client)
          {
             return new %sController(client);
          });
        }
      }
      else
      {
        controllerCollection["%s"] = new GenerateControllerAction((client)
        {
           return new %sController(client);
        });
      }
    };

     /// Generates the controller collection.
	  string generateControllerCollection()
    {
		  auto controllerCollectionResult = "";

		  foreach (controller; controllerInitializers)
      {
        import std.string : format;
		    controllerCollectionResult ~=
          format
          (
            generateFormat,
            controller, controller, controller,
            controller, controller,
            controller.firstToLower(),
            controller
          );
		  }

		  return controllerCollectionResult;
	  }

    /// The controller collection.
    GenerateControllerAction[string] controllerCollection;

    /// Gets a controller by its name
    GenerateControllerAction getControllerAction(string name)
    {
      if (!controllerCollection || !controllerCollection.length)
      {
        mixin(generateControllerCollection);
      }

		  return controllerCollection.get(name, null);
	 }
  }
}
