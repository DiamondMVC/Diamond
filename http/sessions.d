/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.sessions;

import diamond.core.apptype;

static if (isWeb)
{
  import std.datetime : Clock, SysTime;
  import std.variant : Variant;

  import diamond.core.webconfig;
  import diamond.core.collections;
  import diamond.errors.checks;
  import diamond.http.cookies;
  import diamond.http.client;
  import diamond.tasks;

  /// The name of the session cookie.
  private static const __gshared sessionCookieName = "__D_SESSION";

  /// The collection of currently stored sessions.
  private __gshared InternalHttpSession[string] _sessions;

  /// The next session group id.
  private size_t nextSessionGroupId;

  /// The sessions met.
  private size_t sessionsMet;

  /// Wrapper for the internal http session.
  private final class InternalHttpSession
  {
    /// The id of the session.
    string id;

    /// The ip address of the session.
    string ipAddress;

    /// The time when the session ends.
    SysTime endTime;

    /// The value os the session.
    Variant[string] values;

    /// Cached views.
    HashSet!string cachedViews;

    /// The directory for the session view cache.
    string directory;

    final:
    /// Creates a new http session instance.
    this()
    {
      cachedViews = new HashSet!string;
    }
  }

  /// Wrapper around a http session.
  final class HttpSession
  {
    private:
    /// The client.
    HttpClient _client;

    /// The session.
    InternalHttpSession _session;

    /**
    * Creates a new http session.
    * Params:
    *   client =  The client.
    *   session = The internal http session.
    */
    this(HttpClient client, InternalHttpSession session)
    {
      _client = enforceInput(client, "Cannot create a session without a client.");
      _session = enforceInput(session, "Cannot create a session without an internal session.");
    }

    public:
    final:
    @property
    {
      /// Gets the session id.
      string id() { return _session.id; }
    }

    /**
    * Gets a session value.
    * Params:
    *   name =         The name of the value to retrieve.
    *   defaultValue = The default value to return if no value could be retrieved.
    * Returns:
    *   Returns the value retrieved or defaultValue if not found.
    */
    T getValue(T = string)(string name, lazy T defaultValue = T.init)
    {
      Variant value = _session.values.get(name, Variant.init);

      if (!value.hasValue)
      {
        return defaultValue;
      }

      return value.get!T;
    }

    /**
    * Sets a session value.
    * Params:
    *   name =      The name of the value.
    *   value =     The value.
    */
    void setValue(T = string)(string name, T value)
    {
      _session.values[name] = value;
    }

    /**
    * Removes a session value.
    * Params:
    *   name = The name of the value to remove.
    */
    void removeValue(string name)
    {
      if (_session.values && name in _session.values)
      {
        _session.values.remove(name);
      }
    }

    /**
    * Caches a view in the session.
    * Params:
    *   viewName = The view to cache.
    *   result =   The result of the view to cache.
    */
    void cacheView(string viewName, string result)
    {
      if (!webConfig.shouldCacheViews)
      {
        return;
      }

      _session.cachedViews.add(viewName);

      import std.file : exists, write, mkdirRecurse;

      if (!exists(_session.directory))
      {
        mkdirRecurse(_session.directory);
      }

      write(_session.directory ~ "/" ~ viewName ~ ".html", result);
    }

    /**
    * Gets a view from the session cache.
    * Params:
    *   viewName = The view to retrieve.
    * Returns:
    *   The result of the cached view if found, null otherwise.
    */
    string getCachedView(string viewName)
    {
      if (!webConfig.shouldCacheViews)
      {
        return null;
      }

      import std.file : exists, readText;

      if (_session.cachedViews[viewName])
      {
        auto sessionViewFile = _session.directory ~ "/" ~ viewName ~ ".html";

        if (exists(sessionViewFile))
        {
          return readText(sessionViewFile);
        }
      }

      return null;
    }

    /**
    * Updates the session end time.
    * Params:
    *   newEndTime = The new end time.
    */
    void updateEndTime(SysTime newEndTime)
    {
      _session.endTime = newEndTime;
    }

    /// Clears the session values for a session.
    void clearValues()
    {
      _session.values.clear();
    }

    /**
    * Checks whether a value is present in the session.
    * Params:
    *   name = The name of the value to check for presence.
    * Returns:
    *   True if the value is present, false otherwise.
    */
    bool hasValue(string name)
    {
      return _session.values.get(name, Variant.init).hasValue;
    }
  }

  /**
  * Gets a session.
  * Params:
  *   client =                 The client
  *   createSessionIfInvalid = Boolean determining whether a new session should be created if the session is invalid.
  * Returns:
  *   Returns the session.
  */
  package(diamond.http) HttpSession getSession
  (
    HttpClient client,
    bool createSessionIfInvalid = true
  )
  {
    // Checks whether the request has already got its session assigned.
    auto cachedSession = client.getContext!HttpSession(sessionCookieName);

    if (cachedSession)
    {
      return cachedSession;
    }

    auto sessionId = client.cookies.get(sessionCookieName);
    auto session = _sessions.get(sessionId, null);

    if (createSessionIfInvalid &&
      (
        !session ||
        session.ipAddress != client.ipAddress ||
        Clock.currTime() >= session.endTime
      )
    )
    {
      client.cookies.remove(sessionCookieName);

      return createSession(client);
    }

    if (!session)
    {
      return null;
    }

    auto httpSession = new HttpSession(client, session);
    client.addContext(sessionCookieName, httpSession);

    return httpSession;
  }

  /**
  * Creates a http session.
  * Params:
  *   client =  The client.
  * Returns:
  *   Returns the session.
  */
  HttpSession createSession(HttpClient client)
  {
    auto clientSession = getSession(client, false);

    if (clientSession)
    {
      return clientSession;
    }

    auto session = new InternalHttpSession;

    import diamond.security.tokens.sessiontoken;

    session.ipAddress = client.ipAddress;
    session.id = sessionToken.generate(session.ipAddress);
    _sessions[session.id] = session;

    if (webConfig.shouldCacheViews)
    {
      import std.conv : to;

      sessionsMet++;

      if (sessionsMet >= 1000)
      {
        sessionsMet = 0;
        nextSessionGroupId++;
      }

      session.directory = "sessions/" ~ to!string(nextSessionGroupId) ~ "/" ~ session.id[$-52 .. $] ~ "/";
    }

    client.cookies.create(HttpCookieType.session, sessionCookieName, session.id, webConfig.sessionAliveTime * 60);
    session.endTime = Clock.currTime();
    session.endTime = session.endTime + webConfig.sessionAliveTime.minutes;

    clientSession = new HttpSession(client, session);
    client.addContext(sessionCookieName, clientSession);

    executeTask((InternalHttpSession session) { invalidateSession(session, 3); }, session);

    return clientSession;
  }

  /**
  * Invalidates a session.
  * Params:
  *   session = The session to invalidate.
  *   retries = The amount of retries left, if it failed to remove the session.
  *   isRetry = Boolean determining whether the invalidation is a retry or not.
  */
  private void invalidateSession(InternalHttpSession session, size_t retries, bool isRetry = false)
  {
    import diamond.tasks : sleep;

    auto time = isRetry ? 100.msecs : (webConfig.sessionAliveTime + 2).minutes;

    sleep(time);

    try
    {
      // The endtime differs from the default, so we cycle once more.
      if (Clock.currTime() < session.endTime)
      {
        executeTask((InternalHttpSession session) { invalidateSession(session, 3); }, session);
      }
      else
      {
        if (webConfig.shouldCacheViews)
        {
          try
          {
            import std.file : exists, rmdirRecurse;

            if (exists(session.directory))
            {
              rmdirRecurse(session.directory);
            }
          }
          catch (Throwable t) { }
        }

        _sessions.remove(session.id);
      }
    }
    catch (Throwable)
    {
      if (retries)
      {
        executeTask((InternalHttpSession s, size_t r) { invalidateSession(s, r, true); }, session, retries - 1);
      }
    }
  }
}
