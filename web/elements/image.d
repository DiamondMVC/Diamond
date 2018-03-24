/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.elements.image;

import diamond.web.elements.element;

/// Wrapper around a image.
final class Image : Element
{
  private:
  /// The source.
  string _source;
  /// The alt text.
  string _alt;

  public:
  final:
  /// Creates a new image.
  this()
  {
    super("img");

    alt = "";
  }

  /**
  * Creates a new image.
  * Params:
  *   source = The source of the image.
  */
  this(string source)
  {
    this();

    this.source = source;
  }

  @property
  {
    /// Gets the source.
    string source() { return _source; }

    /// Sets the source.
    void source(string newSource)
    {
      _source = newSource;
      addAttribute("src", _source);
    }

    /// Gets the alt text.
    string alt() { return _alt; }

    /// Sets the alt text.
    void alt(string newAlt)
    {
      _alt = newAlt;
    }
  }
}
