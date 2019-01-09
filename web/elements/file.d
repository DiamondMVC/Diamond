/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.file;

import diamond.web.elements.input;

/// Wrapper around a file input.
final class File : Input
{
  private:
  /// Boolean determining whether the input allows multiple files or not.
  bool _multiple;

  public:
  final:
  /// Creates a new file input.
  this()
  {
    super();

    addAttribute("type", "file");
  }

  @property
  {
    /// Gets a boolean determining whether the input allows multiple files or not.
    bool multiple() { return _multiple; }

    /// Sets a boolean determining whether the input allows multiple files or not.
    void multiplate(bool allowMultiple)
    {
      _multiple = allowMultiple;

      addAttribute("multiple", null);
    }
  }
}
