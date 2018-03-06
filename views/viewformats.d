/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewformats;

import diamond.core.apptype;

static if (!isWebApi)
{
  static if (isWebServer)
  {
    /// The format for view classes when using web-servers.
    enum viewClassFormat = q{
      final class view_%s : View
      {
        import std.array : replace, split, array;
        import std.algorithm : map, filter, countUntil, count, canFind;
        import std.string : strip, indexOf, lastIndexOf, isNumeric;
        import std.datetime : Date, DateTime, SysTime, Clock, Month, DayOfWeek;
        import std.conv : to;

        import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPMethod;

        import diamond.http;
        import diamond.errors.exceptions;
        import diamond.controllers;
        import i18n = diamond.data.i18n;

        import controllers;
        import models;

        public:
        final:
        // viewClassMembers
        %s

        this(HttpClient client, string name)
        {
          super(client, name);

          // viewConstructor
          %s
        }

        // modelGenerate
        %s

        override string generate(string sectionName = "")
        {
          try
          {
            // controller
            %s

            // placeHolders
            %s

            switch (sectionName)
            {
              // view code
              %s
            }

            // end
            %s
          }
          catch (Exception e)
          {
            throw new ViewException(super.name, e);
          }
          catch (Throwable t)
          {
            throw new ViewError(super.name, t);
          }
        }
      }
    };

    /// The format for controller handlers.
    enum controllerHandleFormat = q{
      if (!super.rawGenerate)
      {
        auto controllerResult = controller.handle();

        if (controllerResult == Status.notFound)
        {
          client.notFound();
        }
        else if (controllerResult == Status.unauthorized)
        {
          client.unauthorized();
        }
        else if (controllerResult == Status.end)
        {
          return null;
        }
      }
    };

    /// The format for the controller member.
    enum controllerMemberFormat = "%s!%s controller;\r\n";

    /// The format for controller constructors.
    enum controllerConstructorFormat = "controller = new %s!%s(this);\r\n";

  }
  else
  {
    /// The format for view classes when using stand-alone.
    enum viewClassFormat = q{
      final class view_%s : View
      {
        import std.array : replace, split, array;
        import std.algorithm : filter, countUntil, count, canFind;
        import std.string : strip, indexOf, lastIndexOf, isNumeric;
        import std.datetime : Date, DateTime, SysTime, Clock, Month, DayOfWeek;
        import std.conv : to;

        import diamond.errors.exceptions;

        import models;

        public:
        final:
        // viewClassMembers
        %s

        this(string name)
        {
          super(name);

          // viewConstructor
          %s
        }

        // modelGenerate
        %s

        override string generate(string sectionName = "")
        {
          try
          {
            // placeHolders
            %s

            switch (sectionName)
            {
              // view code
              %s
            }

            // end
            %s
          }
          catch (Exception e)
          {
            throw new ViewException(super.name, e);
          }
          catch (Throwable t)
          {
            throw new ViewError(super.name, t);
          }
        }
      }
    };
  }

  /// The format for generating the view using a model.
  enum modelGenerateFormat = q{
    string generateModel(%s newModel, string sectionName = "")
    {
      model = newModel;

      return generate(sectionName);
    }
  };

  /// The format for the model member.
  enum modelMemberFormat = "%s model;\r\n";

  enum updateModelFromRenderViewFormat = q{
    protected override void copyViewData()
    {
      auto rView = cast(view_%s)renderView;

      if (rView)
      {
        this.model = rView.model;
      }

      super.copyViewData();
    }
  };

  /// The format for ending a view generate call.
  enum endFormat = q{
    if (sectionName && sectionName.length)
    {
      return generate(null);
    }
    else
    {
      return super.prepare();
    }
  };

  /// The format for place holders.
  enum placeHolderFormat = q{
    foreach (key,value; %s)
    {
      super.addPlaceHolder(key,value);
    }
  };

  /// The format for appended arguments.
  enum appendFormat = "append(%s);\r\n";

  /// The format for escaped arguments.
  enum escapedFormat = "escape(%s);\r\n";

  /// The format used for layout's in the constructor.
  enum layoutConstructorFormat = "super.layoutName = \"%s\";\r\n";
}
