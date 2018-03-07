/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.http.websockets;

import std.variant : Variant;
import std.conv : to;

import vibewebsockets = vibe.http.websockets;

import diamond.errors;

/// Collection of web socket services;
private __gshared WebSocketService[string] _webSocketServices;

/// Wrapper around a web socket.
final class WebSocket
{
  private:
  /// Boolean determining whether the websocket is in strict mode or not.
  bool _strict;
  /// The raw web socket.
  vibewebsockets.WebSocket _socket;
  /// The websocket context.
  Variant[string] _context;

  /**
  * Creates a new websocket.
  * Params:
  *   socket = The raw socket.
  *   strict = Boolean determining whether the websocket is in strict mode or not.
  */
  this(vibewebsockets.WebSocket socket, bool strict)
  {
    _socket = socket;
    _strict = strict;
  }

  public:
  final:
  package(diamond)
  {
    /// Waits for data to be received.
    bool waitForData()
    {
      return _socket.waitForData();
    }
  }

  /// Reads the current message as a buffer.
  ubyte[] readBuffer()
  {
    return _socket.receiveBinary();
  }

  /// Reads the current message as a text string.
  string readText()
  {
    return _socket.receiveText();
  }

  /// Reads the current message as a generic data-type.
  T read(T)()
  {
    return to!T(readText());
  }

  /**
  * Waits for the next message and reads it as a buffer.
  * Params:
  *   (out) buffer = The buffer.
  * Returns:
  *   True if the message was received, false otherwise (Ex. connection closed.)
  */
  bool readBufferNext(out ubyte[] buffer)
  {
    buffer = null;
    waitForData();

    if (!_socket.connected)
    {
      return false;
    }

    buffer = _socket.receiveBinary();
    return true;
  }

  /**
  * Waits for the next message and reads it as a text string.
  * Params:
  *   (out) text = The text.
  * Returns:
  *   True if the message was received, false otherwise (Ex. connection closed.)
  */
  bool readTextNext(out string text)
  {
    text = null;
    waitForData();

    if (!_socket.connected)
    {
      return false;
    }

    text = _socket.receiveText();
    return true;
  }

  /**
  * Waits for the next message and reads it as a generic data-type.
  * Params:
  *   (out) value = The value.
  * Returns:
  *   True if the message was received, false otherwise (Ex. connection closed.)
  */
  bool readNext(T)(out T value)
  {
    value = T.init;
    waitForData();

    if (!_socket.connected)
    {
      return false;
    }

    value = to!T(readText());

    return true;
  }

  /**
  * Sends a buffer to the web socket.
  * Params:
  *   buffer = The buffer to send.
  */
  void sendBuffer(ubyte[] buffer)
  {
    _socket.send(buffer);
  }

  /**
  * Sends a text string to the web socket.
  * Params:
  *   text = The text to send.
  */
  void sendText(string text)
  {
    _socket.send(text);
  }

  /**
  * Sends a generic data value to the web socket.
  * Params:
  *   value = The value to send.
  */
  void send(T)(T value)
  {
    _socket.send(to!string(value));
  }

  /**
  * Closes the web socket.
  * Params:
  *   code =   The termination code.
  *   reason = A reason given, why the websocket has been closed.
  */
  void close(short code = 0, string reason = "")
  {
    _socket.close(code, reason);
  }

  /**
  * Adds context data to the web socket.
  * Params:
  *   name = The name of the context data.
  *   data = The data to add.
  */
  void add(T)(string name, T data)
  {
    _context[name] = data;
  }

  /**
  * Gets the context data of the web socket.
  * Params:
  *   name = The name of the context data.
  * Returns:
  *   The context data if found, defaultValue otherwise.
  */
  T get(T)(string name, lazy T defaultValue = T.init)
  {
    auto data = _context.get(name, Variant.init);

    if (!data.hasValue)
    {
      return defaultValue;
    }

    return data.get!T;
  }
}

/// Wrapper around a websocket service.
abstract class WebSocketService
{
  private:
  /// The route of the service.
  string _route;
  /// Boolean determining whether web socket service is in strict mode or not.
  bool _strict;

  public:
  /**
  * Creates a new web socket service.
  * Params:
  *   route =  The route of the web socket.
  *   strict = Boolean determ
  */
  this(string route, bool strict = true)
  {
    _route = route;
    _strict = strict;
  }

  package(diamond)
  {
    /**
    * Handling the raw web socket.
    * Params:
    *   rawSocket = The raw socket.
    */
    final void handleWebSocket(scope vibewebsockets.WebSocket rawSocket)
    {
      auto socket = new WebSocket(rawSocket, _strict);

      onConnect(socket);

      while (socket.waitForData())
      {
        onMessage(socket);
      }

      onClose(socket);
    }
  }

  @property
  {
    /// Gets the route of the service.
    final string route() { return _route; }
  }

  /// Function called when a web socket connects.
  abstract void onConnect(WebSocket socket);

  /// Function called when a web socket has received a message.
  abstract void onMessage(WebSocket socket);

  /// Function called when a web socket is closed.
  abstract void onClose(WebSocket socket);
}

/**
* Adds a web socket service.
* Params:
*   service = The web socket service to add.
*/
void addWebSocketService(WebSocketService service)
{
  enforce(service, "No web socket service specified.");

  _webSocketServices[service.route] = service;
}

package(diamond)
{
  import vibe.d : URLRouter;

  /**
  * Handles web sockets.
  * Params:
  *   router = The router.
  */
  void handleWebSockets(URLRouter router)
  {
    enforce(router, "Found no router");

    if (!_webSocketServices)
    {
      return;
    }

    foreach (service; _webSocketServices)
    {
      router.get(service.route, vibewebsockets.handleWebSockets((scope socket)
      {
        auto service = _webSocketServices.get(socket.request.requestPath.toString(), null);

        if (!service)
        {
          socket.close();
          return;
        }

        service.handleWebSocket(socket);
      }));
    }
  }
}
