/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.engines.sqlshared.sqlentityformatter;

/// Wrapper around a mysql entity formatter.
abstract class SqlEntityFormatter(TModel)
{
  protected:
  /// Creates a new sql entity formatter.
  this()
  {

  }

  public:
  /// Generates the read mixin.
  abstract string generateRead();

  /// Generates the insert mixin.
  abstract string generateInsert();

  /// Generates the update mixin.
  abstract string generateUpdate();

  /// Generates the delete mixin.
  abstract string generateDelete();

  /// Generates the read relationship mixin.
  abstract string generateReadRelationship();
}
