[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Logging

Diamond has build-in logging facilities that can be used to create custom logging mechanisms or logging directly to a file or a MySql database.

There are 5 types of logging that can be done with Diamond applications.

### Error Logging

Error logging can be done with **LogType.error**, which will log all errors caused by requests; this includes exceptions etc.

### Not-found Logging

Not-found logging can be done with **LogType.notFound**, which will log all requests to resources that weren't found.

### Static File Logging

Static file logging can be done with **LogType.staticFile**, which will log all requests to static file resources.

### Pre-Request Logging

Pre-request logging can be done with **LogType.before**, which will log all requests before they have been handled.

### Post-Request Logging

Post-request logging can be done with **LogType.after**, which will log all requests after they have been handled successfully.

## Setting up logging

### General

To setup logging you must compile with the version **Diamond_Logging*, otherwise logging facilities cannot be used.

### Log Registration

You must register your logging facilities. It's recommended to register your logging facilities in the **onApplicationStart()** function, which can be found in your websettings module.

All logging facility can be found in the module **diamond.core.logging**.

To register a logging facility you simply call one of the following functions:

* **log(LogType logType, void delegate(LogResult) logger,lazy string messsage = null);**
  * Used for custom loggers
* **logToFile(LogType logType, string file, void delegate(LogResult) callback = null);**
  * Used for file logging
* **logToDatabase(LogType logType, string table, void delegate(LogResult) callback = null, string connectionString = null);**
  * Used for database logging

**LogResult** is a class and from that you can get all the information about the log.

*LogResult*:

```
@property:

string logToken();
LogType logType();
string applicationName();
string ipAddress();
HttpMethod requestMethod();
string requestHeaders();
string requestBody();
string requestUrl();
string responseHeaders();
string responseBody();
HttpStatus responseStatusCode();
string message();
string authToken();
```

You can also call **.toString()** for a log-result which will yield a string equivalent to all its information, which is suited for file logging etc.


## Custom Loggers

Custom loggers are useful if you want to log in other ways than the default ways given. Ex. if you want to log to another type of database, rather than MySql.

Example:

```
log(LogType.error, (result)
{
    logToMSSQLDatabase(result); // Custom implementation to log to a MSSQL database.
});
```

## File Loggers

File loggers are useful to create quick local logs. They shouldn't be used in production. For production it's recommended to use database logging.

Example:

```
logToFile(LogType.error, "errors.log");

...

logToFile(LogType.error, "errors.log",
(result)
{
    import diamond.core.io;
    print(result.toString()); // Prints the log out to the console as well ...
});
```

## Database Loggers

Database logging is the recommended way of logging in Diamond, because it's the safest way to store logs and searching the log's data is much easier when you can query it by sql quries etc.

Example:

```
logToDatabase(LogType.error, "logs");

...

logToDatabase(LogType.error, "logs",
(result)
{
     import diamond.core.io;
     
     print("Logged '%s' to the database.", result.logToken);
});
```

When logging to the database you must have a table structure like below:

```
  logToken (VARCHAR)
  logType (ENUM ("error", "notFound", "after", "before", "staticFile"))
  applicationName (VARCHAR)
  authToken (VARCHAR)
  requestIPAddress (VARCHAR)
  requestMethod (VARCHAR)
  requestHeaders (TEXT)
  requestBody (TEXT)
  requestUrl (VARCHAR)
  responseHeaders (TEXT)
  responseBody (TEXT)
  responseStatusCode (INT)
  message (TEXT)
  timestamp (DATETIME)
```

If you want to use another structure you must create a custom logger.

You can use the implementation of **logToDatabase()** as reference:

```
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
```
