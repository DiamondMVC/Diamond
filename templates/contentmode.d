/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.templates.contentmode;

/// Enumeration of content modes.
enum ContentMode
{
  /// Will append content to the view.
  appendContent,
  /// Will append content to the view with a placeholder
  appendContentPlaceholder,
  /// Will mixin the content as D code.
  mixinContent,
  /// Will parse the content as meta and handle it as such
  metaContent,
  /// Will discard the content.
  discardContent
}
