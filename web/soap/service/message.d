/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.soap.service.message;

import diamond.web.soap.service.parameter;

package(diamond.web.soap.service):
/// Wrapper around a soap message.
final class SoapMessage
{
  private:
  /// The input name.
  string _inputName;
  /// The output name.
  string _outputName;
  /// The input parameters.
  SoapParameter[] _inputParameters;
  /// The output parameter.
  SoapParameter _outputParameter;

  public:
  final:
  /**
  * Creates a new soap message.
  * Params:
  *   inputName =  The name of the input mesage.
  *   outputName = The name of the output message.
  */
  this(string inputName, string outputName)
  {
    _inputName = inputName;
    _outputName = outputName;
  }

  /**
  * Adds an input parameter to the message.
  * Params:
  *   name = The name of the input parameter.
  *   type = The type of the input parameter.
  */
  void addInputParameter(string name, string type)
  {
    _inputParameters ~= new SoapParameter(name, type);
  }

  @property
  {
    /// Gets the input name.
    string inputName() { return _inputName; }

    /// Gets the output name.
    string outputName() { return _outputName; }

    /// Gets the input parameters.
    SoapParameter[] input() { return _inputParameters; }

    /// Gets the output parameter.
    SoapParameter output() { return _outputParameter; }

    /// Sets the output parameter.
    void output(SoapParameter newOutput)
    {
      _outputParameter = newOutput;
    }
  }
}
