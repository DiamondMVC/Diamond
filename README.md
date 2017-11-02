# Diamond

[![OS](https://img.shields.io/badge/os-windows%20%7C%20linux%20%7C%20macos-ff69b4.svg)](http://code.dlang.org/packages/diamond)
[![LOC](https://img.shields.io/badge/lines--of--code-4000%2B%20%7C%207000%2B-yellow.svg)](http://code.dlang.org/packages/diamond)
[![Dub version](https://img.shields.io/dub/v/diamond.svg)](http://code.dlang.org/packages/diamond)
[![Dub downloads](https://img.shields.io/dub/dt/diamond.svg)](http://code.dlang.org/packages/diamond)
[![License](https://img.shields.io/dub/l/diamond.svg)](http://code.dlang.org/packages/diamond)

Diamond is a poweful MVC / Template Framework written in the [D Programming Language](http://dlang.org/).

Diamond can be used to write powerful websites, webapis or as stand-alone as a template parser.

## Goals

* To provide a powerful consistent API
  * The API of Diamond should be rich of features, but still with powerful performance and the style should be consistent all over.
* High performance without complexity
  * The performance of Diamond should be high without making the API complex to use.
* Compile-time template parsing
  * Templates are parsed at compile-time and thus produce very little run-time overhead.
* Easy-to-use and feature-rich template syntax
  * The syntax of templates should be feature-rich, with an easy-to-use syntax.
  * It should be easy to create advanced templates without complex looking code.
* Secure & less error-prone API
  * The API of Diamond should provide security to battle error-prone code, enabling code to be written "bug-free".
* Enterprise development
  * Diamond should be stable enough and have enough features to be used in enterprice and commercial work.
* Always free & open-source
  * Diamond should always remain free and open-source, no matter the framework's size or popularity.
* As little dependencies as possible
  * The less dependencies Diamond has, the better.
* Cross-platform
  * Should always be able to support all platforms that *vibe.d*/*DMD* supports.
* Natural development feeling
  * Using Diamond should feel natural without annoyance, so you can focus more on developing your application, rather than setting up Diamond.

## Dependencies

|Package|Version|Optional|Description|
|---|:--:|:--:|---|
|vibe.d|0.8.1|Yes|Used as the backend for Diamond's web applications.|
|DMD/Phobos|2.072.2 - 2.076.1|No|The standard library of D and thus a required dependency.|
|Diamond-db|0.0.2|Yes|An ORM based on Mysql that is compatible with Diamond.|
|Mysql-native|0.1.6|Yes|A native wrapper for Mysql. It's a dependency to Diamond-db.|

## History

Diamond was originally written as a template parsing library only; completely as an alternative version to vibe.d's diet templates. However soon after development it evolved to a full-fletch powerful restful mvc framework on-top of vibe.d. The goal of Diamond was from the beginning to write powerful web-applications with the style of ASP.NET

The legacy project of Diamond can be found here: https://github.com/bausshf/Diamond/

## Quick-links

Syntax Reference: https://github.com/DiamondMVC/Diamond/wiki/Syntax-Reference

Comparison with ASP.NET Razor: https://github.com/DiamondMVC/Diamond/wiki/Razor-Comparison

Controller Tutorial: https://github.com/DiamondMVC/Diamond/wiki/Controller-Tutorial

Understanding The Core: https://github.com/DiamondMVC/Diamond/wiki/Understanding-The-Core

Using Diamond Stand-alone: https://github.com/DiamondMVC/Diamond/wiki/Using-Diamond-Stand-alone

Using Diamond for Web-api: https://github.com/DiamondMVC/Diamond/wiki/Using-Diamond-For-WebApi

Using Diamond for Web-server: https://github.com/DiamondMVC/Diamond/wiki/Using-Diamond-For-WebServer

Extensions: https://github.com/DiamondMVC/Diamond/wiki/Extensions

Authentication & ACL: https://github.com/DiamondMVC/Diamond/wiki/Authentication-&-ACL

Blog posts: https://github.com/DiamondMVC/Diamond/wiki/Blog-Posts

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
 * ACL & Authentication tied to it
 * Separate authentication that can be used either with or without the ACL
 * CSRF Protection
 * Easy integrated cookie/session API.
 * The network can be restricted to specific ips.

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
* Allows for sections, which is useful to only render a part of the view. (Very useful for responsive designs)
* Can be passed to controllers by their base view
* Layout views can be changed dynamically
* Expensive views can be cached.

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
* Easy integrated authentication (Can be combined with ACL)
* RESTful
* Specific actions can be restricted to specific ips.

### Controllers (WebServer)

* Can access the view directly by the *view* property.
  * *Note: To access requests, response etc. you must go through the view.*
* Can easily return json data either by returning models that are serialized as json or by composing json strings.
* Can easily redirect by calling redirectTo()

### Controllers (WebApi)

* Can access the request, response etc. directly.
* Can have multiple routes associated with them.

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
* Allows for sections, which is useful to only render a part of the view. (Very useful for responsive designs)
* Layout views can be changed dynamically

### Models

* Models can be of any datatype (classes, structs, enums, scalar etc.)
* Models are optional
* Models can be passed around in view rendering

## FAQ

### What is Diamond?

Diamond is a powerful cross-platform full-fletch MVC / Template Framework written in The D Programming language.

### What does Diamond depend on?

View the dependencies above.

### What is the dependency to Vibe.d?

Diamond uses vibe.d as the backend for its webapplications. This comes historically fromthat Diamond was originally written as an alternative template engine to vibe.d's diet templates.

### What syntax does Diamond use?

Diamond is heavily inspired by the ASP.NET Razor syntax, but still differs a lot from it. You can read more about that in the wiki under Syntax Reference or the comparison with ASP.NET Razor

### What advantage does Diamond have over Diet?

It let's you control the markup entirely, can be integrated with any-type of D code, not limited to vibe.d and can be used as standard template library for any type of project such as email templates etc. It also allows for special rendering, easy controller implementations and management of request data, response etc.

Another advantage is that Diamond is very light-weight when used standa-lone; where Diet depends on vibe.d and to use it you must have the whole library referenced.

### Does Diamond parse on every request like ex. PHP?

No. Views are parsed once during compile-time and then compiled into D code that gets executed on run-time; keeping view generation to a minimum, while performance and speed is kept high. The downside of this is that on every changes in code you'll need to recompile. However it's recommended to setup an environment that checks for changes and then simply recompiles when changes are found.

You can use this: (Until *Cryztal* has been developed.)

http://code.dlang.org/packages/fswatch

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
* After that download this empty Diamond project:
  * (WebServer) https://github.com/DiamondMVC/Diamond-Template-WebServer
  * (WebApi) https://github.com/DiamondMVC/Diamond-Template-WebApi
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

## Version & Branch Support

Diamond only supports up to the 3 latest minor versions of itself, including pre-release versions.

If a version is not supported its working branch is deleted.

Currently supported versions: 2.2.0 - 2.4.3

No longer supported (Only available in release.): 2.0.0 - 2.1.2
