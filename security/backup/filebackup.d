/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.backup.filebackup;

import diamond.security.backup.backupservice;
import diamond.security.backup.backuppath;

/// Wrapper around a file backup service.
final class FileBackupService : BackupService
{
  public:
  /**
  * Creates a new file backup service.
  * Params:
  *   time = The time to wait between backing up.
  */
  this(size_t time)
  {
    super(time);
  }

  protected:
  /**
  * Handler for performing a file backup.
  * Params:
  *   paths = The paths to backup.
  */
  override void onBackup(const(BackupPath[]) paths)
  {
    import std.file : dirEntries, SpanMode, exists, isFile, isDir, rmdirRecurse, copy;
    import std.path : dirName;
    import std.array : replace;

    foreach (path; paths)
    {
      if (path.source.isDir && path.destination.isDir)
      {
        if (!path.destination.exists)
        {
          rmdirRecurse(path.destination);
        }

        foreach (string entryPath; dirEntries(path.source, SpanMode.depth))
        {
          auto subEntryPath = path.destination ~ "/" ~ entryPath.replace(path.source, "");

          if (subEntryPath.isDir && !subEntryPath.exists)
          {
            rmdirRecurse(subEntryPath);
          }
          else if (subEntryPath.isFile)
          {
            if (!subEntryPath.dirName.exists)
            {
              rmdirRecurse(subEntryPath.dirName);
            }

            entryPath.copy(subEntryPath);
          }
        }
      }
      else if (path.source.isFile && path.destination.isFile)
      {
        if (!path.destination.dirName.exists)
        {
          rmdirRecurse(path.destination.dirName);
        }

        path.source.copy(path.destination);
      }
    }
  }
}
