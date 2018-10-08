/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.client.envelopebody;

import diamond.web.soap.client.envelopeparameter;

/// Wrapper around a soap envelope body.
final class SoapEnvelopeBody
{
  private:
  /// The method.
  string _method;
  /// The parameters.
  SoapEnvelopeParameter[] _parameters;

  public:
  final:
  /**
  * Creates a new soap envelope body.
  * Params:
  *   method = The method of the body.
  */
  this(string method)
  {
    _method = method;
  }

  @property
  {
    /// Gets the method of the body.
    string method() { return _method; }

    /// Gets the parameters of the body.
    SoapEnvelopeParameter[] parameters() { return _parameters; }
  }

  /**
  * Adds a parameter to the body.
  * Params:
  *   name =  The name.
  *   value = The value.
  */
  void addParameter(string name, string value)
  {
    _parameters ~= new SoapEnvelopeParameter(name, value);
  }

  /**
  * Gets a parameter from the body.
  * Params:
  *   name  = The name of the parameter.
  * Returns:
  *   The parameter if found, null otherwise.
  */
  SoapEnvelopeParameter getParameter(string name)
  {
    import std.algorithm : filter;
    import std.array : array;
    import std.string : toLower, strip;

    if (!name || !name.length)
    {
      return null;
    }

    if (!_parameters || !_parameters.length)
    {
      return null;
    }

    auto parameter = _parameters.filter!(p => p.name.toLower().strip() == name.toLower().strip()).array;

    if (!parameter || !parameter.length)
    {
      return null;
    }

    return parameter[0];
  }
}
