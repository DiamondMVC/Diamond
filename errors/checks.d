/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.errors.checks;

import diamond.errors.exceptions : EnforceException;

/**
* Enforces the value of an input to be defined.
* Params:
*   value =    The value of an input.
*   message =  A given message when the value is undefined.
* Returns:
*   The value of the input.
*/
T enforceInput(T)(T value, lazy string message = null) @trusted
if (is(typeof({ if (!value) {} })))
{
  if (!value)
  {
    throw new EnforceException(message ? message : "Enforcement failed.");
  }

  return value;
}

/**
* Enforces a value to be defined.
* Params:
*   value =    The value.
*   message =  A given message when the value is undefined.
*/
void enforce(T)(T value, lazy string message = null) @trusted
if (is(typeof({ if (!value) {} })))
{
  if (!value)
  {
    throw new EnforceException(message ? message : "Enforcement failed.");
  }
}
