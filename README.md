# Diamond

[![DONATE](https://img.shields.io/badge/Support%20Diamond-Donate-brightgreen.svg)](http://diamondmvc.org/donate)
[![OS](https://img.shields.io/badge/os-windows%20%7C%20linux%20%7C%20macos-ff69b4.svg)](http://code.dlang.org/packages/diamond)
[![LOC](https://img.shields.io/badge/lines--of--code-12000%2B%20%7C%2020000%2B-yellow.svg)](http://code.dlang.org/packages/diamond)
[![Dub version](https://img.shields.io/dub/v/diamond.svg)](http://code.dlang.org/packages/diamond)
[![Dub downloads](https://img.shields.io/dub/dt/diamond.svg)](http://code.dlang.org/packages/diamond)
[![License](https://img.shields.io/dub/l/diamond.svg)](http://code.dlang.org/packages/diamond)

Diamond is a powerful full-stack web-framework written in the [D Programming Language](http://dlang.org/).

Diamond can be used to write powerful websites, webapis or as stand-alone as a template parser.

Website: http://diamondmvc.org/

## Key-Features

[![Key features of Diamond](https://i.imgur.com/5W6sbpR.png)](https://i.imgur.com/5W6sbpR.png)

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
* Diamond should be stable enough and have enough features to be used in enterprise and commercial work.
* Always free & open-source
  * Diamond should always remain free and open-source, no matter the framework's size or popularity.
* As little dependencies as possible
  * The less dependencies Diamond has, the better.
  * library dependencies for database drivers etc. are okay
* Cross-platform
  * Should always be able to support all platforms that *vibe.d*/*DMD* supports.
* Natural development feeling
  * Using Diamond should feel natural without annoyance, so you can focus more on developing your application, rather than setting up Diamond.

## Dependencies

|Package|Version|Description|
|---|:--:|---|
|vibe.d|0.8.3|Used as the backend for Diamond's web applications.|
|DMD/Phobos|2.072.2 - 2.077.0|The standard library of D and thus a required dependency.|
|Mysql-native|2.2.1|A native wrapper for Mysql. It's a dependency, because of the MySql ORM.|

## Example

### View

Layout:
```
@<doctype>
<html>
<head>
  <title>Website - @<title></title>
</head>
<body>
  @<view>
</body>
</html>
```

View:

```
@[
  layout:
    layout
---
  route:
    home
---
  model:
    Home
---
  controller:
    HomeController
---
  placeholders:
    [
      "title": "Home"
    ]
]

<p>Hello @=model.name;!</p>
```

### Controller

```
module controllers.homecontroller;

import diamond.controllers;

final class HomeController(TView) : Controller!TView
{
  this(TView view)
  {
    super(view);
  }
  
  /// / || /home
  @HttpDefault Status defaultAction()
  {
    view.model = new Home("World!");
    
    return Status.success;
  }
  
  /// /home/setname/{name}
  @HttpAction(HttpPost) Status setName()
  {
    auto name = this.getByIndex!string(0);
    view.model = new Home(name);
    
    return Status.success;
  }
}
```

### Model

```
module models.home;

final class Home
{
  private:
  string _name;
  
  public:
  final:
  this(string name)
  {
    _name = name;
  }
  
  @property
  {
    string name() { return _name; }
  }
}
```

## FAQ

See: http://diamondmvc.org/faq

### Are there any syntax guide-lines?

See: http://diamondmvc.org/docs/views/#syntax

## Installing (Web)

See: http://diamondmvc.org/download

## Installing (Standalone)

Using Diamond stand-alone is a little more tricky than using it for web as there are no specific guide-lines in how to use it.

It's not advised to use Diamond as stand-alone until you have a basic understanding of the Diamond API.

* First get a D compiler here: https://dlang.org/download.html
* Then download and install DUB: http://code.dlang.org/download
* After that add the dependency to *Diamond* in your dub.json file
* Simply import *diamondapp* and use *getView* to retrieve the views you want to render.

## Contributing

See: http://diamondmvc.org/contribute

## Version & Branch Support

Diamond only supports up to the 3 latest minor versions of itself, including pre-release versions.

If a version is not supported its working branch is deleted.

Anything below 2.7.0 is no longer supported, because 2.7.0 has better compatibility, does not introduce major breaking changes and fixes most major issues.

Currently supported versions: 2.7.0 - 2.9.0

No longer supported (Only available in release.): 2.0.0 - 2.6.1
