/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.extensions.extensiontype;

/// Enumeration of extension types.
enum ExtensionType
{
  /// An extension used to handle application start.
  applicationStart = "ApplicationStart",

  /// An extension used to add custom grammars.
  customGrammar = "CustomGrammar",

  /// An extension used to parse a view part.
  partParser = "PartParser",

  /// An extension used to extend the general view class.
  viewExtension = "ViewExtension",

  /// An extension used to extend the general view constructor.
  viewCtorExtension = "ViewCtorExtension",

  /// An extension used to extend the general controller class.
  controllerExtension = "ControllerExtension",

  /// An extension to handle the http settings of Diamond.
  httpSettings = "HttpSettings",

  /// An extension used to handle http requests.
  httpRequest = "HttpRequest",

  /// An extension used to handle errors.
  handleError = "HandleError",

  /// An extension used to handle static file requests.
  staticFileExtension = "StaticFiles"
}
