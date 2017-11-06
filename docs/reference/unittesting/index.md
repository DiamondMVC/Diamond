[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Unittesting

Diamond has unittesting build-in from version 2.4.6, which allows you to define custom tests that can create internal requests to certain areas of your application.

To use the build-in unittests you must add the version "Diamond_UnitTesting" to your dub.json/dub.sdl.

Diamond's unittest suite does not depend on D's build-in unittests nor does it require *-unittest* to be enabled by the compiler. It's completely independant.

Tests won't run or compile if the version isn't specified.

When compiling with unittests, controllers and views will have a property called **testing** which returns a bool that can be used to determine whether the request is from a test or not.

Diamond does not accept external requests when all test's hasn't finished. Only local requests from **127.0.0.1** are accepted.

After all tests have passed Diamond will accept ordinary external requests.

If one or more tests fail, Diamond will give a response back to the standard output with which tests failed and why they failed.

Diamond will not continue to operate if one or more tests have failed.

After tests have been enabled with the "Diamond_UnitTesting" version then you must create a file in your config folder called **unittests.config**.

Each line of the file must represent a module that contains tests.

*Note: You cannot use packages, it must be modules. This is because Diamond uses __traits(allMembers, module) internally and it doesn't work well with packages.*

Example of a unittests.config:

```
unittests.test
```

With the above Diamond will expect a module named **unittests.test** to be present.

To create a module like that make a new folder in the root folder of your project called **unittests* and in your dub.json/dub.sdl you want to add a **sourcePath** to the folder **unittests**.

Within the folder create a file called **test.d** and make its module name **unittests.test**.

To create tests you must import **diamond.unittesting**.

It's recommended to encapsulate all tests with **static if (isTesting) { ... }**, otherwise you cannot compile without unittesting enabled.

```
module unittests.test;

import diamond.unittesting;

static if (isTesting)
{
    // TODO: Create tests here ...
}
```

To create a test you must create a function marked with the **@HttpTest** attribute.

The attribute can take a string for a name, otherwise the name of the test will be the function's name.

If a function has a return-type of bool, then returning false will indicate the test has failed.

A test fails if an exception or error is thrown, making Diamond's build-in unittesting compatible with **assert()**.

```
module unittests.test;

import diamond.unittesting;

static if (isTesting)
{
    @HttpTest("My first unittest") test()
    {
        assert(true);
    }
}
```

Running your application will output:

```
All tests have passed.
```

Tests are ideal to test whether specific inputs give correct outputs, generally with controller actions.

Let's say we have a controller action like below in our home controller:

```
@HttpAction(HttpGet, "/<>/{uint:id}") Status test()
{
  import std.string : format;
  
  auto id = get!uint("id");
    
  return jsonString(`{
    "message": "Hello World!",
    "success": %s
  }`.format(id == 100));
}
```

When creating a test for this actions we want to ensure that **success** of our json is true.

It's only true if the id passed to it is 100.

A model in our unittest to validate the json is required.

```
class JsonResponse
{
  string message;
  bool success;
}
```

To create internal requests for testing you must called **testRequest()**.

More information about the function can be found in the api docs. (Online version is not updated, but the offline version has been updated.)

### Testing that it works with the correct input

```
testRequest("/home/test/100", HttpMethod.GET, (scope result)
{
  assert(result.statusCode == HttpStatus.ok);

  auto foo = result.getModelFromJson!JsonResponse;

  assert(foo.success);
});
```

### Testing that it works with an incorrect input

```
testRequest("/home/test/500", HttpMethod.GET, (scope result)
{
  assert(result.statusCode == HttpStatus.ok);

  auto foo = result.getModelFromJson!JsonResponse;

  assert(!foo.success);
});
```

The result for the **testRequest()** function is **diamond.unittesting.request.HttpUnitTestResult**.

Full unittest:

```
module unittests.test;

import diamond.unittesting;

static if (isTesting)
{
  class JsonResponse
  {
    string message;
    bool success;
  }

  @HttpTest("My first unittest") test()
  {
    testRequest("/home/test/100", HttpMethod.GET, (scope result)
    {
      assert(result.statusCode == HttpStatus.ok);

      auto foo = result.getModelFromJson!JsonResponse;

      assert(foo.success);
    });

    testRequest("/home/test/500", HttpMethod.GET, (scope result)
    {
      assert(result.statusCode == HttpStatus.ok);

      auto foo = result.getModelFromJson!JsonResponse;

      assert(!foo.success);
    });
  }
}
```
