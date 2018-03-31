/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.senc;

/**
* Template for the SENC encoding implementation.
* SENC is a simple byte to string encoder.
* Params:
*   unused = Unused boolean to instantiate SENCImpl;
*/
private template SENCImpl(bool unused)
{
  public:
  import std.conv : to;

  /**
  * Encodes a string to a SENC encoded string.
  * Params:
  *   s = The string to encode.
  * Returns:
  *   Returns the encoded string.
  */
  string encode(string s)
  {
    return encode(cast(ubyte[])s);
  }

  /**
  * Encodes a buffer to a SENC encoded buffer.
  * Params:
  *   data = The buffer to encode.
  * Returns:
  *   Returns the encoded string.
  */
  string encode(ubyte[] data)
  {
    auto buf = new char[data.length * 2];

    size_t i;

    foreach (b; data)
    {
      auto hex = to!string(b, 16);

      if (hex.length == 1)
      {
        buf[i] = '0';
        i++;
        buf[i] = hex[0];
        i++;
      }
      else
      {
        buf[i] = hex[0];
        i++;
        buf[i] = hex[1];
        i++;
      }
    }

    return cast(string)buf;
  }

  /**
  * Decodes an encoded string to a string result.
  * Params:
  *   data = The data to decode.
  * Returns:
  *   Returns the decoded string.
  */
  string decodeToString(string data)
  {
    return cast(string)decode(data);
  }

  /**
  * Decodes an encoded string to a buffer result.
  * Params:
  *   data = The data to decode.
  * Returns:
  *   Returns the decoded buffer.
  */
  ubyte[] decode(string data)
  {
    auto buf = new ubyte[data.length / 2];

    size_t i;
    size_t c;

    foreach (ref b; buf)
    {
      buf[c] = to!ubyte(data[i .. i + 2], 16);

      c++;
      i += 2;
    }

    return buf;
  }
}

/// An instance of the SENC implementation.
public alias SENC = SENCImpl!false;
