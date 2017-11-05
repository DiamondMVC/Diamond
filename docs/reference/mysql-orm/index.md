[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Mysql ORM

Diamond has a build-in ORM for MySql.

All models used by the ORM must be placed in the *models* package.

To use the ORM you must have a *db.json* file within your *config* folder.

### db.json

```
 {
   "host": "127.0.0.1",
   "user": "mydbuser",
   "password": "mydbpw",
   "database": "mydb"
 }
```

## Attributes

### @DbNull

All fields that can have a null-value should be marked with this attribute.

### @DbEnum

All fields that are treated like db-enums should be marked with this attribute.

A db-enum is an enum of strings.

### @DbTimestamp

All fields of *std.datetime.DateTime* that should be updated with current time on insert/updates should be marked with this attribute.

### @DbNoMap

All fields that shouldn't be mapped should be marked with this attribute.

### @DbId

Used to mark which field is used for the identity column.

## Example Model

```
module models.mymodel;

import diamond.database;

class MyModel : MySql.MySqlModel!"mymodel_table"
{
  public:
  @DbId ulong id;
  string name;

  this() { super(); }
}
```

## Example Usages

### Read Single

```
import diamond.database;
import models;

static const sql = "SELECT * FROM `@table` WHERE `id` = @id";

auto params = getParams();
params["id"] = cast(ulong)1;

auto model = MySql.readSingle!MyModel(sql, params);
```

### Read Many

```
import diamond.database;
import models;

static const sql = "SELECT * FROM `@table`";

auto modelsRead = MySql.readMany!MyModel(sql, null);
```

### Insert

```
import models;

auto model = new MyModel;
model.name = "Bob";

model.insertModel();
```

### Insert Many

```
import models;
import diamond.database;

auto model1 = new MyModel;
model1.name = "Bob";

auto model2 = new MyModel;
model2.name = "Sally";

auto modelsToInsert = [model1, model2];

modelsToInsert.insertMany();
```

### Update

```
import models;

auto model = new MyModel;
model.id = 1;
model.name = "ThisIsNotBobAnymore";

model.updateModel();
```

### UpdateMany

```
import models;
import diamond.database;

auto model1 = new MyModel;
model1.id = 1;
model1.name = "ThisIsNotBobAnymore";

auto model2 = new MyModel;
model2.id = 2;
model2.name = "ThisIsNotSallyAnymore";

auto modelsToUpdate = [model1, model2];

modelsToUpdate.updateMany();
```

### Delete

```
import models;

auto model = new MyModel;
model.id = 1;

model.deleteModel();
```

### Delete Many

```
import models;
import diamond.database;

auto model1 = new MyModel;
model1.id = 1;

auto model2 = new MyModel;
model2.id = 2;

auto modelsToDelete = [model1, model2];

modelsToDelete.deleteMany();
```

## Parameters

Diamond's MySql implementation allows for two types of parametized queries.

The first one is the traditional parametized statement using **?** and the second one is one using named parameters like **@name**.

### Traditional

To use traditional parameters you must use the **\*raw()** functions provided by the MySql API such as:

* executeRaw()
* existsRaw()
* readManyRaw()
* readSingleRaw()
* scalarInsertRaw()
* scalarRaw()

Example:

```
import models;
import diamond.database;

static const sql = "SELECT * FROM `mymodel_table` WHERE id = ?";

auto params = getParams(1);
params[0] = cast(ulong)1;

auto model = MySql.readSingleRaw!MyModel(sql, params);
```

### Named Parameters

To use named parameters you must use the **non-\*raw()** functions provided by the MySql API such as:

* execute()
* exists()
* readMany()
* readSingle()
* scalarInsert()
* scalar()

When using the named parameter **@table** then it will automatically take the table name from the model. You don't need to add **@table** to the named-parameters collection.

Example:

```
import models;
import diamond.database;

static const sql = "SELECT * FROM `@table` WHERE id = @id";

auto params = getParams();
params["id"] = cast(ulong)1;

auto model = MySql.readSingle!MyModel(sql, params);
```
