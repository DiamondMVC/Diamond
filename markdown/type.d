/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.markdown.type;

/// Enumeration of markdown types.
enum MarkdownType
{
  /// Plain content.
  content,
  /// New-line.
  newline,
  /// The start of content wrapping elements.
  contentWrapStart,
  /// The end of content wrapping elements.
  contentWrapEnd,
  /// Header.
  header,
  /// Unordered list-start.
  ulistStart,
  /// Unordered list-end.
  ulistEnd,
  /// Ordered list-start.
  olistStart,
  /// Ordered list-end.
  olistEnd,
  /// List-item start.
  listItemStart,
  /// List-item end.
  listItemEnd,
  /// Link.
  link,
  /// Image.
  image,
  /// Code-block start.
  codeStart,
  /// Code-block end.
  codeEnd,
  /// Block-quote start
  blockQuoteStart,
  /// Block-quote end
  blockQuoteEnd,
  /// Table start
  tableStart,
  /// Table-row start
  tableRowStart,
  /// Table-head start
  tableHeadStart,
  /// Table-cell start
  tableCellStart,
  /// Table end
  tableEnd,
  /// Table-row end
  tableRowEnd,
  /// Table-head end
  tableHeadEnd,
  /// Table-cell end
  tableCellEnd,
  /// Horizontal
  horizontal,
  // Inline-code
  inlineCode
}
