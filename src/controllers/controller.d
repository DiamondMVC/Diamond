/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.controller;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.d;

  import diamond.controllers.action;
  import diamond.controllers.status;
  import diamond.controllers.basecontroller;
  import diamond.controllers.mapattributes;
}

static if (isWeb)
{
  import std.string : strip, format, toLower;
  import std.traits : hasUDA, getUDAs;

  enum defaultMappingFormat = q{
    static if (hasUDA!(%s.%s, HttpDefault))
    {
      mapDefault(&controller.%s);
    }
  };

  enum mandatoryMappingFormat = q{
    static if (hasUDA!(%s.%s, HttpMandatory))
    {
      mapMandatory(&controller.%s);
    }
  };

  enum actionMappingFormat = q{
    static if (hasUDA!(%s.%s, HttpAction))
    {
      static const action_%s = getUDAs!(%s.%s, HttpAction)[0];

      mapAction(
        action_%s.method,
        (action_%s.action && action_%s.action.strip().length ?
        action_%s.action : "%s").toLower(),
        &controller.%s
      );
    }
  };
}

// WebServer's will have a view associated with the controller, the view then contains information about the request etc.
static if (isWebServer)
{
  /// Wrapper around a controller.
  class Controller(TView) : BaseController
  {
    private:
    /// The view associatedi with the controller.
    TView _view;

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

      foreach (member; __traits(derivedMembers, TController))
      {
        static if (member != "__ctor")
        {
          mixin(defaultMappingFormat.format(TController.stringof, member, member));
          mixin(mandatoryMappingFormat.format(TController.stringof, member, member));
          mixin(actionMappingFormat.format(
            TController.stringof, member,
            member, TController.stringof, member,
            member,
            member, member,
            member, member,
            member
          ));
        }
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
        _view.httpResponse.headers[headerKey] = headerValue;
      }

      _view.httpResponse.headers["Content-Type"] = "text/json; charset=UTF-8";
      _view.httpResponse.bodyWriter.write(s);

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
    Status redirectTo(string url, HTTPStatus status = HTTPStatus.Found)
    {
      _view.httpResponse.redirect(url, status);

      import diamond.core.webconfig;
      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        _view.httpResponse.headers[headerKey] = headerValue;
      }

      return Status.end;
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

      if (_mandatoryAction)
      {
        auto mandatoryResult = _mandatoryAction();

        if (mandatoryResult != Status.success)
        {
          return mandatoryResult;
        }
      }

      return action();
    }
  }
}
// A webapi will not have a view associated with it, thus all information such as the request etc. is available within the controller
else static if (isWebApi)
{
  import diamond.http : Route;

  /// Wrapper around a controller.
  class Controller : BaseController
  {
    private:
    /// The request.
    HTTPServerRequest _request;
    /// The response.
    HTTPServerResponse _response;
    /// The route.
    Route _route;

    protected:
    /**
    * Creates a new controller.
    * Params:
    *   request =    The request of the controller.
    *   response =   The response of the controller.
    *   route =      The route of the controller.
    *   controller = The controller itself
    */
    this(this TController)(HTTPServerRequest request, HTTPServerResponse response, Route route)
    {
      super();

      _request = request;
      _response = response;
      _route = route;

      import controllers;
      auto controller = cast(TController)this;

      foreach (member; __traits(derivedMembers, TController))
      {
        static if (member != "__ctor")
        {
          mixin(defaultMappingFormat.format(TController.stringof, member, member));
          mixin(mandatoryMappingFormat.format(TController.stringof, member, member));
          mixin(actionMappingFormat.format(
            TController.stringof, member,
            member, TController.stringof, member,
            member,
            member, member,
            member, member,
            member
          ));
        }
      }
    }

    public:
    final:
    @property
    {
        /// Gets the request.
        auto httpRequest() { return _request; }
        /// Gets the response.
        auto httpResponse() { return _response; }
        /// Gets the http method.
        auto httpMethod() { return _request.method; }
        /// Gets the route.
        auto route() { return _route; }
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
        httpResponse.headers[headerKey] = headerValue;
      }

      httpResponse.headers["Content-Type"] = "text/json; charset=UTF-8";
      httpResponse.bodyWriter.write(s);

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
    Status redirectTo(string url, HTTPStatus status = HTTPStatus.Found)
    {
      httpResponse.redirect(url, status);

      import diamond.core.webconfig;
      foreach (headerKey,headerValue; webConfig.defaultHeaders.general)
      {
        httpResponse.headers[headerKey] = headerValue;
      }

      return Status.end;
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

      if (_mandatoryAction)
      {
        auto mandatoryResult = _mandatoryAction();

        if (mandatoryResult != Status.success)
        {
          return mandatoryResult;
        }
      }

      return action();
    }
  }

  /// Mixin template for generating the controllers.
  mixin template GenerateControllers(string[] controllerInitializers)
  {
  	  import controllers;

       /// Generates the controller collection.
  	  string generateControllerCollection()
      {
  		  enum generateFormat = q{
  		      controllerCollection["%s"] = new GenerateControllerAction((request, response, route)
            {
  			       return new %sController(request, response, route);
  		      });
  		  };

  		  auto controllerCollectionResult = "";

        import std.string : toLower;

  		  foreach (controller; controllerInitializers)
        {
          import std.string : format;
			    controllerCollectionResult ~= format(generateFormat, controller.toLower(), controller);
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
