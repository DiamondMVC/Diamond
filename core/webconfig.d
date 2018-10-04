/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.webconfig;

import diamond.core.apptype;

static if (isWeb)
{
  import vibe.data.serialization : optional;

  /// Web configurations.
  final class WebConfig
  {
    /// The name of the web application.
    string name;
    /// The routes that are mapped to static files.
    @optional string[] staticFileRoutes;
    /// The paths to white-list for file-access/directory-access.
    @optional string[] whiteListPaths;
    /// A list of hosts that the server accepts.
    @optional string[] hostWhiteList;
    /// The route that's mapped to the home page.
    string homeRoute;
    /// Boolean determining whether views can be accessed by their file name.
    @optional bool allowFileRoute;
    /// An array of addresses the web application is accessible by.
    WebAddress[] addresses;
    /// The default headers the web application uses.
    WebHeaders defaultHeaders;
    /// Boolean determining whether the access log should be redirected to the console.
    @optional bool accessLogToConsole;
    /// The time sessions are stored in memory.
    @optional long sessionAliveTime;
    // A special string representation that splits the root routes when checking ACL.
    @optional string specialRouteSplitter;
    /// Boolean determnining whether views can be cached or not.
    @optional bool shouldCacheViews;
    /// An array of global restricted ip addresses.
    @optional string[] globalRestrictedIPs;
    /// An array of restricted ip addresses.
    @optional string[] restrictedIPs;
    /// A collection of db connection configurations.
    @optional WebDbConnections dbConnections;
    /// Tn associative array of specialized routes.
    @optional WebSpecialRoute[string] specializedRoutes;
    /// A static web-page to display for maintenance. When specified the website will automatically be set to maintenance-mode.
    @optional string maintenance;
    /// An array of ips that can still access the site during maintenance.
    @optional string[] maintenanceWhiteList;
    /// Boolean determining whethere there's only one view to use for routing. The view must be named __view.dd
    @optional bool viewOnly;
    /// Configurations for mongo db.
    @optional WebMongoDb mongoDb;
    /// Configuration to disable privacy logging. When set to true, personal information etc. will be stored in the logging.
    @optional bool disablePrivacyLogging;
    /// Configuration for the ssl certificate file.
    @optional string sslCertificateFile;
    /// Configuration for the ssl private key file.
    @optional string sslPrivateKeyFile;
    /// The http header that contains the client's ip. Useful when using reverse proxies.
    @optional string ipHeader;
    /// Collection of webservices.
    @optional WebService[] webservices;
    /// An associative array of custom configurations;
    @optional string[string] customConfig;
    /// String of an url to redirect all connections that aren't ssl to.
    @optional string forceSSLUrl;
    /// An array of routes that shouldn't have logging for headers.
    @optional string[] disableHeaderLoggingRoutes;
    /// An associative array of mapped auth keys.
    @optional string[string] mappedAuthKeys;
  }

  /// Wrapper around a webservice.
  final class WebService
  {
    /// The name of the webservice.
    string name;

    /// The wsdl of the webservice.
    string wsdl;

    /// The module name of the webservice.
    string moduleName;
  }

  /// A web address.
  final class WebAddress
  {
    /// An array of ip addresses that the web address is bound to.
    string[] ipAddresses;
    /// The port the web address is bound to.
    ushort port;
  }

  /// Web headers.
  final class WebHeaders
  {
    /// Headers used for general purpose.
    string[string] general;
    /// Headers used for static files.
    string[string] staticFiles;
    /// Headers used for 404 responses.
    string[string] notFound;
    /// Headers used for error responses.
    string[string] error;
  }

  /// Wrapper around db connection configurations.
  final class WebDbConnections
  {
    @optional WebDbConnectionConfig[string] mysql;
    @optional WebDbConnectionConfig[string] mssql;
    @optional WebDbConnectionConfig[string] postgresql;
    @optional WebDbConnectionConfig[string] sqlite;
  }

  /// Wrapper around a db connection configuration.
  final class WebDbConnectionConfig
  {
    /// The host.
    string host;
    /// The port.
    @optional ushort port;
    /// The user.
    string user;
    /// The password.
    string password;
    /// The database.
    @optional string database;

    static if (hasMsSql)
    {
      string namedInstance;
    }
  }

  /// Wrapper around a special route.
  final class WebSpecialRoute
  {
    /// The type of the route.
    string type;
    /// The value of the route.
    string value;
  }

  /// Wrapper around mongo db configurations.
  final class WebMongoDb
  {
    /// The host of the mongo db.
    string host;
    /// The port of the mongo db. This should only be used if the host is an IP.
    @optional ushort port;
  }

  /// The web configuration.
  private static __gshared WebConfig _webConfig;

  /// Gets the web configuration.
  @property WebConfig webConfig() { return _webConfig; }

  /// Loads the web configuration.
  void loadWebConfig()
  {
    import vibe.d : deserializeJson;
    import std.file : readText;

    _webConfig = deserializeJson!WebConfig(readText("config/web.json"));

    if (_webConfig.homeRoute[0] == '/')
    {
      _webConfig.homeRoute = _webConfig.homeRoute[1 .. $];
    }

    if (_webConfig.homeRoute[$-1] == '/')
    {
      _webConfig.homeRoute = _webConfig.homeRoute[0 .. $-1];
    }

    if (_webConfig.sessionAliveTime <= 0)
    {
      _webConfig.sessionAliveTime = 30;
    }

    if (!_webConfig.specialRouteSplitter)
    {
      _webConfig.specialRouteSplitter = "-";
    }
  }
}
