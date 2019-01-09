/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.data.transaction;

/// Wrapper for transactional data management.
final class Transaction(T)
if (is(T == struct) || isScalarType!T)
{
  private:
  /// The commit delegate.
  void delegate(Snapshot!T) _commit;
  /// The success delegate.
  void delegate(Snapshot!T) _success;
  /// The failure delegate.
  bool delegate(Snapshot!T, Throwable, size_t) _failure;

  public:
  final:
  /// Creates a new transactional data manager.
  this() { }

  /**
  * Creates a new transactional data manager.
  * Params:
  *   onCommit = The delegate called when committing.
  *   onSuccess = The delegate called when a commit succeeded.
  *   onFailure = The delegate called when a commit failed.
  */
  this
  (
    void delegate(Snapshot!T) onCommit,
    void delegate(Snapshot!T) onSuccess,
    bool delegate(Snapshot!T, Throwable, size_t) onFailure
  )
  {
    _exec = onExec;
    _success = onSuccess;
    _failure = onFailure;
  }

  @property
  {
    /// Sets the delegate called when comitting.
    void commit(void delegate(Snapshot!T) onCommit)
    {
      _commit = onCommit;
    }

    /// Sets the delegate called when a commit succeeded.
    void success(void delegate(Snapshot!T) onSuccess)
    {
      _success = onSuccess;
    }

    /// Sets the delegate called when a commit failed.
    void failure(bool delegate(Snapshot!T, Throwable, size_t) onFailure)
    {
      _failure = onFailure;
    }
  }


  /**
  * Commits the transaction.
  * Params:
  *   snapshot = The snapshot to commit.
  *   retries = The amount of retries a commit has had.
  */
  private void call(Snapshot!T snapshot, size_t retries)
  {
    try
    {
      if (_commit) _commit(snapshot);
      if (_success) _success(snapshot);
    }
    catch (Throwable t)
    {
      if (_failure && _failure(snapshot, t, retries))
      {
        call(snapshot, retries + 1);
      }
      else
      {
        throw t;
      }
    }
  }

  /// Operator overload for calling the transaction and committing it.
  void opCall(Snapshot!T snapshot)
  {
    call(snapshot, 0);
  }
}
