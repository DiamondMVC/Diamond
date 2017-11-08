[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Version-control

Diamond supports version control for controllers, which is useful when developing for production.

This allows you to add new functionality without breaking existing functionality.

To use version-control you must assign a controller with the **@HttpVersion** attribute which takes two values.

The values of the attribute are as following.

### Version Identifier

The first value of the attribute is the version identifier. This is the version in which the controller must branch out to the new controller.

Ex. if the identifier is **v2** then the controller will branch out when a request is sent with **v2** as the version.

*Note: You cannot have multiple versions to branch to. A controller may only branch out once.*

### Version Controller

The second value of the attribute is the name of the controller which the current controller branches out to.

The value must be in form of a string, since you can't pass symbols to an attribute.

## Example Of Version-control

Old home controller:

```
@HttpVersion("v2", NewHomeController.stringof) final class OldHomeController(TView) : Controller!TView
{
  public:
  final:
  /**
  * Creates a new instance of the old home controller.
  * Params:
  *   view =  The view assocaited with the controller.
  */
  this(TView view)
  {
    super(view);
  }

  /// Route: / | /home
  @HttpDefault Status home()
  {
    return Status.success;
  }
  
  /// Route: /home/getValue
  @HttpAction(HttpGet) Status getValue()
  {
      return jsonString(`{
          "success": true,
          "message": "Old"
      }`);
  }
}
```

New home controller:

```
final class NewHomeController(TView) : Controller!TView
{
  public:
  final:
  /**
  * Creates a new instance of the new controller.
  * Params:
  *   view =  The view assocaited with the controller.
  */
  this(TView view)
  {
    super(view);
  }

  /// Route: /home/v2
  @HttpDefault Status home()
  {
    return Status.success;
  }
  
  /// Route: /home/v2/getValue
  @HttpAction(HttpGet) Status getValue()
  {
      return jsonString(`{
          "success": true,
          "message": "New"
      }`);
  }
}
```

When calling: **/home/getValue** you get the following json:

```
{
    "success". true,
    "message". "Old"
}
```

When calling: **/home/v2/getValue** you get the following json:


```
{
    "success". true,
    "message". "New"
}
```
