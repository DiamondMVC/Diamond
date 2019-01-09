/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.markdown.part;

import diamond.markdown.type;

/// Wrapper around a markdown part.
final class MarkdownPart
{
  private:
  /// The type.
  MarkdownType _type;
  /// The content.
  string _content;
  /// The volume.
  size_t _volume;
  /// The metadata.
  string[string] _metadata;

  public:
  final:
  /**
  * Creates a new markdown part.
  * Params:
  *   type = The type of the markdown part.
  */
  this(MarkdownType type)
  {
    _type = type;
  }

  @property
  {
    /// Gets the type of the markdown part.
    MarkdownType type() { return _type; }

    /// Gets the content of the markdown part.
    string content() { return _content; }

    /// Gets the volume of the markdown part.
    size_t volume() { return _volume; }

    package(diamond.markdown)
    {
      /// Sets the type of the markdown part.
      void type(MarkdownType newType)
      {
        _type = newType;
      }

      /// Sets the content of the markdown part.
      void content(string newContent)
      {
        _content = newContent;
      }

      /// Sets the volume of the markdown part.
      void volume(size_t newVolume)
      {
        _volume = newVolume;
      }
    }
  }

  /**
  * Gets a metadata value.
  * Params:
  *   key = The key of the metadata to get.
  * Returns:
  *   The metadata value if existing, null otherwise.
  */
  string getMetadata(string key)
  {
    return _metadata.get(key, null);
  }

  /**
  * Sets a metadata.
  * Params:
  *   key =   The key of the metadata.
  *   value = The value of the metadata.
  */
  package(diamond.markdown) void setMetadata(string key, string value)
  {
    _metadata[key] = value;
  }
}
