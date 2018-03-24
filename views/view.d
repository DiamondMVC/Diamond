/**
* Copyright © DiamondMVC 2018
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

  import diamond.errors.checks;

  static if (isWebServer)
  {
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
      /// The client.
      HttpClient _client;

      /// Boolean determnining whether the view can be cached or not.
      bool _cached;
    }

    /// The name of the view.
    string _name;

    /// The placeholders.
    string[string] _placeholders;

    /// The result.
    string _result;

    /// The layout view.
    string _layoutName;

    /// Boolean determining whether the page rendering is delayed.
    bool _delayRender;

    /// The view that's currently rendering the layout view.
    View _renderView;

    /// Boolean determining whether the view generation is raw or if it should call controllers etc.
    bool _rawGenerate;

    protected:
    static if (isWebServer)
    {
      /**
      * Creates a new view.
      * Params:
      *   client =    The client.
      *   name =      The name of the view.
      */
      this(HttpClient client, string name)
      {
        _client = enforceInput(client, "Cannot create a view without an associated client.");
        _name = name;

        _placeholders["doctype"] = "<!DOCTYPE html>";
        _placeholders["defaultRoute"] = _client.route.name;

        import diamond.extensions;
        mixin ExtensionEmit!(ExtensionType.viewCtorExtension, q{
          mixin {{extensionEntry}}.extension;
        });

        static if (__traits(compiles, { onViewCtor();}))
        {
          onViewCtor();
        }
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

    static if (isWebServer)
    {
      protected:
      @property
      {
        /// Sets a boolean determining whether the view can be cached or not.
        void cached(bool canBeCached)
        {
          _cached = canBeCached;
        }
      }
    }

    public:
    @property
    {
      static if (isWebServer)
      {
        /// Gets a boolean determining whether the view can be cached or not.
        bool cached() { return _cached; }

        /// Gets the client.
        HttpClient client() { return _client; }

        /// Gets the method.
        HttpMethod httpMethod() { return _client.method; }

        /// Gets the route.
        Route route() { return _client.route; }

        /// Gets a boolean determining whether the route is the default route or not.
        bool isDefaultRoute()
        {
          return !route.action || !route.action.length;
        }

        static if (isTesting)
        {
          import diamond.unittesting;

          /// Gets a boolean determnining whether the request is a test or not.
          bool testing() { return !testsPassed; }
        }
      }

      /// Gets the name.
      string name() { return _name; }

      /// Sets the name.
      void name(string name)
      {
        _name = name;
      }

      /// Gets the layout name.
      string layoutName() { return _layoutName; }

      /// Sets the layout name.
      void layoutName(string newLayoutName)
      {
        _layoutName = newLayoutName;
      }

      /// Gets a boolean determining whether the rendering is delayed.
      bool delayRender() { return _delayRender; }

      /// Sets a boolean determining whether the rendering is delayed.
      void delayRender(bool isDelayed)
      {
        _delayRender = isDelayed;
      }

      /// Gets the view that's currently rendering the layout view.
      View renderView() { return _renderView; }

      /// Sets a new render view.
      void renderView(View newRenderView)
      {
        _renderView = newRenderView;

        copyViewData();
      }

      /// Gets a boolean determining whether the view generation is raw or if it should call controllers etc.
      bool rawGenerate() { return _rawGenerate; }

      /// Sets a boolean determining whether the view generation is raw or if it should call controllers etc.
      void rawGenerate(bool isRawGenerate)
      {
        _rawGenerate= isRawGenerate;
      }
    }

    protected void copyViewData()
    {
      static if (isWebServer)
      {
        _client = _renderView._client;
        _cached = _renderView._cached;
      }

      _placeholders = _renderView._placeholders;
    }

    final
    {
      /// Clears the view result.
      void clearView()
      {
        _result = "";
      }

      /**
      * Adds a place holder to the view.
      * Params:
      *   key =   The key of the place holder.
      *   value = The value of the place holder.
      */
      deprecated("Please use addPlaceholder() -- Will be removed in 2.9.0") void addPlaceHolder(string key, string value)
      {
        addPlaceholder(key, value);
      }

      /**
      * Gets a place holder of the view.
      * Params:
      *   key =   The key of the place holder.
      * Returns:
      *   Returns the place holder.
      */
      deprecated("Please use getPlaceholder() -- Will be removed in 2.9.0") string getPlaceHolder(string key)
      {
        return getPlaceholder(key);
      }

      /**
      * Adds a place holder to the view.
      * Params:
      *   key =   The key of the place holder.
      *   value = The value of the place holder.
      */
      void addPlaceholder(string key, string value)
      {
        _placeholders[key] = value;
      }

      /**
      * Gets a place holder of the view.
      * Params:
      *   key =   The key of the place holder.
      * Returns:
      *   Returns the place holder.
      */
      string getPlaceholder(string key)
      {
        return _placeholders.get(key, null);
      }

      /**
      * Prepares the view with its layout, placeholders etc.
      * Returns:
      *   The resulting string after the view has been rendered with its layout.
      */
      string prepare()
      {
        string result = _delayRender ? "" : cast(string)_result.dup;

        if (_layoutName && _layoutName.strip().length)
        {
          auto layoutView = view(_layoutName);

          if (layoutView)
          {
            layoutView.name = name;
            layoutView._renderView = this;

            layoutView.addPlaceholder("view", result);

            foreach (key,value; _placeholders)
            {
              layoutView.addPlaceholder(key, value);
            }

            result = layoutView.generate();
          }
        }

        return result;
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
          mixin("return cast(view_" ~ name ~ ")getView(_client, new Route(name), checkRoute);");
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
          return getView(_client, new Route(name), checkRoute);
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
        /**
        * Gets a route that fits an action for the current route.
        * Params:
        *   actionName = The name of the action to get.
        * Returns:
        *   A new constructed route with the given action name.
        */
        string action(string actionName)
        {
          enforce(actionName, "No action given.");

          return "/" ~ route.name ~ "/" ~ actionName;
        }

        /**
        * Gets a route that fits an action and parameters for the current route.
        * Params:
        *   actionName = The name of the action to get.
        *   params =     The data parameters to give the route.
        * Returns:
        *   A new constructed route with the given action name and parameters.
        */
        string actionParams(string actionName, string[] params)
        {
          enforce(actionName, "No action given.");
          enforce(params, "No parameters given.");

          return action(actionName) ~ "/" ~ params.join("/");
        }

        /**
        * Inserts a javascript file in a script tag.
        * Params:
        *   file = The javascript file.
        */
        void script(string file)
        {
          append("<script src=\"%s\"></script>".format(file));
        }

        /**
        * Inserts an asynchronous javascript file in a script tag.
        * Params:
        *   file = The javascript file.
        */
        void asyncScript(string file)
        {
          append("<script src=\"%s\" async></script>".format(file));
        }

        /**
        * Inserts a javascript file in a script tag after the page has loaded.
        * Params:
        *   file = The javascript file.
        */
        void deferScript(string file)
        {
          append("<script src=\"%s\" defer></script>".format(file));
        }

        import CSRF = diamond.security.csrf;

        /// Clears the current csrf token. This is recommended before generating CSRF token fields.
        void clearCSRFToken()
        {
          CSRF.clearCSRFToken(_client);
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

          auto csrfToken = CSRF.generateCSRFToken(_client);

          append
          (
            `<input type="hidden" value="%s" name="%s" id="%s">`
            .format(csrfToken, name, name)
          );
        }

        enum FlashMessageType
        {
          always,
          showOnce,
          showOnceGuest,
          custom
        }

        void flashMessage(string identifier, string message, FlashMessageType type, size_t displayTime = 0)
        {
          enforce(identifier && identifier.length, "No identifier specified.");

          auto sessionValueName = "__D_FLASHMSG_" ~ _name ~ identifier;

          switch (type)
          {
            case FlashMessageType.showOnce:
            {
              if (_client.session.hasValue(sessionValueName))
              {
                return;
              }

              _client.session.setValue(sessionValueName, true);
              break;
            }

            case FlashMessageType.showOnceGuest:
            {
              import diamond.authentication.roles : defaultRole;

              if (_client.role && _client.role != defaultRole)
              {
                return;
              }

              if (_client.session.hasValue(sessionValueName))
              {
                return;
              }

              _client.session.setValue(sessionValueName, true);
              break;
            }

            default: break;
          }

          append(`
            <div id="%s">
              %s
            </div>
          `.format(identifier, message));

          if (displayTime > 0 && type != FlashMessageType.custom)
          {
            append(`
              <script type="text/javascript">
                window.addEventListener('load', function() {
                  var flashMessage = document.getElementById('%s');

                  if (flashMessage && flashMessage.parentNode) {
                    setTimeout(function() {
                      flashMessage.parentNode.removeChild(flashMessage);
                    }, %d);
                  }
                }, false);
              </script>
            `.format(identifier, displayTime));
          }
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
