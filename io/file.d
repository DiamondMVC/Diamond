/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.io.file;

import std.file;
import std.string : toLower, strip, stripLeft, stripRight;
import std.algorithm : startsWith;

private
{
  alias dwrite = std.file.write;
  alias dappend = std.file.append;
  alias dread = std.file.read;
  alias dreadText = std.file.readText;
  alias dexists = std.file.exists;
  alias dremove = std.file.remove;
}

import diamond.errors;

/// Enumeration of file access security.
enum FileAccessSecurity
{
  /// Allows system path access.
  systemAccess,
  /// Allows web-root path access only.
  webRootAccess,
  /// Allows static file route path access only.
  staticFileAccess,
  /// Allows white-listed path access only.
  whiteListAccess
}

/// Collection of white-listed paths.
private __gshared string[] _whiteList;

/**
* Adds a path to the white-list.
* Params:
*   path = The path to add.
*/
void addPathToWhiteList(string path)
{
  _whiteList ~= path;
}

/// The root path of the web application.
private string _webRootPath;

@property
{
  /// Gets the root path of the web application.
  string webRootPath()
  {
    if (!_webRootPath)
    {
      import std.algorithm : startsWith;
      import std.file : thisExePath;
      import std.path : absolutePath, dirName;

      _webRootPath = absolutePath(dirName(thisExePath));
    }

    return _webRootPath;
  }
}

/**
* Transform a path into the correct access security path and also validates it.
* Params:
*   security = The access security.
*   path =     The path to transform and validate.
* Returns:
*   Returns the transformed path.
*/
private string transformPath(FileAccessSecurity security, string path)
{
  static const char backSlash = cast(char)0x5c;

  enforce(path, "Cannot transform an empty path.");

  path = path.strip();

  if (security != FileAccessSecurity.systemAccess && security != FileAccessSecurity.whiteListAccess)
  {
    version (Windows)
    {
      if (path[0] != '/' && path[0] != backSlash)
      {
        path = "/" ~ path;
      }
    }
    else
    {
      if (path[0] != '/')
      {
        path = "/" ~ path;
      }
    }
  }

  switch (security)
  {
    case FileAccessSecurity.webRootAccess:
    {
      if (!path.toLower().startsWith(webRootPath.toLower()))
      {
        path = webRootPath ~ path;
      }
      break;
    }

    case FileAccessSecurity.staticFileAccess:
    {
      import diamond.core.webconfig;

      bool isStaticPath;

      foreach (staticFileRoute; webConfig.staticFileRoutes)
      {
        if (path.startsWith(staticFileRoute.strip().stripLeft([backSlash, '/'])))
        {
          isStaticPath = true;
        }
      }

      if (!isStaticPath)
      {
        throw new FileSecurityException("The path is not a static file path");
      }

      path = webRootPath ~ path;
      break;
    }

    case FileAccessSecurity.whiteListAccess:
    {
      bool isWhiteListPath;

      if (_whiteList)
      {
        foreach (whiteListPath; _whiteList)
        {
          if (path.startsWith(whiteListPath.strip().stripLeft([backSlash, '/'])))
          {
            isWhiteListPath = true;
          }
        }
      }

      if (!isWhiteListPath)
      {
        throw new FileSecurityException("The path is not white-listed");
      }
      break;
    }

    default: break;
  }

  return path;
}


/**
* Writes to a file securely.
* Params:
*   security = The file security access.
*   file =     The file to write.
*   content =  The content of the file.
*/
void write(FileAccessSecurity security, string file, string content)
{
  auto path = transformPath(security, file);

  dwrite(path, content);
}

/**
* Appends to a file securely.
* Params:
*   security = The file security access.
*   file =     The file to append.
*   content =  The content of the file.
*/
void append(FileAccessSecurity security, string file, string content)
{
  auto path = transformPath(security, file);

  dappend(path, content);
}

/**
* Reads the content of a file securely.
* Params:
*   security = The file security access.
*   file =     The file to read.
* Returns:
*   Returns the content of the file.
*/
string readText(FileAccessSecurity security, string file)
{
  auto path = transformPath(security, file);

  return dreadText(file);
}

/**
* Reads the buffer of a file securely.
* Params:
*   security = The file security access.
*   file =     The file to read.
* Returns:
*   Returns the buffer of the file.
*/
ubyte[] readBuffer(FileAccessSecurity security, string file)
{
  auto path = transformPath(security, file);

  return cast(ubyte[])dread(file);
}

/**
* Checks whether a file or directory exists securely.
* Params:
*   security = The path access security.
*   path =     The path to validate for existence.
*/
bool exists(FileAccessSecurity security, string path)
{
  path = transformPath(security, path);

  return dexists(path);
}

/**
* Removes a file securely.
* Params:
*   security = The files access security.
*   file =     The file to remove.
*/
void remove(FileAccessSecurity security, string file)
{
  file = transformPath(security, file);

  dremove(file);
}

/**
* Makes a directory securely.
* Params:
*   security = The directory security access.
*   path =     The path of the directory to make.
*/
void makeDir(FileAccessSecurity security, string path)
{
  path = transformPath(security, path);

  mkdir(path);
}

/**
* Removes a directory securely.
* Params:
*   security = The directory security access.
*   path =     The path of the directory to remove.
*/
void removeDir(FileAccessSecurity security, string path)
{
  path = transformPath(security, path);

  rmdirRecurse(path);
}
