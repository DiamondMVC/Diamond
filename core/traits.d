/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.traits;

/// Creates a string to use with mixin that is an exact copy members of an enum
string createEnumAlias(T)(string name)
{
  import std.traits : EnumMembers, OriginalType;
  import std.conv : to;
  import std.string : format;
  import std.array : array, join;
  import std.algorithm : map;
  import std.meta : NoDuplicates;

  return format("enum %s : %s { ", name, (OriginalType!T).stringof) ~ [NoDuplicates!(EnumMembers!T)]
    .map!
    (
      (member)
      {
        return format("%s = %s", to!string(member), cast(OriginalType!T)member);
      }
    )
    .array.join(",") ~ " }";
}

/// Mixin template to handle fields of a type.
mixin template HandleFields(T, string handler)
{
  string handleThem()
  {
    mixin HandleField!(T, [FieldNameTuple!T], handler);

    return handle();
  }
}

/// Mixin template to handle a specific field of a fieldname collection.
mixin template HandleField
(
  T,
  string[] fieldNames,
  string handler
)
{
  import std.array : replace;

  string handle()
  {
    string s = "";

    foreach (fieldName; fieldNames)
    {
      s ~= "{" ~
        handler
          .replace("{{fieldName}}", fieldName)
          .replace("{{fullName}}", T.stringof ~ "." ~ fieldName)
        ~ "}";
    }

    return s;
  }
}
