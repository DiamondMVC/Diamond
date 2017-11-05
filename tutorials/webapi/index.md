[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Creating a website

An empty template for a Diamond webapi can be found [here](https://github.com/DiamondMVC/Diamond-Template-WebApi).

## Project Structure

Create a new folder for your project.
Ex. diamondproject

Create the following folders and files within it.
(Don't worry about content right now.)

* /diamondproject
    * /config
        * controllers.config
        * web.json
    * /controllers
        * package.d
        * homecontroller.d
    * /core
        * websettings.d
    * /models
        * package.d
    * dub.json

Below is all the content for the files.
Just copy-paste it into the files.
Explanations of them are right below.

## dub.json

```
{
    "name": "diamond-webapi-empty",
    "description": "Empty project template for a web-api",
    "authors": ["Jacob Jensen"],
    "homepage": "https://github.com/DiamondMVC/Diamond-Template-WebApi",
    "dependencies": {
        "vibe-d": "~>0.8.1",
        "diamond": "~>2.4.5",
        "mysql-native": "~>1.1.2"
    },
    "versions": ["VibeDefaultMain", "Diamond_Debug", "Diamond_WebApi"],
    "sourcePaths": ["core", "models", "controllers"],
    "stringImportPaths": ["views", "config"],
    "targetType": "executable"
}
```

*name* is the name of the project.

*description* is the description of the project.

*authors* are the authors of the project.

*homepage* is the homepage of the project.

*license* is the license of the project.

*dependencies* are the dependencies of the project. A webserver using Diamond has a dependency to vibe.d

*versions* are all versions to compile with. For a webserver you must compile with "WebServer"

*sourcePaths* are all paths that dub will look for code. By defualt Diamond only uses core, models and controllers.

*stringImportPaths* are all paths dub will look for string imports. By default Diamond only uses views and config.

*targetType* are the type of the output. For a Diamond project, it'll typically be executable.

## web.json

```
{
  "name": "Empty Diamond WebApi",
  "homeRoute": "home",
  "allowFileRoute": false,
  "accessLogToConsole": false,
  "addresses": [{
    "ipAddresses": ["::1", "127.0.0.1"],
    "port": 8181
  }, {
    "ipAddresses": ["::1", "127.0.0.1"],
    "port": 8080
  }],
  "defaultHeaders": {
    "general": {
      "Content-Type": "text/html; charset=UTF-8",
      "Server": "vibe.d - Diamond MVC/Template Framework"
    },
    "staticFiles": {
      "Server": "vibe.d - Diamond MVC/Template Framework"
    },
    "notFound": {
      "Content-Type": "text/html; charset=UTF-8",
      "Server": "vibe.d - Diamond MVC/Template Framework"
    },
    "error": {
      "Content-Type": "text/html; charset=UTF-8",
      "Server": "vibe.d - Diamond MVC/Template Framework"
    }
  }
}
```

*name* is the name of the project.

*homeRoute* is the default route for `/`

*allowFileRoute* is a boolean determining if views can be routed by their file name.

*accessLogToConsole* is a boolean determining if logging should be redirected to the console.

*addresses* are the addresses the server should be bound to.

*defaultHeaders* are the default headers to use.
  * *general* contains the default headers for regular responses.
  * *stticFiles* contains the default headers for static files.
  * *notFound* contains the default headers for actions not found.
  * *error* contains the default headers for errors.
  
## config/controllers.config

```
Home
```

Controllers should be separated per line with the following format:

```
{name without "Controller"}
```

## controllers\package.d

```
module controllers;

public
{
  import controllers.homecontroller;
}
```

You must import all controller modules within this file. Otherwise Diamond will be unable to locate your controllers.

## controllers\homecontroller.d

```
module controllers.homecontroller;

import diamond.controllers;

/// The home controller.
final class HomeController : Controller
{
  public:
  final:
  /**
  * Creates a new instance of the home controller.
  * Params:
  *   client =  The client passed to the controller.
  */
  this(HttpClient client)
  {
    super(client);
  }

  /// Route: / | /home
  @HttpDefault Status home()
  {
    return jsonString(`{
      "message": "Hello Diamond!"
    }`);
  }
}
```

All controller methods must return "Status" which indicates the status of the call.

Controllers are automatically instantiated internally by Diamond.

## core/websettings.d

```
module websettings;

import diamond.core.websettings;

class DiamondWebSettings : WebSettings
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerErrorInfo;

  import diamond.http;

  private:
  this()
  {
    super();
  }

  public:
  override void onApplicationStart()
  {
  }

  override bool onBeforeRequest(HttpClient client)
  {
    return true;
  }

  override void onAfterRequest(HttpClient client)
  {

  }

  override void onHttpError(Throwable thrownError, HTTPServerRequest request,
    HTTPServerResponse response, HTTPServerErrorInfo error)
  {
    response.bodyWriter.write(thrownError.toString());
  }

  override void onNotFound(HTTPServerRequest request, HTTPServerResponse response)
  {
    import std.string : format;

    response.bodyWriter.write(format("The path '%s' wasn't found.'", request.path));
  }

  override void onStaticFile(HttpClient client)
  {

  }
}

void initializeWebSettings()
{
  webSettings = new DiamondWebSettings;
}
```

*onBeforeRequest* can be used to handle requests before they have been processed.

*onAferRequest* can be used to handle requests after they have been processed successfully.

*onHttpError* can be used to handle requests that caused an error.

*onNotFound* can be used to handle requests given a path that weren't found.

*onStaticFile* can be used to handle static file requests before they've been processed.

## models/package.d

```
module models;

public
{
    // TODO: Import models here ...
}
```

Just like controllers, you must declare all models in this file. Otherwise Diamond won't be able to locate the models. This only counts for models that views use.

## Building

To compile the project simply use the following dub command

```
    dub build
```

For more information about controllers view: https://diamondmvc.github.io/Diamond/docs/reference/controllers/
