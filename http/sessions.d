/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.sessions;

import diamond.core.apptype;

static if (isWeb)
{
  import core.time : msecs, minutes;
  import std.datetime : Clock, SysTime;

  import vibe.d : HTTPServerRequest, HTTPServerResponse, runTask;

  import diamond.http.cookies;
  import diamond.errors.checks;
  import diamond.core.webconfig;

  /// The name of the session cookie.
  private static const __gshared sessionCookieName = "__D_SESSION";

  /// Wrapper for a http session.
  final class HttpSession
  {
    private:
    /// The id of the session.
    string _id;

    /// The ip address of the session.
    string _ipAddress;

    /// The time when the session ends.
    SysTime _endTime;

    final:
    @property
    {
      /// Sets the id.
      void id(string newId)
      {
        _id = newId;
      }

      /// Sets the ip address.
      void ipAddress(string newIPAddress)
      {
        _ipAddress = newIPAddress;
      }

      /// Sets the time when the session ends.
      void endTime(SysTime newEndTime)
      {
        _endTime = newEndTime;
      }
    }

    /// The value os the session.
    string[string] values;

    /// Creates a new http session instance.
    this() { }

    public:
    @property
    {
      /// Gets the id.
      string id() { return _id; }

      /// Gets the ip address.
      string ipAddress() { return _ipAddress; }

      /// Gets the time when the session ends.
      SysTime endTime() { return _endTime; }
    }
  }

  /// The collection of currently stored sessions.
  private __gshared HttpSession[string] _sessions;

  /**
  * Gets a session.
  * Params:
  *   request =                The request.
  *   response =               The response.
  *   createSessionIfInvalid = Boolean determining whether a new session should be created if the session is invalid.
  * Returns:
  *   Returns the session.
  */
  private HttpSession getSession
  (
    HTTPServerRequest request, HTTPServerResponse response,
    bool createSessionIfInvalid = true
  )
  {
    import std.variant : Variant;
    // Checks whether the request has already got its session assigned.
    Variant cachedSession = request.context.get(sessionCookieName);

    if (cachedSession.hasValue)
    {
      return cachedSession.get!HttpSession;
    }

    auto sessionId = getCookie(request, sessionCookieName);
    auto session = _sessions.get(sessionId, null);

    if (createSessionIfInvalid &&
      (
        !session ||
        session.ipAddress != request.clientAddress.toAddressString() ||
        Clock.currTime() >= session.endTime
      )
    )
    {
      response.removeCookie(sessionCookieName);

      return createSession(request, response);
    }

    request.context[sessionCookieName] = session;

    return session;
  }

  /**
  * Gets a session value.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   name =      The name of the value to retrieve.
  * Returns:
  *   Returns the value retrieved or defaultValue if not found.
  */
  string getSessionValue(HTTPServerRequest request, HTTPServerResponse response, string name, string defaultValue = null)
  {
    enforce(request, "You must specify the request to get the session value from.");
    enforce(response, "You must specify the response to get the session value from.");

    auto session = getSession(request, response);

    return session.values.get(name, defaultValue);
  }

  /**
  * Sets a session value.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   name =      The name of the value.
  *   value =     The value.
  */
  void setSessionValue
  (
    HTTPServerRequest request, HTTPServerResponse response,
    string name, string value
  )
  {
    enforce(request, "You must specify the request to set the session value for.");
    enforce(response, "You must specify the response to set the session value for.");

    auto session = getSession(request, response);

    session.values[name] = value;
  }

  /**
  * Removes a session value.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   name =      The name of the value to remove.
  */
  void removeSessionValue
  (
    HTTPServerRequest request, HTTPServerResponse response,
    string name
  )
  {
    enforce(request, "You must specify the request to set the session value for.");
    enforce(response, "You must specify the response to set the session value for.");

    auto session = getSession(request, response);

    if (session.values && name in session.values)
    {
      session.values.remove(name);
    }
  }

  /**
  * Creates a http session.
  * Params:
  *   request =   The request.
  *   response =  The response.
  * Returns:
  *   Returns the session.
  */
  HttpSession createSession(HTTPServerRequest request, HTTPServerResponse response)
  {
    enforce(request, "You must specify a request to create the session for.");
    enforce(response, "You must specify a response to create the session for.");

    auto session = getSession(request, response, false);

    if (session)
    {
      return session;
    }

    session = new HttpSession;

    import diamond.security.sessiontoken;

    session.ipAddress = request.clientAddress.toAddressString();
    session.id = sessionToken.generate(session.ipAddress);
    _sessions[session.id] = session;

    response.createCookie(sessionCookieName, session.id, webConfig.sessionAliveTime * 60);
    session.endTime = Clock.currTime();
    session.endTime = session.endTime + webConfig.sessionAliveTime.minutes;

    request.context[sessionCookieName] = session;

    runTask((HttpSession session) { invalidateSession(session, 3); }, session);

    return session;
  }

  /**
  * Updates the session end time.
  * Params:
  *   request =    The request.
  *   response =   The response.
  *   newEndTime = The new end time.
  */
  void updateSessionEndTime(HTTPServerRequest request, HTTPServerResponse response, SysTime newEndTime)
  {
    auto session = enforceInput(getSession(request, response, false), "Found no session.");
    session.endTime = newEndTime;
  }

  /**
  * Clears the session values for a session.
  * Params:
  *   request =  The request.
  *   response = The response.
  */
  void clearSessionValues(HTTPServerRequest request, HTTPServerResponse response)
  {
    auto session = enforceInput(getSession(request, response), "No session found.");

    session.values.clear();
  }

  /**
  * Invalidates a session.
  * Params:
  *   session = The session to invalidate.
  *   retries = The amount of retries left, if it failed to remove the session.
  *   isRetry = Boolean determining whether the invalidation is a retry or not.
  */
  private void invalidateSession(HttpSession session, size_t retries, bool isRetry = false)
  {
    import vibe.core.core : sleep;

    auto time = isRetry ? 100.msecs : (webConfig.sessionAliveTime + 2).minutes;

    sleep(time);

    try
    {
      // The endtime differs from the default, so we cycle once more.
      if (Clock.currTime() < session.endTime)
      {
        runTask((HttpSession session) { invalidateSession(session, 3); }, session);
      }
      else
      {
        _sessions.remove(session.id);
      }
    }
    catch (Throwable)
    {
      if (retries)
      {
        runTask((HttpSession s, size_t r) { invalidateSession(s, r, true); }, session, retries--);
      }
    }
  }
}
