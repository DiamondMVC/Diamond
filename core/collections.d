/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.collections;

/// A simple hash set implementation using the build-in AA.
final class HashSet(T)
{
  private:
  /// The build-in AA.
  ubyte[T] _set;

  public:
  final:
  /// Creates a new hash set.
  this() { }

  /**
  * Creates a new hash set from a sequence of elements.
  */
  this(T[] elements)
  {
    if (elements && elements.length)
    {
      foreach (element; elements)
      {
        _set[element] = 0;
      }
    }
  }

  /**
  * Adds a value to the hash set.
  * Params:
  *   value = The value added to the hash set.
  */
  void add(T value)
  {
    _set[value] = 0;
  }

  /**
  * Checks whether the hash set contains the given value.
  * Params:
  *   value = The value to check for existence within the set.
  * Returns:
  *   True if the set contains the given value.
  */
  bool has(T value)
  {
    if (!_set)
    {
      return false;
    }

    if (value in _set)
    {
      return true;
    }

    return false;
  }

  /**
  * Operator overload for accessing the set like an array.
  * This calls "bool has(T value);"
  */
  bool opIndex(T value)
  {
    return has(value);
  }
}
