/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.view;

import diamond.core.apptype;

static if (!isWebApi)
{
  import std.string : format, strip;
  import std.array : join, replace, split, array;
  import std.conv : to;
  import std.algorithm : filter;

  static if (isWebServer)
  {
    import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPMethod;

    import diamond.http;
  }

  /**
  * Template to get the type name of a view.
  * Params:
  *   name = The name of the view.
  */
  template ViewTypeName(string name)
  {
    mixin("alias ViewTypeName = view_" ~ name ~ ";");
  }

  /// The abstract wrapper for views.
  abstract class View
  {
    private:
    static if (isWebServer)
    {
      /// The request.
      HTTPServerRequest _request;

      /// The response.
      HTTPServerResponse _response;

      /// The route.
      Route _route;
    }

    /// The name of the view.
    string _name;

    /// The place holders.
    string[string] _placeHolders;

    /// The result.
    string _result;

    /// The root path.
    string _rootPath;

    protected:
    static if (isWebServer)
    {
      /**
      * Creates a new view.
      * Params:
      *   request =   The request of the view.
      *   response =  The response of the view.
      *   name =      The name of the view.
      *   route =     The route of the view.
      */
      this(HTTPServerRequest request, HTTPServerResponse response,
        string name, Route route)
      {
        _request = request;
        _response = response;
        _name = name;
        _route = route;

        _placeHolders["doctype"] = "<!DOCTYPE html>";
        _placeHolders["defaultRoute"] = _route.name;
      }
    }
    else
    {
      /**
      * Creates a new view.
      * Params:
      *   name = The name of the view.
      */
      this(string name)
      {
        _name = name;
      }
    }

    public:
    @property
    {
      static if (isWebServer)
      {
        /// Gets the request.
        HTTPServerRequest httpRequest() { return _request; }

        /// Gets the response.
        HTTPServerResponse httpResponse() { return _response; }

        /// Gets the method.
        HTTPMethod httpMethod() { return _request.method; }

        /// Gets the route.
        Route route() { return _route; }

        /// Gets a boolean determining whether the route is the default route or not.
        bool isDefaultRoute()
        {
          return !_route.action || !route.action.length;
        }

        /// Gets the root path.
        final string rootPath()
        {
          if (_rootPath)
          {
            return _rootPath;
          }

          // This makes sure that it's not retrieving the page's route, but the requests.
          // It's useful in terms of a view redirecting to another view internally.
          // Since the redirected view will have the route of the redirection and not the request.
          scope auto path = httpRequest.path == "/" ? "default" : httpRequest.path[1 .. $];
          scope auto route = path.split("/").filter!(p => p && p.strip().length).array;

          if (!route || route.length <= 1)
          {
            return "..";
          }

          auto rootPathValue = "";

          foreach (i; 0 .. route.length)
          {
            rootPathValue ~= (i == (route.length - 1) ? ".." : "../");
          }

          return rootPathValue;
        }
      }

      /// Gets the name.
      string name() { return _name; }

      /// Sets the name.
      void name(string name)
      {
        _name = name;
      }
    }

    final
    {
      /**
      * Adds a place holder to the view.
      * Params:
      *   key =   The key of the place holder.
      *   value = The value of the place holder.
      */
      void addPlaceHolder(string key, string value)
      {
        _placeHolders[key] = value;
      }

      /**
      * Prepares the view with its layout, placeholders etc.
      * Params:
      *   layoutName = The name of the layout to prepare the view with.
      * Returns:
      *   The resulting string after the view has been rendered with its layout.
      */
      string prepare(string layoutName = null)
      {
        string result = _result.dup;

        if (layoutName)
        {
          auto layoutView = view(layoutName);

          if (layoutView)
          {
            layoutView.name = name;

            auto layoutResult = layoutView.generate();

            auto headPlaceHolder = _placeHolders.get("head", null);

            if (headPlaceHolder)
            {
              layoutResult = layoutResult.replace("@<head>", headPlaceHolder);
            }

            result = layoutResult.replace("@<view>", result);
          }
        }

        foreach (key,value; _placeHolders)
        {
          result = result.replace(format("@<%s>", key), value);
        }

        static if (isWebServer)
        {
          return result.replace("@..", rootPath);
        }
        else
        {
          return result;
        }
      }

      /**
      * Appends data to the view's result.
      * This will append data to the current position.
      * Generally this is not necessary, because of the template attributes such as @=
      * Params:
      *   data =  The data to append.
      */
      void append(T)(T data)
      {
        _result ~= to!string(data);
      }

      /**
      * Appends html escaped data to the view's result.
      * This will append data to the current position.
      * Generally this is not necessary, because of the template attributes such as @(), @$= etc.
      * Params:
      *   data =  The data to escape.
      */
      void escape(T)(T data)
      {
        auto toEscape = to!string(data);
        string result = "";

        foreach (c; toEscape)
        {
          switch (c)
          {
            case '<':
            {
              result ~= "&lt;";
              break;
            }

            case '>':
            {
              result ~= "&gt;";
              break;
            }

            case '"':
            {
              result ~= "&quot;";
              break;
            }

            case '\'':
            {
              result ~= "&#39";
              break;
            }

            case '&':
            {
              result ~= "&amp;";
              break;
            }

            case ' ':
            {
              result ~= "&nbsp;";
              break;
            }

            default:
            {
              if (c < ' ')
              {
                result ~= format("&#%d;", c);
              }
              else
              {
                result ~= to!string(c);
              }
            }
          }
        }

        append(result);
      }

      /**
      * Gets th current view as a specific view.
      * Params:
      *   name = The name of the view to get the view as.
      * Returns:
      *   The view converted to the specific view.
      */
      auto asView(string name)()
      {
        mixin("import diamondapp : getView, view_" ~ name ~ ";");

        static if (isWebServer)
        {
          mixin("return cast(view_" ~ name ~ ")this;");
        }
        else
        {
          mixin("return cast(view_" ~ name ~ ")this;");
        }
      }

      /**
      * Retrieves a raw view by name.
      * This wraps around getView.
      * Params:
      *   name =        The name of the view to retrieve.
      *   checkRoute =  Boolean determining whether the name should be checked upon default routes. (Value doesn't matter if it isn't a webserver.)
      * Returns:
      *   The view.
      */
      auto viewRaw(string name)(bool checkRoute = false) {
        mixin("import diamondapp : getView, view_" ~ name ~ ";");

        static if (isWebServer)
        {
          mixin("return cast(view_" ~ name ~ ")getView(_request, _response, new Route(name), checkRoute);");
        }
        else
        {
          mixin("return cast(view_" ~ name ~ ")getView(name);");
        }
      }

      /**
      * Retrieves a view by name.
      * This wraps around getView.
      * Params:
      *   name =        The name of the view to retrieve.
      *   checkRoute =  Boolean determining whether the name should be checked upon default routes. (Value doesn't matter if it isn't a webserver.)
      * Returns:
      *   The view.
      */
      auto view(string name, bool checkRoute = false)
      {
        import diamondapp : getView;

        static if (isWebServer)
        {
          return getView(this.httpRequest, this.httpResponse, new Route(name), checkRoute);
        }
        else
        {
          return getView(name);
        }
      }

      /**
      * Retrieves the generated result of a view.
      * This should generally only be used to render partial views into another view.
      * Params:
      *   name =        The name of the view to generate the result of.
      *   sectionName = The name of the setion to retrieve the generated result of.
      * Returns:
      *   A string qeuivalent to the generated result.
      */
      string retrieve(string name, string sectionName = "")
      {
        return view(name).generate(sectionName);
      }

      /**
      * Will render another view into this one.
      * Params:
      *   name =        The name of the view to render.
      *   sectionName = The name of the section to render.
      */
      void render(string name, string sectionName = "")
      {
        append(retrieve(name, sectionName));
      }

      /**
      * Retrieves the generated result of a view.
      * This should generally only be used to render partial views into another view.
      * Params:
      *   name =        The name of the view to generate the result of.
      *   sectionName = The name of the section to retrieve the result of.
      * Returns:
      *   A string qeuivalent to the generated result.
      */
      string retrieve(string name)(string sectionName = "")
      {
        return viewRaw!name.generate(sectionName);
      }

      /**
      * Will render another view into this one.
      * Params:
      *   name =        The name of the view to render.
      *   sectionName = The name of the section to render.
      */
      void render(string name)(string sectionName = "")
      {
        append(retrieve!name(sectionName));
      }

      /**
      * Retrieves the generated result of a view.
      * This should generally only be used to render partial views into another view.
      * Params:
      *   name =  The name of the view to generate the result of.
      * Returns:
      *   A string qeuivalent to the generated result.
      */
      string retrieveModel(string name, TModel)(TModel model, string sectionName = "")
      {
        return viewRaw!name.generateModel(model, sectionName);
      }

      /**
      * Will render another view into this one.
      * Params:
      *   name =  The name of the view to render.
      */
      void renderModel(string name, TModel)(TModel model, string sectionName = "")
      {
        append(retrieveModel!(name, TModel)(model, sectionName));
      }

      static if (isWebServer)
      {
        import CSRF = diamond.security.csrf;

        /// Clears the current csrf token. This is recommended before generating CSRF token fields.
        void clearCSRFToken()
        {
          CSRF.clearCSRFToken(httpRequest, httpResponse);
        }

        /**
        * Appends a hidden-field with a generated token that can be used for csrf protection.
        * Params:
        *   name =       A custom name for the field.
        *   appendName = Boolean determining if the custom name should be appened to the default name "formToken".
        */
        void appendCSRFTokenField(string name = null, bool appendName = false)
        {
          bool hasName = name && name.strip().length;

          if (!hasName)
          {
            name = "formToken";
          }
          else if (appendName && hasName)
          {
            name = "formToken_" ~ name;
          }

          auto csrfToken = CSRF.generateCSRFToken(httpRequest, httpResponse);

          append
          (
            `<input type="hidden" value="%s" name="%s" id="%s">`
            .format(csrfToken, name, name)
          );
        }
      }
    }

    /**
    * Generates the result of the view.
    * This is override by each view implementation.
    * Returns:
    *   A string equivalent to the generated result.
    */
    string generate(string sectionName = "")
    {
      return prepare();
    }

    import diamond.extensions;
    mixin ExtensionEmit!(ExtensionType.viewExtension, q{
      mixin {{extensionEntry}}.extensions;
    });
  }
}
