/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.views.viewparser;

import diamond.core.apptype;

static if (!isWebApi)
{
  import diamond.views.viewformats;
  import diamond.templates;

  import std.string : strip, format;
  import std.array : replace, split;
  import std.conv : to;

  /**
  * Parses the view parts into a view class.
  * Params:
  *   allParts = All the parsed parts of the view template.
  *   viewName = The name of the view.
  *   route =    The route of the view. (This is null if no route is specified or if using stand-alone)
  * Returns:
  *   A string equivalent to the generated view class.
  */
  string parseViewParts(Part[][string] allParts, string viewName, out string route)
  {
    route = null;

    string viewClassMembersGeneration = "";
    string viewConstructorGeneration = "";
    string viewModelGenerateGeneration = "";
    string viewCodeGeneration = "";
    string viewPlaceholderGeneration = "";
    bool hasController;
    bool useBaseView;
    bool hasDefaultSection;

    foreach (sectionName,parts; allParts)
    {
      if (sectionName && sectionName.length)
      {
        viewCodeGeneration ~= "case \"" ~ sectionName ~ "\":
        {
  ";
      }
      else
      {
        hasDefaultSection = true;
        viewCodeGeneration ~= "default:
        {
";
      }

      foreach (part; parts)
      {
        if (!part.content || !part.content.strip().length)
        {
          continue;
        }

        import diamond.extensions;
        mixin ExtensionEmit!(ExtensionType.partParser, q{
          {{extensionEntry}}.parsePart(
            part,
            viewName,
            viewClassMembersGeneration, viewConstructorGeneration,
            viewModelGenerateGeneration,
            viewCodeGeneration
          );
        });
        emitExtension();

        switch (part.contentMode)
        {
          case ContentMode.appendContent:
          {
            viewCodeGeneration ~= parseAppendContent(part);
            break;
          }

          case ContentMode.appendContentPlaceholder:
          {
            if (part.content[0] == '%' && part.content[$-1] == '%')
            {
              viewCodeGeneration ~= parseAppendTranslateContent(part);
            }
            else if (part.content[0] == '#' && part.content[$-1] == '#')
            {
              viewCodeGeneration ~= parseAppendPartialViewContent(part);
            }
            else
            {
              viewCodeGeneration ~= parseAppendPlaceholderContent(part);
            }
            break;
          }

          case ContentMode.mixinContent:
          {
            viewCodeGeneration ~= part.content;
            break;
          }

          case ContentMode.metaContent:
          {
            parseMetaContent(
              part,
              viewName,
              viewClassMembersGeneration, viewConstructorGeneration,
              viewModelGenerateGeneration, viewPlaceholderGeneration,
              useBaseView,
              hasController,
              route
            );
            break;
          }

          default : break;
        }
      }

      viewCodeGeneration ~= "break;
}
";
    }

    if (!hasDefaultSection) {
      viewCodeGeneration ~= "default: break;";
    }

    static if (isWebServer)
    {
      return viewClassFormat.format(
        viewName,
        viewClassMembersGeneration,
        viewConstructorGeneration,
        viewModelGenerateGeneration,
        hasController ? controllerHandleFormat : "",
        viewPlaceholderGeneration,
        viewCodeGeneration,
        endFormat
      );
    }
    else
    {
      return viewClassFormat.format(
        viewName,
        viewClassMembersGeneration,
        viewConstructorGeneration,
        viewModelGenerateGeneration,
        viewPlaceholderGeneration,
        viewCodeGeneration,
        endFormat
      );
    }
  }

  private:
  /**
  * Parses content that can be appended as a place holder.
  * Params:
  *   part = The part to parse.
  * Returns:
  *   The appended result.
  */
  string parseAppendPlaceholderContent(Part part)
  {
    return appendFormat.format("getPlaceholder(`" ~ part.content ~ "`)");
  }

  /**
  * Parses content that can be appended as i18n.
  * Params:
  *   part = The part to parse.
  * Returns:
  *   The appended result.
  */
  string parseAppendTranslateContent(Part part)
  {
    return appendFormat.format("i18n.getMessage(super.client, \"" ~ part.content[1 .. $-1] ~ "\")");
  }

  /**
  * Parses content that can be appended as partial view.
  * Params:
  *   part = The part to parse.
  * Returns:
  *   The appended result.
  */
  string parseAppendPartialViewContent(Part part)
  {
    auto viewData = part.content[1 .. $-1].split(",");

    if (viewData.length == 2)
    {
      return appendFormat.format("retrieveModel!\"%s\"(%s)".format(viewData[0], viewData[1]));
    }
    else
    {
      return appendFormat.format("retrieve(\"%s\")".format(viewData[0]));
    }
  }

  /**
  * Parses content that can be appended.
  * Params:
  *   part = The part to parse.
  * Returns:
  *   The appended result.
  */
  string parseAppendContent(Part part)
  {
    switch (part.name)
    {
      case "expressionValue":
      {
        return appendFormat.format(part.content);
      }

      case "escapedValue":
      {
        return escapedFormat.format("`" ~ part.content ~ "`");
      }

      case "expressionEscaped":
      {
        return escapedFormat.format(part.content);
      }

      default:
      {
        return appendFormat.format("`" ~ part.content ~ "`");
      }
    }
  }

  /**
  * Parses the meta content of a view.
  * Params:
  *   part =                        The part of the meta content.
  *   viewClassMembersGeneration =  The resulting string of the view's class members.
  *   viewConstructorGeneration =   The resulting string of the view's constructor.
  *   viewModelGenerateGeneration = The resulting string of the view's model-generate function.
  *   viewPlaceHolderGeneration =   The resulting string of the view's placeholder generation.
  *   useBaseView =                 Boolean determining whether the view should use the base view for controllers.
  *   hasController =               Boolean determining whether the view has a controller or not.
  *   route =                       The name of the view's route. (null if no route or if stand-alone.)
  */
  void parseMetaContent(Part part,
    string viewName,
    ref string viewClassMembersGeneration,
    ref string viewConstructorGeneration,
    ref string viewModelGenerateGeneration,
    ref string viewPlaceholderGeneration,
    ref bool useBaseView,
    ref bool hasController,
    ref string route)
  {
    string[string] metaData;
    auto metaContent = part.content.replace("\r", "").split("---");

    foreach (entry; metaContent)
    {
      if (entry && entry.length)
      {
        import std.string : indexOf;

        auto keyIndex = entry.indexOf(':');
        auto key = entry[0 .. keyIndex].strip().replace("\n", "");

        metaData[key] = entry[keyIndex + 1 .. $].strip();
      }
    }

    foreach (key, value; metaData)
    {
      if (!value || !value.length)
      {
        continue;
      }

      switch (key)
      {
        case "placeHolders": // TODO: Remove in 2.9.0
        case "placeholders":
        {
          viewPlaceholderGeneration = placeholderFormat.format(value);
          break;
        }

        case "route":
        {
          import std.string : toLower;
          route = value.replace("\n", "").toLower();
          break;
        }

        case "model":
        {
          viewModelGenerateGeneration = modelGenerateFormat.format(value);
          viewClassMembersGeneration ~= modelMemberFormat.format(value);
          viewClassMembersGeneration ~= updateModelFromRenderViewFormat.format(viewName);
          break;
        }

        static if (isWebServer)
        {
          case "controllerUseBaseView":
          {
            useBaseView = to!bool(value);
            break;
          }

          case "controller":
          {
            hasController = true;
            viewClassMembersGeneration ~= controllerMemberFormat.format(value, useBaseView ? "View" : "view_" ~ viewName);
            viewConstructorGeneration ~= controllerConstructorFormat.format(value, useBaseView ? "View" : "view_" ~ viewName);
            break;
          }
        }

        case "layout":
        {
          viewConstructorGeneration ~= layoutConstructorFormat.format(value.replace("\n", ""));
          break;
        }

        case "cache":
        {
          if (to!bool(value))
          {
            viewConstructorGeneration ~= "super.cached = true;\r\n";
          }

          break;
        }

        case "contentType":
        {
          viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"%s\";".format(value.replace("\n", ""));
          break;
        }

        case "type":
        {
          switch (value.replace("\n", ""))
          {
            case "text":
            {
              viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"text/plain; charset=UTF-8\";";
              break;
            }

            case "xml":
            {
              viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"application/xml; charset=UTF-8\";";
              break;
            }

            case "rss":
            {
              viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"application/rss+xml; charset=UTF-8\";";
              break;
            }

            case "atom":
            {
              viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"application/atom+xml; charset=UTF-8\";";
              break;
            }

            case "json":
            {
              viewConstructorGeneration ~= "super.client.rawResponse.headers[\"Content-Type\"] = \"application/json; charset=UTF-8\";";
              break;
            }

            default: break;
          }
          break;
        }

        default: break;
      }
    }
  }
}
