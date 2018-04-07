/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.postgresql.model;

version (Diamond_PostgreSqlDev)
{
  import std.datetime : Date, DateTime, Clock, SysTime;

  import vibe.data.serialization : ignore;

  import diamond.data.mapping.model;
  import diamond.data.mapping.attributes;
  import diamond.data.mapping.engines.postgresql.generators;

  /// Base-interface for a postgresql model.
  interface IPostgreSqlModel { }

  /**
  * Converts a SysTime to a DateTime.
  *  Params:
  *    sysTime = The SysTime to convert.
  *  Returns:
  *    The converted DateTime.
  */
  private DateTime asDateTime(SysTime sysTime)
  {
    return DateTime(sysTime.year, sysTime.month, sysTime.day, sysTime.hour, sysTime.minute, sysTime.second);
  }

  /**
  * Creates a new postgresql model.
  *  Params:
  *    tableName = The name of the table the model is associated with.
  */
  class PostgreSqlModel(string tableName) : Model, IPostgreSqlModel
  {
    private
    {

    }

    public:
    final:
    /// The table name.
    @ignore static const string table = tableName;

    /// Creates a new database model.
    this(this TModel)()
    {
      auto model = cast(TModel)this;

      import models;

      mixin
      (
        "super(%s, %s, %s, %s);".format
        (
          "null", generateInsert!TModel,
          "null", "null"
        )
        /*"super(%s, %s, %s, %s);".format
        (
          generateRead!TModel, generateInsert!TModel,
          generateUpdate!TModel, generateDelete!TModel
        )*/
      );
    }

    @property
    {

    }
  }
}
