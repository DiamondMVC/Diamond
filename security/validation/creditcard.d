/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.creditcard;

/**
* Validates a credit-card number using luhn's algorithm.
* Params:
*   creditCardNumber = The number of the credit card.
*   allowedDigits =    The allowed length of digits. If it's null it allows credit card numbers to be any length.
* Returns:
*   True if the credit card number is valid according to the allowed digits and luhn's algorithm, false otherwise.
*/
bool isValidCreditCard(string creditCardNumber, size_t[] allowedDigits = null)
{
  import std.conv : to;
  import std.algorithm : map, canFind;

  import diamond.errors.checks;

  import diamond.security.validation.types : isValidNumber;

  enforce(creditCardNumber && creditCardNumber.length, "A credit card number must be specified.");
  enforce(isValidNumber(creditCardNumber), "The credit card number must be numeric");

  if (allowedDigits)
  {
    if (!allowedDigits.canFind(creditCardNumber.length))
    {
      return false;
    }
  }

  size_t sum;

  foreach (digit; creditCardNumber.map!(d => to!string(d)))
  {
    auto value = to!size_t(digit);

    if (value % 2 == 0)
    {
      value *= 2;

      if (value > 9)
      {
        value = 1 + (value % 10);
      }
    }

    sum += value;
  }

  return (sum % 10) == 0;
}
