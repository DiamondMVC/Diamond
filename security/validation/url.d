/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.security.validation.url;

/**
* Checks whether a given url is valid or not.
* Params:
*   url = The url to validate.
* Returns:
*   True if the url is valid, false otherwise.
*/
bool isValidUrl(string url)
{
  import vibe.inet.url;

  try
  {
    URL.parse(url);

    return true;
  }
  catch (Exception)
  {
    return false;
  }
}
