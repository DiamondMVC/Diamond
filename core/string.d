/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.string;

import std.traits : isSomeString;

/**
* Converts the first character of a string to lowercase.
* Params:
*   s = The string to lowercase the first character.
* Returns:
*   Returns a new string with the first character lowercased. The string is returned unmodified if its null or empty.
*/
TString firstToLower(TString)(TString s)
if (isSomeString!TString)
{
  import std.string : toLower;
  import std.conv : to;

  if (!s || !s.length)
  {
    return s;
  }

  if (s.length == 1)
  {
    return s.toLower();
  }

  return to!string(s[0]).toLower() ~ s[1 .. $];
}

/**
* Converts the first character of a string to uppercase.
* Params:
*   s = The string to uppercase the first character.
* Returns:
*   Returns a new string with the first character uppercased. The string is returned unmodified if its null or empty.
*/
TString firstToUpper(TString)(TString s)
if (isSomeString!TString)
{
  import std.string : toUpper;
  import std.conv : to;

  if (!s || !s.length)
  {
    return s;
  }

  if (s.length == 1)
  {
    return s.toUpper();
  }

  return to!string(s[0]).toUpper() ~ s[1 .. $];
}

/**
* Splits a string input into grouped words.
* Params:
*   input = The input to split into grouped words.
* Returns:
*   The string split into grouped words.
*/
string[] splitIntoGroupedWords(string input)
{
  import std.array : split;

  auto inputs = input.split(" ");
  string[] words = [];

  foreach (i; 0 .. inputs.length)
  {
    string current = inputs[i];
    string next1 = i < (inputs.length - 1) ? (" " ~ inputs[i + 1]) : null;
    string next2 = i < (inputs.length - 2) ? (" " ~ inputs[i + 2]) : null;

    words ~= current;

    if (next1)
    {
      words ~= current ~ next1;
    }

    if (next2)
    {
      words ~= current ~ next1 ~ next2;
    }
  }

  return words;
}
