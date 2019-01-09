/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.database.mongo;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.db.mongo.mongo;
  import vibe.db.mongo.client;

  /// The mongo db client.
  private static __gshared MongoClient _client;

  public
  {
    import MongoDb = diamond.database.mongo.operations;
  }

  package(diamond)
  {
    /**
    * Initializes the mongo db connection.
    * Params:
    *   host = The host of the mongo db.
    *   port = The port of the mongo db host. Only specify this the host is an ip address.
    */
    void initializeMongo(string host, ushort port = 0)
    {
      if (port)
      {
        _client = connectMongoDB(host, port);
      }
      else
      {
        _client = connectMongoDB(host);
      }
    }

    /// Gets the raw vibe.d mongo client.
    @property MongoClient client()
    {
      return _client;
    }
  }
}
