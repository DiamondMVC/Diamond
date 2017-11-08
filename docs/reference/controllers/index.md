[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Controllers

The examples focuses mostly on controllers for webservers, however using them for webapis are pretty much the same, except for no view support.

## 1. Setting up a controller

Controllers are simply classes that inherit from the *Controller* class. To create a controller, one must create a new class that inherits from that. For websites you must specify a generic type for views.

```
final class MyController(TView) : Controller!TView
{
}
```

The entry route for a controller is always the view that it inherits. For webapis it's of course the name given to the controller. This means that controllers for websites are more dynamically, as they aren't defined by themselves, but by views, where as controllers for webapis are always stand-alone.

## 2. The constructor

After declaring a controller, a constructor must be setup.

The constructor for websites takes in a view, where the constructor for webapi takes a request, response and a route.

The constructor is called for every request and can be used to handle connections before actions.

## 3. Routing

There are 3 types of actions that can be mapped to routes.

Default actions, mandatory actions and regular actions. A controller can only have one default action, which is the action called when no action has been specified, a mandatory action is an action that is always called and must go through successfully for the actual action to be executed. Mandatory actions can be used for authentication, validation etc. and can only be mapped once just like default actions. At last there is the regular actions, which are just actions mapped to a specific action route.

Routing for controllers are as following:

	/{controller-route|view-route}/{action}/{params}

Note: Instead of using params, you can use query strings.

* void mapDefault(Action fun);
* void mapDefault(Status delegate() d);
* void mapDefault(Status function() f);

*mapDefault* maps the default action.

* void mapMandatory(Action fun);
* void mapMandatory(Status delegate() d);
* void mapMandatory(Status function() f);

*mapMandatory* maps a mandatory action.

* void mapAction(HttpMethod method, string action, Action fun);
* void mapAction(HttpMethod method, string action, Status delegate() d);
* void mapAction(HttpMethod method, string action, Status function() f);

*mapAction*  will map an action to a method and an action name.

These functions are usually called in the constructor, however it's recommended to just use the attributes available for mapping. The examples below rely on the mapping attributes.

Example implementation on a constructor

```
this(TView view)
{
    super(view);
}
```

# 4. Actions

In this case *defaultAction* will be used to tell the user he needs to specify an action, *getData* will get some json data and save data will save some json data.

# 5. defaultAction

```
@HttpDefault Status defaultAction()
{
    view.model.message = "You must specify an action.";

    return Status.success;
}
```

# 6. getData

```
@HttpAction(HttpGet) Status getData()
{
    auto id = this.getByIndex!int(0); // The first parameter is the id

    auto data = Database.getData(id); // Gets data from the id

    return json(data); // Returns the data as a json response
}
```

*getData* can be called like */MyView/GetData/10000* where MyView is the view we call the action from, GetData is the route to the mapped action and 10000 is the first parameter specified.

# 7. saveData

```
@HttpAction(HttpPost) Status saveData()
{
    auto id = this.getByIndex!int(0); // The first parameter is the id

    Database.saveData(id, view.client.json); // Saves the json data to the specified id.
		
    // Returns a json response with a boolean set as true for success
    return jsonString(`{
        "success": true
    }`);
} 
```

*saveData* can be called like */MyView/SaveData/10000* where MyView is the view we call the action from, SaveData is the route to the mapped action and 10000 is the first parameter specified. The body of the request should be json data to save.

For webapis you don't need to specify view to retrieve params, request, response etc.

## Redirection

You can redirect to a specific url directly from a controller. However you must either return directly during the redirect call or manually return with *Status.end* afterwards. The redirect call already returns *Staus.end* to you.

If you need to process something afterwards then you can use *HttpClient.redirect()*. The instance of *HttpClient* can be accessed with the view's *client* property.

Example:
```
Status someCall()
{
    if (!isLoggedIn(client))
    {
        return redirectTo("/login");
    }

    return Status.success;
}
```
