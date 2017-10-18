# Diamond

Diamond is a MVC / Template Framework written in the D Programming Language. It's inspired by ASP.NET's Razor syntax; however it still differs from it and has its own set of rules. Diamonds was originally written to be an alternative template version of Vibe.d's Diet templates, however it has evolved far beyond that.

## Features - Web

* Full control over requests / responses when wanted.
* "Websettings" file that lets you control requests / responses for:
  * Before a request is handled.
  * After a request has been handled.
  * When an error occurres.
  * When a page or controller action wasn't found.
  * When a static file has been requested.
* Multiple static file paths
* Let's you bind to multiple ip addresses and ports.
* Let's you control default headers for each type of request (default, static files, errors, not found etc.)
* Uses vibe.d for backend, so it's very powerful and all vibe.d features can be used with Diamond
* Easy control over the application's type using *static if* constructs.
  * isWeb (true for both web-servers and web-apis.)
  * isWebServer (true for web-servers)
  * isWebApi (true for web-apis)
  * isWeb, isWebServer and isWebApi will be false for standalone.

### Views (WebServer)

* Views are parsed at compile-time, thus rendering of views are super fast
* Views can have layout views
* Views have a metadata section that lets you change view configurations such as its controller, model, layout, route and placeholders.
* Views have placeholders and layout view's can access the render view's placeholders.
* Views can encode their data
* Has a rich syntax that allows for complex and innovative rendering.
* Easy access to the current request / response using the properties: *httpRequest* and *httpResponse*
* Can render other views within itself
* Any type of D code can be written within views.

### Models

* Models can be of any datatype (classes, structs, enums, scalar etc.)
* Models are optional
* Models can be passed around in view rendering
* "Models" can easily be converted to json from controllers

### Controllers

* Controller actions are mapped through attributes. (By default the route name will be the name of the function.)
  * If wanted actions can be mapped manually, but that's a legacy feature.
* Controller actions can easily control how the response is handled, as they require a status returned
  * Status.success (Will continue to handle the request.)
  * Status.end (Will end the request; useful for json responses etc. *Note: using the json() function already does it for you.)*
  * Status.notFound (Will issue a 404 status for the response.)
* Can map mandatory actions that are executed on every requests. (Useful for authentication etc.)

### Controllers (WebServer)

* Can access the view directly by the *view* property.
  * *Note: To access requests, response etc. you must go through the view.*
* Can easily return json data either by returning models that are serialized as json or by composing json strings.
* Can easily redirect by calling redirectTo()

### Controllers (WebApi)

* Can access the request, response etc. directly.

## Features - Standalone

### Views

* Views are parsed at compile-time, thus rendering of views are super fast
* Views can have layout views
* Views have a metadata section that lets you change view configurations such as its model, layout and placeholders.
* Views have placeholders and layout view's can access the render view's placeholders.
* Views can encode their data
* Has a rich syntax that allows for complex and innovative rendering.
* Can render other views within itself
* Any type of D code can be written within views.
* Can be used for any type of template rendering such as email, UI etc.

### Models

* Models can be of any datatype (classes, structs, enums, scalar etc.)
* Models are optional
* Models can be passed around in view rendering

## FAQ

### What is Diamond?

Diamond is a MVC / Template library written in Diamond. It was written originally as an alternative to the Diet templates in vibe.d, but now its functonality and capabilities are far beyond templating only.

### What does Diamond depend on?

Diamond can be used stand-alone without depending on any third-party libraries, other than the standard library Phobos. It has 3 types of usage, websites and webservices, where it's used on-top of vibe.d and as a stand-alone mvc/template library.

### What is the dependency to Vibe.d?

Diamond was originally written to be used in a hobby project as an alternative syntax to the "standard" diet templates. Thus it was originally build on-top vibe.d as a pure website template. It has now evolved to be able to run stand-alone however.

### What syntax does Diamond use?

Diamond is heavily inspired by the ASP.NET Razor syntax, but still differs a lot from it. You can read more about that in the wiki under Syntax Reference or the comparison with ASP.NET Razor

### What advantage does Diamond have over Diet?

It let's you control the markup entirely, can be integrated with any-type of D code, not limited to vibe.d and can be used as standard template library for any type of project such as email templates etc. It also allows for special rendering, easy controller implementations and management of request data, response etc.

Another advantage is that Diamond is very light-weight when used standa-lone; where Diet depends on vibe.d and to use it you must have the whole library referenced.

### Does Diamond parse on every request like ex. PHP?

No. Views are parsed once during compile-time and then compiled into D code that gets executed on run-time; keeping view generation to a minimum, while performance and speed is kept high. The downside of this is that on every changes in code you'll need to recompile. However it's recommended to setup an environment that checks for changes and then simply recompiles when changes are found. On Windows this can be done with https://msdn.microsoft.com/en-us/library/aa365465(VS.85).aspx or if you don't mind .NET you can use https://msdn.microsoft.com/en-us/library/system.io.filesystemwatcher(v=vs.110).aspx (Not sure about *nix systems as I have very little experience with those.)

In the future (At least for Windows as a starter) an application will be developed that can be used to automate build-processing etc. 

View the repository *Cryztal* for more information.

### What are some main features of Diamond?

Please view the feature section above.

### Is it easy to use Diamond?

Diamond has been made in a way that it's very easy to use and integrate into projects. It also takes care of all background setup for vibe.d projects, letting you focus on just writing your websites / webservices logic, rather than a huge hassle of setup.

### Are there any syntax guide-lines?

The wiki has two syntax guide-lines one for the specific syntax of Diamond and one that compares it with ASP.NET Razor.

## Installing (Web)

Diamond supports dub and compiles as a source library.

* First get a D compiler here: https://dlang.org/download.html
* Then download and install DUB: http://code.dlang.org/download
* After that download this empty Diamond project: *insert link here*
* Invoke *dub build* on the root folder of the project (The folder with dub.json)
* It should build the project and create an executable that you can run
* Run the executable and access it in the browser with *http://127.0.0.1:8080/*
* If *Hello World!* is shown then it worked fine.
* First time you build it can take a while
* After you have tested Diamond was installed successully and runs fine then you can start modifying the project and begin your own using it as a template.

## Installing (Standalone)

Using Diamond stand-alone is a little more tricky than using it for web as there are no specific guide-lines in how to use it.

It's not adviced to use Diamond as stand-alone until you have a basic understanding of the Diamond API.

* First get a D compiler here: https://dlang.org/download.html
* Then download and install DUB: http://code.dlang.org/download
* After that add the dependency to *Diamond* in your dub.json file
* Simply import *diamondapp* and use *getView* to retrieve the views you want to render.

## Contributing

It's appreciated if you want to contribute to Diamond as there currently are no other developers on the project, other than me.

If you wish to contribute simply do the following:

* Fork the project
* Make your changes
* Create a pull request

Please follow the following guide-lines though:

* Use the same coding-style, naming-convention etc.
* Keep each pull request to a single change or implementation to simplify merging

*Please view the wki for more information.*

*Coming soon: Diamond website.*
