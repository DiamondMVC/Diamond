/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.sensitive;

import std.regex : Regex, regex, matchAll;
import std.algorithm : filter, canFind;
import std.array : array;

/// Collection of patterns used to create the sensitive data regex.
private static __gshared string[][SecurityLevel] _sensitiveDataPatterns;

// Collection of names to look for in the input which might disclose sensitive data.
private static __gshared string[][SecurityLevel] _sensitiveDataNames;

/// The generated regex from sensitive data patterns.
private static __gshared Regex!char[][SecurityLevel] _sensitiveDataRegexes;

/// Regex for phone numbers.
private static const _phoneNumberRegex = `(\+?(?:(?:9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)|\((?:9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)\))[0-9. -]{4,14})(?:\b|x\d+)`;

/// Regex for amex cards.
private static const _amexCardRegex = `^3[47][0-9]{13}$`;

/// Regex for BCGlobal cards.
private static const _BCGlobalRegex = `^(6541|6556)[0-9]{12}$`;

/// Regex for Carte Blanche cards.
private static const _carteBlancheCardRegex = `^389[0-9]{11}$`;

/// Regex for Diners Club cards.
private static const _dinersClubCardRegex = `^3(?:0[0-5]|[68][0-9])[0-9]{11}$`;

/// Regex for Discover cards.
private static const _discoverCardRegex = `^65[4-9][0-9]{13}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10})$`;

/// Regex for Insta Payment cards.
private static const _instaPaymentCardRegex = `^63[7-9][0-9]{13}$`;

/// Regex for JCB cards.
private static const _JCBCardRegex = `^(?:2131|1800|35\d{3})\d{11}$`;

/// Regex for Korean Local cards.
private static const _koreanLocalCardRegex = `^9[0-9]{15}$`;

/// Regex for Maestro cards.
private static const _maestroCardRegex = `^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$`;

/// Regex for Mastercard cards.
private static const _mastercardRegex = `^5[1-5][0-9]{14}$`;

/// Regex for Solo cards.
private static const _soloCardRegex = `^(6334|6767)[0-9]{12}|(6334|6767)[0-9]{14}|(6334|6767)[0-9]{15}$`;

/// Regex for Union Pay cards.
private static const _unionPayCardRegex = `^(62[0-9]{14,17})$`;

/// Regex for Visa cards.
private static const _visaCardRegex = `^4[0-9]{12}(?:[0-9]{3})?$`;

/// Regex for Visa master cards.
private static const _visaMasterCardRegex = `^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})$`;

/// Regex for Mastercards after 2016.
private static const _masterCard2016Regex = `^5$|^5[1-5][0-9]{0,14}$|^2[2]?[2]?$|^2221[0-9]{0,12}$|^222[3-9][0-9]{0,12}$|^22[3-9][0-9]{0,13}$|^2[3-6][0-9]{0,14}$|^2[7]?$|^27[2]?$|^27[0-1][0-9]{0,12}$|^2720[0-9]{0,12}$`;

/// Regex for Mastercard Bin cards.
private static const _masterCardBinRegex = `^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$`;

/// Regex for generic credit/debit cards.
private static const _genericCardRegex = `^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$`;

/// Regex for CPR numbers.
private static const _cprRegex = `^(?:(?:31(?:0[13578]|1[02])|(?:30|29)(?:0[13-9]|1[0-2])|(?:0[1-9]|1[0-9]|2[0-8])(?:0[1-9]|1[0-2]))[0-9]{2}\s?-?\s?[0-9]|290200\s?-?\s?[4-9]|2902(?:(?!00)[02468][048]|[13579][26])\s?-?\s?[0-3])[0-9]{3}|000000\s?-?\s?0000$`;

/// Regex for Social Security numbers.
private static const _ssnRegex = `^(?!(000|666|9))\d{3}-(?!00)\d{2}-(?!0000)\d{4}$`;

/// Regex for UK Insurance numbers.
private static const _ukInsuranceNumberRegex = `^\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*$`;

/// Enumeration of security levels.
enum SecurityLevel
{
  /// Allows everything under medium, but also phone numbers, emails and addresses.
  minimum,
  /// Allows names, authentication (Not password), zip codes / postal codes, job / occupation, age, politics, race and ethnicity.
  medium,
  /// Allows no sensitive data.
  maximum
}

/// Initializing the sensitive data validator.
void initializeSensitiveDataValidator()
{
  _sensitiveDataNames = [
    SecurityLevel.minimum :
    [
      "password",
      "cpr", "ssn", "social security", "socialsecurity", "social-security",
      "social number", "social-number", "socialnumber",
      "salary", "payment",
      "money", "cash", "bank", "bank account", "bank-account",
      "cc", "credit", "credit card", "credit-card", "creditcard",
      "dc", "debit", "debit card", "debit-card", "debitcard",
      "credit info", "creditinfo", "credit-info",
      "debit info", "debitinfo", "debit-info",
      "debt", "bill",
      "insurance", "insurance number", "insurance-number"
    ],
    SecurityLevel.medium :
    [
      "password",
      "cpr", "ssn", "social security", "socialsecurity", "social-security",
      "social number", "social-number", "socialnumber",
      "address",
      "email", "e-mail", "mail", "phone", "telephone", "salary", "payment",
      "money", "cash", "bank", "bank account", "bank-account",
      "cc", "credit", "credit card", "credit-card", "creditcard",
      "dc", "debit", "debit card", "debit-card", "debitcard",
      "credit info", "creditinfo", "credit-info",
      "debit info", "debitinfo", "debit-info",
      "debt", "bill",
      "insurance", "insurance number", "insurance-number"
    ],
    SecurityLevel.maximum :
    [
      "name", "account", "username", "password", "auth", "login",
      "cpr", "ssn", "social security", "socialsecurity", "social-security",
      "social number", "social-number", "socialnumber",
      "age", "race", "politic", "address", "zip", "zipcode", "postal", "postalcode",
      "job", "jobtitle", "occupation", "nick", "nickname",
      "email", "e-mail", "mail", "phone", "telephone", "salary", "payment",
      "money", "cash", "bank", "bank account", "bank-account",
      "cc", "credit", "credit card", "credit-card", "creditcard",
      "dc", "debit", "debit card", "debit-card", "debitcard",
      "credit info", "creditinfo", "credit-info",
      "debit info", "debitinfo", "debit-info",
      "debt", "bill",
      "ethnic", "ethnicity",
      "insurance", "insurance number", "insurance-number"
    ]
  ];

  _sensitiveDataPatterns = [
    SecurityLevel.minimum :
    [
      _amexCardRegex,
      _BCGlobalRegex,
      _carteBlancheCardRegex,
      _dinersClubCardRegex,
      _discoverCardRegex,
      _instaPaymentCardRegex,
      _JCBCardRegex,
      _koreanLocalCardRegex,
      _maestroCardRegex,
      _mastercardRegex,
      _soloCardRegex,
      _unionPayCardRegex,
      _visaCardRegex,
      _visaMasterCardRegex,
      _masterCard2016Regex,
      _masterCardBinRegex,
      _genericCardRegex,

      _cprRegex,
      _ssnRegex,
      _ukInsuranceNumberRegex
    ],
    SecurityLevel.medium :
    [
      _phoneNumberRegex,

      _amexCardRegex,
      _BCGlobalRegex,
      _carteBlancheCardRegex,
      _dinersClubCardRegex,
      _discoverCardRegex,
      _instaPaymentCardRegex,
      _JCBCardRegex,
      _koreanLocalCardRegex,
      _maestroCardRegex,
      _mastercardRegex,
      _soloCardRegex,
      _unionPayCardRegex,
      _visaCardRegex,
      _visaMasterCardRegex,
      _masterCard2016Regex,
      _masterCardBinRegex,
      _genericCardRegex,

       _cprRegex,
      _ssnRegex,
      _ukInsuranceNumberRegex
    ],
    SecurityLevel.maximum :
    [
      _phoneNumberRegex,

      _amexCardRegex,
      _BCGlobalRegex,
      _carteBlancheCardRegex,
      _dinersClubCardRegex,
      _discoverCardRegex,
      _instaPaymentCardRegex,
      _JCBCardRegex,
      _koreanLocalCardRegex,
      _maestroCardRegex,
      _mastercardRegex,
      _soloCardRegex,
      _unionPayCardRegex,
      _visaCardRegex,
      _visaMasterCardRegex,
      _masterCard2016Regex,
      _masterCardBinRegex,
      _genericCardRegex,

      _cprRegex,
      _ssnRegex,
      _ukInsuranceNumberRegex
    ]
  ];

  updateRegexPattern();
}

/// Updates the regex pattern for sensitive data patterns.
private void updateRegexPattern()
{
  foreach (level,patterns; _sensitiveDataPatterns)
  {
    foreach (pattern; patterns)
    {
      _sensitiveDataRegexes[level] ~= regex(pattern);
    }
  }
}

/**
* Adds a sensitive data name.
* Params:
*   name =  The name to add.
*   level = The security level to add the name to.
*/
void addSensitiveDataName(string name, SecurityLevel level)
{
  _sensitiveDataNames[level] ~= name;
}

/**
* Adds a sensitive data pattern.
* Params:
*   pattern =     The pattern to add.
*   level =       The security level to add the pattern to.
*   updateRegex = Boolean determining whether the validation regex should be updated. False by default to allow bulk-adds.
*/
void addSensitiveDataPattern(string pattern, SecurityLevel level, bool updateRegex = false)
{
  _sensitiveDataPatterns[level] ~= pattern;

  if (updateRegex)
  {
    updateRegexPattern();
  }
}

/**
* Removes a sensitive data name.
* Params:
*   name = The name to remove.
*   level =   The security level to remove the name from.
*/
void removeSensitiveDataName(string name, SecurityLevel level)
{
  _sensitiveDataNames[level] = _sensitiveDataNames[level].filter!(n => n != name).array;
}

/**
* Removes a sensitive data pattern.
* Params:
*   pattern = The pattern to remove.
*   level =   The security level to remove the pattern from.
*/
void removeSensitiveDataPattern(string pattern, SecurityLevel level)
{
  _sensitiveDataPatterns[level] = _sensitiveDataPatterns[level].filter!(p => p != pattern).array;

  updateRegexPattern();
}

/// Clears all sensitive data names.
void clearSensitiveDataNames()
{
  _sensitiveDataNames.clear();
}

/// Clears all sensitive data patterns.
void clearSensitiveDataPatterns()
{
  _sensitiveDataPatterns.clear();
}

/**
* Checks whether a specific string contains sensitive data.
* Params:
*   data =  The data to check.
*   level = The security level for the validation
* Returns:
*   True if the string contains sensitive data, false otherwise.
*/
bool hasSensitiveData(string data, SecurityLevel level)
{
  if (!data || !data.length)
  {
    return false;
  }

  import diamond.core.string : splitIntoGroupedWords;

  auto words = splitIntoGroupedWords(data);

  foreach (word; words)
  {
    if (_sensitiveDataNames && level in _sensitiveDataNames && _sensitiveDataNames[level].length)
    {
      foreach (name; _sensitiveDataNames[level])
      {
        if (word.canFind(name))
        {
          return true;
        }
      }
    }

    if (_sensitiveDataPatterns && level in _sensitiveDataPatterns && level in _sensitiveDataRegexes && _sensitiveDataPatterns[level].length)
    {
      auto regexes = _sensitiveDataRegexes.get(level, null);

      if (regexes && regexes.length)
      {
        foreach (regex; regexes)
        {
          auto regexResult = word.matchAll(regex);

          if (!regexResult.empty)
          {
            return true;
          }
        }
      }
    }
  }

  return false;
}

/**
* Checks whether a specific string contains sensitive data.
* Params:
*   data = The data to check.
*   level = The security level for the validation
* Throws:
*   SensitiveDataException when the string contains sensitive data.
*/
void validateSensitiveData(string data, SecurityLevel level)
{
  if (hasSensitiveData(data, level))
  {
	  writeln("FAILED");
  }
}
