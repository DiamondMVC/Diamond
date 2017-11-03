[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Basics

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
