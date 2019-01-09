/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.backup.backuppath;

/// Wrapper around a backup path.
struct BackupPath
{
  /// The source path.
  string source;
  /// The destination path.
  string destination;
}
