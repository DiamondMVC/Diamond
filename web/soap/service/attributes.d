/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.attributes;

/// Wrapper around a soap action.
struct SoapAction
{
  /// The url of the soap action.
  string url;
}

/// Wrapper around a soap operation.
struct SoapOperation
{
  /// The url of the soap operation;
  string url;
}
