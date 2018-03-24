/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.types;

import std.traits : isNumeric;

/**
* Checks whether a given string input is a number or not.
* Params:
*   input = The string input to validate.
* Returns:
*   True if the input is a valid number, false otherwise.
*/
bool isValidNumber(string input)
{
  import std.string : isNumeric;

  return input.isNumeric;
}

/**
* Checks whether a given string input is a boolean or not.
* Params:
*   input = The string input to validate.
* Returns:
*   True if the input is a valid boolean, false otherwise.
*/
bool isValidBoolean(string input)
{
  return input == "true" || input == "false";
}

/**
* Checks whether a given numeric input is a boolean or not.
* Params:
*   input = The numeric input to validate.
* Returns:
*   True if the input is a valid boolean, false otherwise.
*/
bool isValidBoolean(TNumber)(TNumber input)
if (isNumeric!TNumber)
{
  return input == 0 || input == 1;
}
