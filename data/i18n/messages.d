/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.i18n.messages;

import diamond.core.apptype;

static if (isWeb)
{

  import diamond.http;

  /// Alias for an associative array.
  private alias Language = string[string];

  /// A collection of localization messages.
  private __gshared Language[string] _messages;

  /// The default language.
  private __gshared string _defaultLanguage;

  /**
  * Sets the default language of the application.
  * Params:
  *   language = The language.
  */
  void setDefaultLanguage(string language)
  {
    _defaultLanguage = language;
  }

  /**
  * Gets a message.
  * Params:
  *   clent = The client to use the language of.
  *   key =   The key of the message to retrieve.
  * Returns:
  *   The message if found for the client's language, otherwise it will attempt to get the default language's message and if that fails too then it returns an empty string.
  */
  string getMessage(HttpClient client, string key)
  {
    return getMessage(client.language, key);
  }

  /**
  * Gets a message.
  * Params:
  *   languageName = The language to retrieve a message from.
  *   key =          The key of the message to retrieve.
  * Returns:
  *   The message if found for the specified language, otherwise it will attempt to get the default language's message and if that fails too then it returns an empty string.
  */
  string getMessage(string languageName, string key)
  {
    auto language = _messages.get(languageName, null);

    if (!language)
    {
      language = _messages.get(_defaultLanguage, null);
    }

    if (!language)
    {
      return "";
    }

    return language.get(key, "");
  }

  /**
  * Adds a message to a specific language.
  * Params:
  *   language = The language to add the message to.
  *   key =      The key of the message.
  *   message =  The message to add.
  */
  package(diamond) void addMessage(string language, string key, string message)
  {
    _messages[language][key] = message;
  }
}
