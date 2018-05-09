/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.mapping.model;

/// Base-interface for a model.
interface IModel { }

/// Wrapper for a base model.
abstract class Model : IModel
{
  private:
  /// The reader.
  void delegate() _reader;
  /// The inserter.
  void delegate() _inserter;
  /// The updater.
  void delegate() _updater;
  /// The deleter.
  void delegate() _deleter;
  /// The relationship reader.
  void delegate() _readerRelationship;

  public:
  final:
  /// Creates a new model.
  this
  (
    void delegate() reader,
    void delegate() inserter,
    void delegate() updater,
    void delegate() deleter,
    void delegate() readerRelationship
  )
  {
    _reader = reader;
    _inserter = inserter;
    _updater = updater;
    _deleter = deleter;
    _readerRelationship = readerRelationship;
  }

  /// Reads the model from the reader. Called internally from readSingle & readMany
  void readModel() @system
  {
    if (_reader)
    {
      _reader();
    }
  }

  /// Inserts the model.
  void insertModel() @system
  {
    if (_inserter)
    {
      _inserter();
    }
  }

  /// Updates the model.
  void updateModel() @system
  {
    if (_updater)
    {
      _updater();
    }
  }

  /// Deletes the model.
  void deleteModel() @system
  {
    if (_deleter)
    {
      _deleter();
    }
  }

  /// Reads the relationships the model has.
  void readRelationships() @system
  {
    if (_readerRelationship)
    {
      _readerRelationship();
    }
  }
}

// TODO: Optimize these to do CTFE:

/**
* Inserts an array of models.
*  Params:
*    models = The models to insert.
*/
void insertMany(T : IModel)(T[] models) @system
{
  foreach (model; models)
  {
    model.insertModel();
  }
}

/**
* Updates an array of models.
*  Params:
*    models = The models to update.
*/
void updateMany(T : IModel)(T[] models) @system
{
  foreach (model; models)
  {
    model.updateModel();
  }
}

/**
* Deletes an array of models.
*  Params:
*    models = The models to delete.
*/
void deleteMany(T : IModel)(T[] models) @system
{
  foreach (model; models)
  {
    model.deleteModel();
  }
}
