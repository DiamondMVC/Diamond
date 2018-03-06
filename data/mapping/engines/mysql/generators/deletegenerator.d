/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.mysql.generators.deletegenerator;

import std.string : format;
import std.traits : hasUDA, FieldNameTuple;

import diamond.core.traits;
import diamond.data.mapping.attributes;
import diamond.data.mapping.engines.mysql.model : IMySqlModel;

package(diamond.data):
/**
* Generates the delete function for a database model.
* Returns:
*   The delete function string to use with mixin.
*/
string generateDelete(T : IMySqlModel)()
{
  import models;

  string s = q{
    {
      static const sql = "DELETE FROM `%s` WHERE `%s` = ?";
      auto params = getParams(1);

      %s

      MySql.executeRaw(sql, params);
    }
  };

  string idName;
  string idParams;

  {
    mixin HandleFields!(T, q{{
      enum hasId = hasUDA!({{fullName}}, DbId);

      static if (hasId)
      {
        idName = "{{fieldName}}";
        idParams = "params[0] = model.{{fieldName}};";
      }
    }});
    mixin(handleThem());

    if (!idName)
    {
      return "";
    }
  }

  return s.format(T.table, idName, idParams);
}
