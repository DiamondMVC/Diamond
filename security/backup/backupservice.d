/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.backup.backupservice;

import diamond.security.backup.backuppath;

/// Wrapper around a backup service.
abstract class BackupService
{
  private:
  /// The paths to backup.
  BackupPath[] _paths;
  /// The time to wait between backing up.
  size_t _time;

  protected:
  /**
  * Creates a new backup service.
  * Params:
  *   time = The time to wait between backing up.
  */
  this(size_t time)
  {
    _time = time;
  }

  /**
  * Handler for performing a backup.
  * Params:
  *   paths = The paths to backup.
  */
  abstract void onBackup(const(BackupPath[]) paths);

  public:
  @property
  {
    /// Gets the time to wait between backing up.
    const(size_t) time() { return _time; }
  }
  /**
  * Adds a path to backup.
  * Params:
  *   path = The path to backup.
  */
  void addPath(BackupPath path)
  {
    _paths ~= path;
  }

  package(diamond):
  /// Performs the specified backup.
  void backup()
  {
    if (_paths)
    {
      onBackup(_paths);
    }
  }
}
