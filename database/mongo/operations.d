/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.database.mongo.operations;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.data.json;

  import diamond.errors.checks;
  import diamond.database.mongo;

  /**
  * Finds a single document.
  * Params:
  *   collection = The mongo db collection.
  *   query =      The find query.
  * Returns:
  *   Returns a single document result if found.
  */
  T findSingle(T,TQuery)(string collection, TQuery query)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    auto result = client.getCollection(collection).findOne!T(query);

    if (!result.isNull)
    {
      return result.get!T;
    }

    return T.ini;
  }

  /**
  * Finds a set of documents.
  * Params:
  *   collection = The mongo db collection.
  *   query =      The find query.
  * Returns:
  *   Returns an array of the document results found.
  */
  T[] findMany(T,TQuery)(string collection, TQuery query)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    import std.array : array;

    return client.getCollection(collection).find!T(query).array;
  }

  /**
  * Inserts a single document.
  * Params:
  *   collection = The mongo db collection.
  *   document =   The document to insert.
  */
  void insertSingle(T)(string collection, T document)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    client.getCollection(collection).insert(document);
  }

  /**
  * Inserts a set of documents.
  * Params:
  *   collection = The mongo db collection.
  *   documents =   The documents to insert.
  */
  void insertMany(T)(string collection, T[] documents)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    client.getCollection(collection).insert(documents);
  }

  /**
  * Updates a set of documents based on a query.
  * Params:
  *   collection = The mongo db collection.
  *   query =      The query of the update.
  *   update =     The data to update the document(s) with.
  */
  void update(TQuery,TUpdate)(string collection, TQuery query, TUpdate update)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    client.getCollection(collection).update(query, update);
  }

  /**
  * Removes a set of documents based on a query.
  * Params:
  *   collection = The mongo db collection.
  *   query =      The query of the update.
  */
  void remove(TQuery,TUpdate)(string collection, TQuery query)
  {
    enforce(client !is null, "Mongodb has not been configured properly.");

    client.getCollection(collection).remove(query);
  }
}
