/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.sessions;

import diamond.core.apptype;

static if (isWeb)
{
  import core.time : minutes;
  import std.datetime : Clock, SysTime;

  import vibe.crypto.cryptorand;
  import vibe.d : HTTPServerRequest, HTTPServerResponse;

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

  /// The random generator used to generate session ids.
  private __gshared SHA1HashMixerRNG _randomGenerator;

  /// The collection of currently stored sessions.
  private __gshared HttpSession[string] _sessions;

  /// Shared static constructor for the module.
  shared static this()
  {
    _randomGenerator = new SHA1HashMixerRNG();
  }

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

    return session;
  }

  /**
  * Gets a session value.
  * Params:
  *   request =   The request.
  *   response =  The response.
  *   name =      The name of the value to retrieve.
  * Returns:
  *   Returns the value retrieved or null if not found.
  */
  string getSessionValue(HTTPServerRequest request, HTTPServerResponse response, string name)
  {
    enforce(request, "You must specify the request to get the session value from.");

    auto session = getSession(request, response);

    return session.values.get(name, null);
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

    auto session = getSession(request, response);

    session.values[name] = value;
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

    ubyte[64] randomBuffer;
		_randomGenerator.read(randomBuffer);

    session = new HttpSession;

    import diamond.core.senc;
    session.ipAddress = request.clientAddress.toAddressString();
    session.id = SENC.encode(randomBuffer) ~ SENC.encode(session.ipAddress);
    _sessions[session.id] = session;

    auto time = webConfig.sessionAliveTime;

    response.createCookie(sessionCookieName, session.id, time * 60);
    session.endTime = Clock.currTime();
    session.endTime = session.endTime + time.minutes;
    session.values["Test"] = "Hello!";
    request.cookies.add(sessionCookieName, session.id);

    import vibe.d : runTask;
    runTask((HttpSession session) { invalidateSession(session, 3); }, session);

    return session;
  }

  /**
  * Invalidates a session.
  * Params:
  *   session = The session to invalidate.
  *   retries = The amount of retries left, if it failed to remove the session.
  */
  private void invalidateSession(HttpSession session, size_t retries)
  {
    import vibe.core.core : sleep;

    auto time = (webConfig.sessionAliveTime + 2).minutes;

    sleep(time);

    try
    {
      _sessions.remove(session.id);
    }
    catch (Throwable)
    {
      if (retries)
      {
        runTask((HttpSession s, size_t r) { invalidateSession(s, r); }, session, retries--);
      }
    }
  }
}
