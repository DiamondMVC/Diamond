/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.html;

string escapeHtml(string html)
{
  import std.string : format;
  import std.conv : to;

  if (!html || !html.length)
  {
    return html;
  }

  string result = "";

  foreach (c; html)
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

      case '(':
      {
        result ~= "&#40;";
        break;
      }

      case ')':
      {
        result ~= "&#41;";
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

  return result;
}

string escapeJson(string json)
{
  import std.string : format;
  import std.conv : to;

  if (!json || !json.length)
  {
    return json;
  }

  string result = "";

  foreach (c; json)
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

      case '&':
      {
        result ~= "&amp;";
        break;
      }

      case '(':
      {
        result ~= "&#40;";
        break;
      }

      case ')':
      {
        result ~= "&#41;";
        break;
      }

      default:
      {
        result ~= to!string(c);
      }
    }
  }

  return result;
}
