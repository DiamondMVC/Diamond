/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.io;

import stdio = std.stdio : writeln, writefln, readln;

/// Mixin template to handle files at compile-time.
mixin template handleCTFEFile(string fileName, string fileHandler)
{
  /// Function that must be called to handle the file.
  void handle()
  {
    static if (__traits(compiles, { auto s = import(fileName); }))
    {
      mixin("{
        enum __fileResult = import(fileName);
        " ~ fileHandler ~
      "}");
    }
  }
}

/**
* Prints a message to the standard output.
* Params:
*   msg = The message to print.
*/
void print(string msg)
{
  stdio.writeln(msg);
}

/**
* Prints a formatted message to the standard output.
* Params:
*   msg = The message to print.
*   args = The arguments to print.
*/
void print(Args...)(string msg, Args args)
{
  stdio.writefln(msg, args);
}

/**
* Prints data to the standard output.
* Params:
*   data = The data to print.
*/
void print(T)(T data)
{
  print("Data: %s", data);
}

void wait()
{
  readInput();
}

auto readInput()
{
  return stdio.readln();
}
