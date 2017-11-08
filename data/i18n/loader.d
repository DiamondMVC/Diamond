/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.i18n.loader;

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
  import std.string : strip, indexOf;
  import std.algorithm : map;

  import diamond.errors.checks;
  import diamond.data.i18n.messages;

  enforce(exists(languageFile), "Cannot find language file.");

  auto lines = readText(languageFile).replace("\r", "").split("\n");

  bool multiLine;
  string key = "";
  string message = "";

  foreach (line; lines.map!(l => l.strip()))
  {
    if (!line.length)
    {
      continue;
    }

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
        message ~= line ~ "\r\n";
        continue;
      }
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

    key = line[0 .. keyEndIndex].strip();
    message = line[keyEndIndex + 1 .. $].strip();

    addMessage(languageName, key, message);
  }
}
