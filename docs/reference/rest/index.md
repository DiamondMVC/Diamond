[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# REST

By default most controller routes already acts partially REST, but to be completely RESTful there are a few additions that must be made.

You must use [ACL](https://diamondmvc.github.io/Diamond/docs/reference/acl/) properly, as the correct http methods must only have the correct permissions.

See: [ACL - Default Required Permissions](https://diamondmvc.github.io/Diamond/docs/reference/acl/#default-required-permissions)

For controllers you must setup actions using specialized type-secure routes.

## Special Routes

Diamond supports a special route syntax for http actions, which is useful to create RESTful web applications.

If the first entry is *\<>* then it will use the function name as the action name, otherwise the first entry specified is the action name.

To create an entry with a specific type you must write *{type}* and to get the entry a specific name you must write *{type:name}*.

The route also supports wildcards which will accept anything. Wildcards are specified with *\**

### Example routes:

```
@HttpAction(HttpGet, "/product/{uint:productId}/") Status getProduct()
{
    auto productId = get!uint("productId");
    auto product = getProductFromDatabase(productId);

    return json(product);
}
```

```
@HttpAction(HttpPut, "/product/{uint:productId}/") Status insertOrUpdateProduct()
{
    auto productId = get!uint("productId"); // If the id is 0 then we'll insert, else we'll update.

    insertProductToDatabase(productId, view.client.json); // Normally you'll want to deserialize the json

    return jsonString(q{{ "success": true }});
}
```

```
@HttpAction(HttpDelete, "/product/{uint:productId}/") Status deleteProduct()
{
    auto productId = get!uint("productId");

    deleteProductFromDatabase(productId);

    return jsonString(q{{ "success": true }});
}
```

There are two functions provided by the controller used to retrieve the passed data.

*get(T)(string name);* -- Will get named values. Ex. in the examples above *productId* would be a named value.

*get(T)(size_t index);* -- Will get values based on their index in the route. Ex. *productId* would have be at index *0*.
