/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.debugging;

import diamond.core.apptype;

static if (debugging)
{
  public import diamond.core.io;

  /// A stack logger wrapper.
  class StackLogger
  {
    private:
    /// The call stack of the logger.
    string[] _callStack;

    /// Creates a new stack logger.
    this() {}

    public:
    /// Gets the current callstack.
    @property const(string[]) callStack() { return _callStack; }

    /// Logs the current call.
    void log(in string file = __FILE__, in size_t line = __LINE__, in string mod = __MODULE__, in string func = __PRETTY_FUNCTION__)
    {
      import std.string : format;

      _callStack ~= format("file: '%s' line: '%s' module: '%s' function: '%s'", file, line, mod, func);
    }

    /// Clears the call stack.
    void clear()
    {
      _callStack = null;
    }

    /// Prints the call stack.
    void printCallStack()
    {
      print(_callStack);
    }
  }

  /// The thread-local stack logger.
  private StackLogger _stackLogger;

  /// Gets the stack logger for the current thread.
  @property StackLogger stackLogger()
  {
    if (_stackLogger)
    {
      return _stackLogger;
    }

    _stackLogger = new StackLogger;

    return _stackLogger;
  }
}
