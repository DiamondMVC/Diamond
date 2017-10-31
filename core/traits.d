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
