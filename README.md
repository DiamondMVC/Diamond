# Diamond

[![DONATE](https://img.shields.io/badge/Support%20Diamond-Donate-brightgreen.svg)](https://diamondmvc.org/donate)
[![OS](https://img.shields.io/badge/os-windows%20%7C%20linux%20%7C%20macos-ff69b4.svg)](http://code.dlang.org/packages/diamond)
[![LOC](https://img.shields.io/badge/lines--of--code-%2027000%2B-yellow.svg)](http://code.dlang.org/packages/diamond)
[![Dub version](https://img.shields.io/dub/v/diamond.svg)](http://code.dlang.org/packages/diamond)
[![License](https://img.shields.io/dub/l/diamond.svg)](http://code.dlang.org/packages/diamond)

Diamond is a powerful full-stack web-framework written in the [D Programming Language](http://dlang.org/).

Diamond can be used to write powerful websites, webapis or as stand-alone as a template parser.

Website: https://diamondmvc.org/

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
|vibe.d|0.8.3|Used as the backend for Diamond's web applications. From 3.0.0 vibe.d will be an optional dependency.|
|DMD/Phobos|2.072.2 - 2.077.0|The standard library of D and thus a required dependency.|
|Mysql-native|2.2.1|A native wrapper for Mysql. It's a dependency, because of the MySql ORM.|
|ddbc|X.X.X|A database wrapper in D to a lot of database systems. Diamond will be using it for PostgreSQL, Sqlite and MSSQL.|

## Example (2.X.X)

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

## Example (3.X.X)

### View

Layout:
```
@(doctype)
<html>
<head>
  <title>Website - @(title)</title>
</head>
<body>
  @(view)
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

### Controller (View)

```
module controllers.homecontroller;

import diamond.controllers;

final class HomeController(TView) : WebController!TView
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
  @HttpAction(HttpPost) Status setName(string name)
  {
    view.model = new Home(name);
    
    return Status.success;
  }
}
```

### Controller (Api)

```
module controllers.usercontroller;

import diamond.controllers;

final class UserController : ApiController
{
  this(HttpClient client)
  {
    super(client);
  }
  
  /// /user/update
  @HttpAction(HttpPost) Status update(UserModel user)
  {
    // Do stuff ...
    
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

...

module models.user;

final class User
{
  public:
  string name;
  int age;
}
```


## FAQ

See: https://diamondmvc.org/faq

### Are there any syntax guide-lines?

See: https://diamondmvc.org/docs/views/#syntax

## Installing (Web)

See: https://diamondmvc.org/download

## Installing (Standalone)

Not supported since 3.0.0

## Contributing

See: https://diamondmvc.org/contribute

## Version & Branch Support

Diamond only supports up to the 3 latest minor versions of itself, including pre-release versions.

If a version is not supported its working branch is deleted.

Anything below 2.10.0 is no longer supported, because earlier versions are not adviced to use unless necessary.

2.10.0+ is generally backward compatible, but 3.0.0 is not.

Currently supported versions: 2.10.0 - 3.0.0

No longer supported (Only available in release.): < 2.10.0

Note: 3.0.0 is not yet supported, but the master branch is 3.0.0
