/**
* Copyright © DiamondMVC 2019
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

    import diamond.http.client;

    protected:
    /// Creates a new instance of the web settings.
    this() { }

    public:
    /// Function invoked when the application starts.
    abstract void onApplicationStart();

    /*
    * Function invoked before a request has been processed.
    * Params:
    *   client =  The client.
    * Returns:
    *   True if the request can be processed, false otherwise.
    */
    abstract bool onBeforeRequest(HttpClient client);

    /*
    * Function invoked after a request has been processed successfully.
    * Params:
    *   client =  The client.
    */
    abstract void onAfterRequest(HttpClient client);

    /*
    * Function invoked when an error has been encountered.
    * Params:
    *   thrownError = The error encountered.
    *   request =     The request.
    *   response =    The response.
    *   error =       The error information (this can be null)
    */
    abstract void onHttpError
    (
      Throwable thrownError, HTTPServerRequest request,
      HTTPServerResponse response, HTTPServerErrorInfo error
    );

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
    *   client =  The client.
    */
    abstract void onStaticFile(HttpClient client);
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
