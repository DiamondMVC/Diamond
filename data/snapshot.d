/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.snapshot;

import std.traits : isScalarType;

/// Wrapper for a snapshot type, which is a type that keeps track of a type's value history.
final class Snapshot(T)
if (is(T == struct) || isScalarType!T)
{
	private:
  /// The values.
	T[] _values;
  /// The current value.
	T _current;

	public:
	final:
  /// Creates a new snapshot of a type.
	this() { }

  /**
  * Creates a new snapshot of a type.
  * Params:
  *   initValue = The initializationValue
  */
	this(T initValue)
	{
		value = initValue;
	}

	@property
	{
    /// Sets the value.
		void value(T newValue)
		{
			_values ~= newValue;
			_current = newValue;
		}

    /// Gets the value.
		T value()
		{
			if (!_values || !_values.length)
			{
				return T.init;
			}

			return _current;
		}
	}

  /// Rolls back to the previous value.
	void prev()
	{
		if (!_values || !_values.length)
		{
			return;
		}

		_values = _values[0 .. $-1];
		_current = _values[$-1];
	}

  /**
  * Rolls back a specific amount of states.
  * Params:
  *   states = The amount of states to roll back.
  */
	void prev(size_t states)
	{
		if (states >= _values.length)
		{
			_values = [];
			_current = T.init;
		}
		else
		{
			_values = _values[0 .. $-states];
			_current = _values[$-1];
		}
	}

  /// Resets the value to its first known value.
	void reset()
	{
		if (!_values || !_values.length)
		{
			return;
		}

		_values = [_values[0]];
	}

  /**
  * Operator overload for indexing to retrieve a specific historical snapshot of the type.
  * Params:
  *   index = The index to retrieve the snapshot of.
  * Returns:
  *   The value at the index if found, T.init otherwise.
  */
	T opIndex(size_t index)
	{
		if (index >= _values.length)
		{
			return T.init;
		}

		return _values[index];
	}

	static if (isScalarType!T)
	{
    /// Operator overload for comparing scalar types.
		int opCmp(T comparison)
		{
			if (_current < comparison)
			{
				return -1;
			}

			if (_current > comparison)
			{
				return 1;
			}

			return 0;
		}

    /// Operator overload for equality comparison between scalar types.
		bool opEquals(T comparison)
		{
			return opCmp(comparison) == 0;
		}
	}

  /// Alias this to set the value directly for the snapshot.
	alias value this;
}
