/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.email;

import diamond.web.elements.input;

/// Wrapper around a email input.
final class Email : Input
{
  private:
  /// Boolean determining whether the input allows multiple emails or not.
  bool _multiple;

  public:
  final:
  /// Creates a new email input.
  this()
  {
    super();

    addAttribute("type", "email");
  }

  @property
  {
    /// Gets a boolean determining whether the input allows multiple emails or not.
    bool multiple() { return _multiple; }

    /// Sets a boolean determining whether the input allows multiple emails or not.
    void multiplate(bool allowMultiple)
    {
      _multiple = allowMultiple;

      addAttribute("multiple", null);
    }

    /// Gets a boolean determining whether the input allows an empty value.
    bool allowsEmptyValue()
    {
      return _multiple;
    }
  }
}
