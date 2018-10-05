/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.dom.domparsersettings;

import std.string : toLower;

import diamond.core.collections;

/// Wrapper around dom parser settings.
abstract class DomParserSettings
{
  private:
  /// Boolean determining whether the parser is strict or not.
  bool _strictParsing;
  /// HashSet of tags that can has flexible content, such as the HTML <script> tag.
  HashSet!string _flexibleTags;

  protected
  {
    /**
    * Creates a new dom parser setting.
    * Params:
    *   strictParsing =  Boolean determining whether the parser is strict or not.
    *   flexibleTags =   An array of tags that can has flexible content, such as the HTML <script> tag.
    */
    this
    (
      bool strictParsing,
      string[] flexibleTags
    ) @safe
    {
      _strictParsing = strictParsing;

      _flexibleTags = new HashSet!string;

      if (flexibleTags && flexibleTags.length)
      {
        foreach (tag; flexibleTags)
        {
          _flexibleTags.add(tag.toLower);
        }
      }
    }
  }

  public:
  final:
  @property
  {
    /// Gets a boolean determining whether the parser is strict or not.
    bool strictParsing() @safe { return _strictParsing; }
  }

  /**
  * Checks whether a specific tag is flexible or not.
  * Params:
  *   tagName = The name of the tag to validate.
  * Returns:
  *   True if the tag is flexible, false otherwise.
  */
  bool isFlexibleTag(string tagName) @safe
  {
    return _flexibleTags.has(tagName.toLower);
  }
}
