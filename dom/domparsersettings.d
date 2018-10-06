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
  /// Boolean determining whether the parser allows self-closing tags or not.
  bool _allowSelfClosingTags;
  /// HashSet of self-closing tags.
  HashSet!string _selfClosingTags;
  /// HashSet of standard tags.
  HashSet!string _standardTags;

  protected
  {
    /**
    * Creates a new dom parser setting.
    * Params:
    *   strictParsing =         Boolean determining whether the parser is strict or not.
    *   flexibleTags =          An array of tags that can has flexible content, such as the HTML <script> tag.
    *   allowSelfClosingTags =  Boolean determining whether the parser allows self-closing tags or not.
    *   selfClosingTags =       An array of tags that can be self-closed.
    *   standardTags =          An array of standard tags. These are only relevant if self-closing tags are allowed.
    */
    this
    (
      bool strictParsing,
      string[] flexibleTags,
      bool allowSelfClosingTags,
      string[] selfClosingTags,
      string[] standardTags
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

      _allowSelfClosingTags = allowSelfClosingTags;

      if (_allowSelfClosingTags)
      {
        _selfClosingTags = new HashSet!string;

        if (selfClosingTags && selfClosingTags.length)
        {
          foreach (tag; selfClosingTags)
          {
            _selfClosingTags.add(tag.toLower);
          }
        }

        _standardTags = new HashSet!string;

        if (standardTags && standardTags.length)
        {
          foreach (tag; standardTags)
          {
            _standardTags.add(tag.toLower);
          }
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

    /// Gets a boolean determining whether the parser allwos self-closing tags or not.
    bool allowSelfClosingTags() @safe { return _allowSelfClosingTags; }
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

  /**
  * Checks whether a specific tag is self-closing or not.
  * Params:
  *   tagName = The name of the tag to validate.
  * Returns:
  *   True if the tag is self-closing, false otherwise.
  */
  bool isSelfClosingTag(string tagName) @safe
  {
    return _selfClosingTags.has(tagName.toLower);
  }

  /**
  * Checks whether a specific tag is standard or not.
  * Params:
  *   tagName = The name of the tag to validate.
  * Returns:
  *   True if the tag is standard, false otherwise.
  */
  bool isStandardTag(string tagName) @safe
  {
    return _standardTags.has(tagName.toLower);
  }
}
