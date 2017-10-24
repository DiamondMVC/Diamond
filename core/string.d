module diamond.core.string;

import std.traits : isSomeString;

TString firstToLower(TString)(TString s)
if (isSomeString!TString)
{
  import std.string : toLower;
  import std.conv : to;

  if (!s)
  {
    return s;
  }

  if (s.length == 1)
  {
    return s.toLower();
  }

  return to!string(s[0]).toLower() ~ s[1 .. $];
}
