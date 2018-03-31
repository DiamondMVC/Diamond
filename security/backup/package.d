/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.backup;

public
{
  import diamond.security.backup.backupservice;
  import diamond.security.backup.backuppath;
  import diamond.security.backup.filebackup;
}

/// Collection of backup services.
private static __gshared BackupService[] _backupServices;

/**
* Adds a backup service.
* Params:
*   service = The backup service to add.
*/
void addBackupService(BackupService service)
{
  _backupServices ~= service;
}

/// Executes the backup services.
package(diamond) void executeBackup()
{
  if (!_backupServices)
  {
    return;
  }

  import diamond.tasks;

  foreach (service; _backupServices)
  {
    executeTask
    ({
      while (true)
      {
        sleep(service.time.minutes);
        service.backup();
      }
    });
  }
}
