/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.date;

import diamond.web.elements.input;

/// Wrapper around a date input.
final class Date : Input
{
  private:
  /// The min date.
  string _minDate;
  /// The max date.
  string _maxDate;

  public:
  final:
  /// Creates a new date input.
  this()
  {
    super();

    addAttribute("type", "date");
  }

  /**
  * Creates a new date input.
  * Params:
  *   date = The date of the input.
  */
  this(string date)
  {
    this();

    super.value = date;
  }

  @property
  {
    /// Gets the min date.
    string minDate() { return _minDate; }

    /// Sets the min date.
    void minDate(string newMinDate)
    {
      _minDate = newMinDate;

      addAttribute("min", _minDate);
    }

    /// Gets the max date.
    string maxDate() { return _maxDate; }

    /// Sets the min date.
    void maxDate(string newMaxDate)
    {
      _maxDate = newMaxDate;

      addAttribute("max", _maxDate);
    }
  }
}
