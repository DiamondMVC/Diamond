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
* **logToFile(LogType logType, string file, void delegate(LogResult) callback = null);**
* **logToDatabase(LogType logType, string table, void delegate(LogResult) callback = null, string connectionString = null);**

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

-- MORE COMING SOON -- GOTTA EAT SO I WILL FINISH IT AFTER LOL :)
