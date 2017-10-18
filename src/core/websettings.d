/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.websettings;

import diamond.core.apptype;

static if (isWeb)
{
  /// The web settings for the application.
  private __gshared WebSettings _webSettings;

  /// The abstract wrapper for web settings.
  abstract class WebSettings
  {
    import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerErrorInfo;

    protected:
    /// Creates a new instance of the web settings.
    this() { }

    public:
    /*
    * Function invoked before a request has been processed.
    * Params:
    *   request =  The request to be processed.
    *   response = The response.
    * Returns:
    *   True if the request can be processed, false otherwise.
    */
    abstract bool onBeforeRequest(HTTPServerRequest request, HTTPServerResponse response);

    /*
    * Function invoked after a request has been processed successfully.
    * Params:
    *   request =  The request that were processed.
    *   response = The response.
    */
    abstract void onAfterRequest(HTTPServerRequest request, HTTPServerResponse response);

    /*
    * Function invoked when an error has been encountered.
    * Params:
    *   thrownError = The error encountered.
    *   request =     The request.
    *   response =    The response.
    *   error =       The error information (this can be null)
    */
    abstract void onHttpError(Throwable thrownError, HTTPServerRequest request,
      HTTPServerResponse response, HTTPServerErrorInfo error);

    /*
    * Function invoked when a page or an action cannot be found.
    * Use request.path to get the path that was attempted to be accessed
    * Params:
    *   request =  The request.
    *   response = The response.
    */
    abstract void onNotFound(HTTPServerRequest request, HTTPServerResponse response);

    /*
    * Function invoked before a static file is processed.
    * Params:
    *   request =  The request.
    *   response = The response.
    */
    abstract void onStaticFile(HTTPServerRequest request, HTTPServerResponse response);
  }

  @property
  {
    /// Gets the web settings.
    WebSettings webSettings() { return _webSettings; }

    /// Sets the web settings.
    void webSettings(WebSettings newWebSettings)
    {
      _webSettings = newWebSettings;
    }
  }
}
