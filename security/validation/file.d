/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.file;

/// Alias to a file validator delegate.
public alias FileValidator = bool delegate(ubyte[]);

/// Collection of custom file validators.
private static __gshared FileValidator[string] _validators;

/**
* Adds a custom file validator.
* Params:
*   extension = The file extension to validate.
*   handler =   The handler that validates the file.
*/
void addCustomFileValidator(string extension, FileValidator handler)
{
  _validators[extension] = handler;
}

/**
* Checks whether specified file data matches an extension.
* Currently this supports ".jpg, .jpeg, .gif, .png, .pdf"
* Params:
*   extension = The extension of the file.
*   data =      The data to validate.
* Returns:
*   True if the data is valid for the extension given, false otherwise. Unhandled extensions returns true.
*/
bool isValidFile(string extension, ubyte[] data)
{
  import diamond.errors.checks;

  enforce(data && data.length, "No data to validate.");

  auto customValidator = _validators.get(extension, null);

  if (customValidator)
  {
    return customValidator(data);
  }

  switch (extension)
  {
    case ".jpg":
    case ".jpeg":
    {
      return data.length > 4 &&
             data[0] == 0xff && data[1] == 0xd8 &&
             data[$-2] == 0xff && data[$-1] == 0xd9;
    }

    case ".gif":
    {
      if (data.length < 6)
      {
        return false;
      }

      auto start = cast(string)data[0 .. 6];

      return start == "GIF87a" || start == "GIF89a";
    }

    case ".png":
    {
      if (data.length < 8)
      {
        return false;
      }

      auto png = data[1 .. 4];

      if (png != "PNG")
      {
        return false;
      }

      return data[0] == 0x89 &&
             data[4] == 0x0d && data[5] == 0x0a &&
             data[6] == 0x1a &&
             data[7] == 0x0a;
    }

    case ".pdf":
    {
      return data.length > 5 &&
             data[0] == 0x25 &&
             data[1] == 0x50 && data[2] == 0x44 && data[3] == 0x46 &&
             data[4] == 0x2d;
    }


    default: return true;
  }
}
