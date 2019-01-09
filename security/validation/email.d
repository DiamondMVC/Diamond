/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.email;

import std.net.isemail : isEmail;

public import std.net.isemail : EmailStatusCode;

/**
* Checks whether a given email is valid or not.
* Standards:
*   RFC 5321
*   RFC 5322
* Params:
*   email = The email to validate.
*   checkDns = Boolean determining whether it should check dns for validation.
*   errorLevel = The error level boundary.
* Returns:
*   True if the email is valid according to the given configurations, false otherwise.
*/
bool isValidEmail(string email, bool checkDns = false, EmailStatusCode errorLevel = EmailStatusCode.none)
{
  import std.typecons : Yes, No;

  return isEmail(email, checkDns ? Yes.checkDns : No.checkDns, errorLevel).valid;
}
