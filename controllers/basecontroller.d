/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.basecontroller;

import diamond.core.apptype;

static if (isWeb)
{
  import std.conv : to;
  import std.variant : Variant;
  import std.traits : EnumMembers;
  import std.algorithm : filter;
  import std.array : array;
  import std.string : strip;

  import diamond.http;
  import diamond.controllers.action;
  import diamond.controllers.status;
  import diamond.errors;
  import diamond.core.collections;
  import diamond.controllers.rest;

  /// Wrapper for a base controller.
  abstract class BaseController
  {
    package(diamond.controllers)
    {
      /// Data passed by the request in a RESTful manner.
      Variant[string] _data;

      /**
      * Valiates a route and the passed source data to it.
      * Params:
      *   routeData =  The route part data.
      *   sourceData = The data passed.
      */
      void validateRoute(RoutePart[] routeData, string[] sourceData)
      {
        if (!sourceData)
        {
          throw new RouteException("Passed no data to the route.");
        }

        sourceData = sourceData.filter!(d => d && d.strip().length).array;

        if (sourceData.length != (routeData.length - 1))
        {
          throw new RouteException("Passed invalid amount of arguments to the route.");
        }

        foreach (i; 0 .. sourceData.length)
        {
          auto rData = routeData[i + 1];
          auto data = sourceData[i].strip();

          switch (rData.routeType)
          {
            case RouteType.identifier:
            {
              if (rData.identifier != data)
              {
                throw new RouteException("Expected '" ~ rData.identifier ~ "' as identifier in the route.");
              }

              break;
            }

            case RouteType.type:
            {
              final switch (rData.type)
              {
                foreach (memberIndex, member; EnumMembers!RouteDataType)
                {
                  mixin(
                    "case RouteDataType." ~
                    to!string(cast(RouteDataType)member) ~
                    ": mapValue!" ~
                    member ~
                    "(data); break;"
                  );
                }
              }

              break;
            }

            case RouteType.typeIdentifier:
            {
              final switch (rData.type)
              {
                foreach (memberIndex, member; EnumMembers!RouteDataType)
                {
                  mixin(
                    "case RouteDataType." ~
                    to!string(cast(RouteDataType)member) ~
                    ": mapValue!" ~
                    member ~
                    "(data, rData.identifier); break;"
                  );
                }
              }

              break;
            }

            default: break;
          }
        }
      }

      /**
      * Maps a value that was passed to the route in a RESTful manner.
      * Params:
      *   data = The to be mapped.
      *   mapName = The name to map it as. If no name is passed then conversion is just validated.
      */
      void mapValue(T)(string data, string mapName = null)
      {
        static if (is(typeof(T) == typeof(string)))
        {
          alias value = data;
        }
        else
        {
          T value = to!T(data);
        }

        if (mapName)
        {
          _data[mapName] = value;
        }
      }
    }

    protected:
    /// Alias for the action entry.
    alias ActionEntry = Action[string];
    /// Alias for the method entry.
    alias MethodEntry = ActionEntry[HttpMethod];

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
    void mapAction(HttpMethod method, string action, Action fun)
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
    void mapAction(HttpMethod method, string action, Status delegate() d)
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
    void mapAction(HttpMethod method, string action, Status function() f)
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

    /**
    * Gets a value from the passed data.
    * Params:
    *   name =          The name of the value to get.
    *   defaultValue =  The default value.
    * Returns:
    *   Returns the value if found, else the default value.
    */
    T get(T)(string name, T defaultValue = T.init)
    {
      Variant emptyVariant;
      auto value = _data.get(name, emptyVariant);

      return value.hasValue ? value.get!T : defaultValue;
    }
  }
}
