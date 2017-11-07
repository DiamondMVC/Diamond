/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.logging;

import diamond.core.apptype;

static if (loggingEnabled)
{
  import diamond.http;

  /// Alias for a logging delegate.
  private alias LogDelegate = void delegate(LogResult);

  /// Wrapper around a log result.
  final class LogResult
  {
    private:
    /// Unique token for the log.
    string _logToken;
    /// The log type.
    LogType _logType;
    /// The name of the application.
    string _applicationName;
    /// The ip address.
    string _ipAddress;
    /// The request method.
    HttpMethod _requestMethod;
    /// The request headers.
    string _requestHeaders;
    /// The request body.
    string _requestBody;
    /// The request url.
    string _requestUrl;
    /// The response headers.
    string _responseHeaders;
    /// The response body.
    string _responseBody;
    /// The response status code.
    HttpStatus _responseStatusCode;
    /// The message.
    string _message;
    /// The auth token.
    string _authToken;

    /**
    * Creates a new log result.
    * Params:
    *   logToken =          The token of the log result.
    *   logType =           The type of the log.
    *   applicationName =   The name of the application.
    *   ipAddress =         The ip address.
    *   requestMethod =     The request method.
    *   requestHeaders =    The request headers.
    *   requestBody =       The request body.
    *   requestUrl =        The request url.
    *   responseHeaders =   The response headers.
    *   responseBody =      The response body.
    *   responseStatusCode  The response status code.
    *   message =           The message.
    */
    this
    (
      string logToken,
      LogType logType,
      string applicationName,
      string ipAddress,
      HttpMethod requestMethod,
      string requestHeaders,
      string requestBody,
      string requestUrl,
      string responseHeaders,
      string responseBody,
      HttpStatus responseStatusCode,
      string message,
      string authToken
    )
    {
      _logToken = logToken;
      _logType = logType;
      _applicationName = applicationName;
      _ipAddress = ipAddress;
      _requestMethod = requestMethod;
      _requestHeaders = requestHeaders;
      _requestBody = requestBody;
      _requestUrl = requestUrl;
      _responseHeaders = responseHeaders;
      _responseBody = responseBody;
      _responseStatusCode = responseStatusCode;
      _message = message;
      _authToken = authToken;
    }

    public:
    final:
    @property
    {
      /// Gets the unique token for the log result.
      string logToken() { return _logToken; }

      /// Gets the type of the log.
      LogType logType() { return _logType; }

      /// Gets the name of the application.
      string applicationName() { return _applicationName; }

      /// Gets the ip address.
      string ipAddress() { return _ipAddress; }

      /// Gets the request method.
      HttpMethod requestMethod() { return _requestMethod; }

      /// Gets the request headers.
      string requestHeaders() { return _requestHeaders; }

      /// Gets the request body.
      string requestBody() { return _requestBody; }

      /// Gets the request url.
      string requestUrl() { return _requestUrl; }

      /// Gets the response headers.
      string responseHeaders() { return _responseHeaders; }

      /// Gets the response body.
      string responseBody() { return _responseBody; }

      /// Gets the response status code.
      HttpStatus responseStatusCode() { return _responseStatusCode; }

      /// Gets the message.
      string message() { return _message; }

      /// Gets the auth token.
      string authToken() { return _authToken; }
    }

    /// Gets the log result as a loggable string, fit for ex. file-logs.
    override string toString()
    {
      import std.datetime : Clock;
      import std.string : format;

      return `-------------------
--------- %s ----------
-------------------
Token: %s
LogType: %s
App: %s,
IPAddress: %s
Method: %s
Status: %s
ReqUrl: %s
AuthToken: %s
ReqHeaders:
-------------------
%s
-------------------
ReqBody:
-------------------
%s
-------------------
ResHeaders:
-------------------
%s
-------------------
ResBody:
-------------------
%s
-------------------
Message:
-------------------
%s
-------------------
-------------------`.format
      (
        Clock.currTime().toString(),
        logToken, logType, applicationName,
        ipAddress, requestMethod,
        responseStatusCode, requestUrl,
        authToken,
        requestHeaders, requestBody,
        responseHeaders, responseBody,
        message
      );
    }
  }

  package(diamond)
  {
    /// Collection of loggers.
    __gshared LogDelegate[][LogType] _loggers;

    /**
    * Executes a specific type of logger.
    * Params:
    *   logType =   The type of logger to execute.
    *   client =    The client to log.
    *   message =   The message associated with the log.
    */
    void executeLog
    (
      LogType logType,
      HttpClient client,
      lazy string message = null
    )
    {
      auto loggers = _loggers.get(logType, null);

      if (!loggers)
      {
        return;
      }

      import std.algorithm : canFind;
      import std.string : format;
      import vibe.stream.operations : readAllUTF8;
      import diamond.core.webconfig;
      import diamond.core.senc;

      string requestHeaders;

      foreach (key,value; client.headers.byKeyValue())
      {
        requestHeaders ~= "%s: %s\r\n".format(key, value);
      }

      string responseHeaders;

      foreach (key,value; client.rawResponse.headers)
      {
        responseHeaders ~= "%s: %s\r\n".format(key, value);
      }

      import std.uuid : randomUUID, sha1UUID;
      import std.random : Xorshift192, unpredictableSeed;

      Xorshift192 gen;
      gen.seed(unpredictableSeed);

      string logToken =
        randomUUID(gen).toString() ~ "-" ~ sha1UUID(client.session.id).toString();

      auto statusCode = client.statusCode;

      if (logType == LogType.error)
      {
        statusCode = HttpStatus.internalServerError;
      }
      else if (logType == LogType.notFound)
      {
        statusCode = HttpStatus.notFound;
      }
      else if (statusCode == HttpStatus.continue_)
      {
        statusCode = HttpStatus.ok;
      }

      auto logResult = new LogResult
      (
        logToken,
        logType,
        webConfig.name,
        client.ipAddress,
        client.method,
        requestHeaders ? requestHeaders : "",
        client.requestStream.readAllUTF8(),
        client.fullUrl.toString(),
        responseHeaders,
        client.rawResponse.contentType.canFind("text") ?
          cast(string)client.getBody() : SENC.encode(client.getBody()),
        statusCode,
        message ? message : "",
        client.cookies.hasAuthCookie() ? client.cookies.getAuthCookie() : ""
      );

      foreach (logger; loggers)
      {
        logger(logResult);
      }
    }
  }

  /// Enumeration of log types.
  enum LogType
  {
    /// An error logger.
    error,

    /// A not-found logger.
    notFound,

    /// A logger for pre-request handling.
    before,

    /// A logger for post-request handling.
    after,

    /// A logger for static files.
    staticFile
  }

  /**
  * Creates a logger.
  * Params:
  *   logType = The type of the logger.
  *   logger =  The logger handler.
  */
  void log(LogType logType, void delegate(LogResult) logger)
  {
    _loggers[logType] ~= logger;
  }

  /**
  * Creates a file logger.
  * Params:
  *   logType =   The type of the logger.
  *   file =      The file append logs to.
  *   callback =  An optional callback after the log has been written.
  */
  void logToFile(LogType logType, string file, void delegate(LogResult) callback = null)
  {
    log(logType,
    (result)
    {
      import std.file : append;
      append(file, result.toString());

      if (callback !is null)
      {
        callback(result);
      }
    });
  }

  /**
  * Creates a database logger.
  * The table must implement the following columns:
  * logToken (VARCHAR)
  * logType (ENUM ("error", "notFound", "after", "before", "staticFile"))
  * applicationName (VARCHAR)
  * authToken (VARCHAR)
  * requestIPAddress (VARCHAR)
  * requestMethod (VARCHAR)
  * requestHeaders (TEXT)
  * requestBody (TEXT)
  * requestUrl (VARCHAR)
  * responseHeaders (TEXT)
  * responseBody (TEXT)
  * responseStatusCode (INT)
  * message (TEXT)
  * timestamp (DATETIME)
  * Params:
  *   logType =          The type of the logger.
  *   table =            The table to log entries to.
  *   callback =         An optional callback after the log has been written.
  *   connectionString = A connection string to associate with the logging. If none is specified then it will use the default connection string.
  */
  void logToDatabase(LogType logType, string table, void delegate(LogResult) callback = null, string connectionString = null)
  {
    log(logType,
    (result)
    {
      import std.string : format;

      auto sql = "
      INSERT INTO `%s`
      (
        `logToken`,
        `logType`,
        `applicationName`,
        `authToken`,
        `requestIPAddress`, `requestMethod`, `requestHeaders`,
        `requestBody`, `requestUrl`,
        `responseHeaders`, `responseBody`, `responseStatusCode`,
        `message`,
        `timestamp`
      )
      VALUES
      (
        @logToken,
        @logType,
        @applicationName,
        @authToken,
        @requestIPAddress, @requestMethod, @requestHeaders,
        @requestBody, @requestUrl,
        @responseHeaders, @responseBody, @responseStatusCode,
        @message,
        NOW()
      )".format(table);

      import std.conv : to;
      import diamond.database;

      auto params = getParams();
      params["logToken"] = result.logToken;
      params["logType"] = to!string(result.logType);
      params["applicationName"] = result.applicationName;
      params["authToken"] = result.authToken;
      params["requestIPAddress"] = result.ipAddress;
      params["requestMethod"] = to!string(result.requestMethod);
      params["requestHeaders"] = result.requestHeaders;
      params["requestBody"] = result.requestBody;
      params["requestUrl"] = result.requestUrl;
      params["responseHeaders"] = result.responseHeaders;
      params["responseBody"] = result.responseBody;
      params["responseStatusCode"] = cast(int)result.responseStatusCode;
      params["message"] = result.message;

      MySql.execute(sql, params, connectionString);

      if (callback !is null)
      {
        callback(result);
      }
    });
  }
}
