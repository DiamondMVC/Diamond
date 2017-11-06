/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.unittesting.initialization;

import diamond.core.apptype;

static if (isWeb && isTesting)
{
  /// Boolean determinng whether all tests has passed or not.
  package(diamond) __gshared bool testsPassed;

  /// Wrapper around a test's failure result.
  private class TestFailResult
  {
    /// The name of the test.
    string name;
    /// The error.
    string error;
  }

  /// Initializes the tests.
  package(diamond) void initializeTests()
  {
    TestFailResult[] failedTests;

    mixin HandleTests;
    handleTests();

    import diamond.core.io;

    if (failedTests && failedTests.length)
    {
      import vibe.core.core : exitEventLoop;

      exitEventLoop();

      print("The following tests has failed:");

      foreach (test; failedTests)
      {
        print("-------------------");
        print("Test: %s", test.name);
        print("Error:");
        print(test.error);
        print("-------------------");
      }
    }
    else
    {
      testsPassed = true;
      print("All tests has passed.");
    }
  }

  /// Mixin template to handle the tests.
  private mixin template HandleTests()
  {
    static string[] getModules()
    {
      import std.string : strip;
      import std.array : replace, split;

      string[] modules = [];

      import diamond.core.io : handleCTFEFile;

      mixin handleCTFEFile!("unittests.config", q{
        auto lines = __fileResult.replace("\r", "").split("\n");

        foreach (line; lines)
        {
          if (!line || !line.strip().length)
          {
            continue;
          }

          modules ~= line.strip();
        }
      });
      handle();

      return modules;
    }

    enum moduleNames = getModules();

    static string generateTests()
    {
      string s = "";

      foreach (moduleName; moduleNames)
      {
        s ~= "{ import " ~ moduleName ~ ";\r\n";
        s ~= "foreach (member; __traits(allMembers, " ~ moduleName ~ "))\r\n";

        s ~= q{
        	{
        		mixin(q{
              static if (mixin("hasUDA!(%1$s, HttpTest)"))
              {
                static test_%1$s = getUDAs!(%1$s, HttpTest)[0];

                auto testName =
                  test_%1$s.name && test_%1$s.name.length ? test_%1$s.name : "%1$s";

                try
                {
                  static if (is(ReturnType!%1$s == bool))
                  {
                    if (!%1$s())
                    {
                      auto testFailResult = new TestFailResult;
                      testFailResult.name = testName;
                      testFailResult.error = "Returned false.";

                      failedTests ~= testFailResult;
                    }
                  }
                  else
                  {
                    %1$s();
                  }
                }
                catch (Throwable t)
                {
                  auto testFailResult = new TestFailResult;
                  testFailResult.name = testName;
                  testFailResult.error = t.toString();

                  failedTests ~= testFailResult;
                }
              }
            }.format(member));
        	}
        };

        s ~= "}\r\n";
      }

      return s;
    }

    void handleTests()
    {
      import std.string : format;
      import std.traits : hasUDA, getUDAs, ReturnType;
      import diamond.core.collections;
      import diamond.unittesting.attributes;

      mixin(generateTests());
    }
  }
}
