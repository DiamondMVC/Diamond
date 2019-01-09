/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.i18n.loader;

import diamond.core.apptype;

static if (isWeb)
{
  /**
  * Loads a language file for i18n use.
  * The format of the file must be like shown in the example:
  * Examples:
  * --------------------
  * MESSAGE_KEY=SINGLE-LINE MESSAGE
  *
  * ...
  *
  * MESSAGE_KEY:
  * MULTI-LINE
  * MESSAGE
  * ;
  * --------------------
  * Params:
  *   languageName = The name of the language.
  *   languageFile = The file for the localization content.
  */
  void loadLanguageFile(string languageName, string languageFile)
  {
    import std.file : exists, readText;
    import std.array : replace, split;
    import std.string : strip, stripLeft, stripRight, indexOf;
    import std.algorithm : map;

    import diamond.errors.checks;
    import diamond.data.i18n.messages;

    enforce(exists(languageFile), "Cannot find language file.");

    auto lines = readText(languageFile).replace("\r", "").split("\n");

    bool multiLine;
    string key = "";
    string message = "";

    foreach (line; lines.map!(l => l.stripRight()))
    {
      if (multiLine)
      {
        if (line == ";" && message[$-1] != 0x5c/*0x5c = '\'*/)
        {
          multiLine = false;
          addMessage(languageName, key, message);
          continue;
        }
        else
        {
          message ~= (line.stripLeft().length ? line : "") ~ "\r\n";
          continue;
        }
      }

      if (!line.strip().length)
      {
        continue;
      }

      auto keyEndIndex = line.indexOf('=');

      if (keyEndIndex == -1 && line[$-1] == ':')
      {
        multiLine = true;
        key = line[0 .. $-1];
        message = "";
        continue;
      }

      enforce(keyEndIndex > 0, "Found no message key");
      enforce(keyEndIndex < line.length, "Found no message value.");

      key = line[0 .. keyEndIndex].stripLeft();
      message = line[keyEndIndex + 1 .. $].strip();

      addMessage(languageName, key, message);
    }
  }
}
