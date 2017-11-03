[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Models

Models in Diamond can be of any types, but user-defined models are generally structs or classes.

There's no specific design principle on how a model should look as it entirely comes down to the developer.

Example:

```
class Home
{
    private:
    string _title;
    
    public:
    this(string title)
    {
        _title = title;
    }
    
    @property string title() { return _title; }
}
```

## General Rules For Models

* Logic should be kept out of models
* Models should be simple (Shouldn't contain much more than fields and properties.)
* Models shouldn't have side-effects in their properties

## Database Models

When using the package *diamond-db* you can create database models that can be used for the MySql ORM.

### Example

```
class MyModel : DatabaseModel!"mymodel_table"
{
  public:
  @DbId ulong id;
  string name;

  this() { super(); }
}
```

Attributes for models are:

* @DbNull
  * All values that can be null should be marked @DbNull to handle them properly when reading from the database.
* @DbEnum
  * All values that are based on string enums should be marked with @DbEnum.
* @DbTimestamp
  * All fields of std.datetime.DateTime that should be updated to current time when inserting or updating should be marked with this.
* @DbNoMap
  * Used to ignore mapping of specific fields in the model.
* @DbId
  * Used to mark the identity column of a model.
