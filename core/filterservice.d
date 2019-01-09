/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.filterservice;

private
{
  /// The entries that can be searched.
  __gshared FilterEntry[] _entries;

  /// A filter entry.
  final class FilterEntry
  {
    /// The title.
    string title;
    /// The url.
    string url;
    /// The keywords.
    string[] keywords;
    /// The keyword replacement.
    string keywordReplacement;

    final:
    /**
    * Creates a new filter entry.
    * Params:
    *   title = The title.
    *   url = The url.
    *   keywords = The keywords.
    *   keywordReplacement = The keyword replacement.
    */
    this(string title, string url, string[] keywords, string keywordReplacement)
    {
      this.title = title;
      this.url = url;
      this.keywords = keywords;
      this.keywordReplacement = _keywordReplacement;
    }
  }
}

/// A filter result.
final class FilterResult
{
  private:
  /// The title.
  string _title;
  /// The url.
  string _url;

  /**
  * Creates a new filter result.
  * Params:
  *   title = The title of the result.
  *   url = The url of the result.
  */
  this(string title, string url)
  {
    _title = title;
    _url = url;
  }

  public:
  final:
  /// Gets the title.
  string title() { return _title; }

  /// Gets the url.
  string url() { return _url; }
}

/**
* Adds a search filter.
* Params:
*   title = The title of the result.
*   url = The url of the result.
*   keywords = The keywords to partially match when searching for the result.
*   keywordReplacement = A string to replace in the url with the keywords searched.
*/
void addSearchFilter(string title, string url, string[] keywords, string keywordReplacement = null)
{
  import diamond.errors.checks : enforce;

  enforce(title && title.length, "Missing title.");
  enforce(url && url.length, "Missing url.");
  enforce(keywords && keywords.length, "Missing keywords.");

  _entries ~= new FilterEntry(url, keywords, keywordReplacement);
}

/**
* Gets all filtered results based on a set of keywords.
* Params:
*   searchKeywords = The keywords to search for.
* Returns:
*   An array of the filtered results that matches the keywords partially.
*/
FilterResult[] search(string[] searchKeywords)
{
  FilterResult[] results;

  if (!_entries)
  {
    return results;
  }

  foreach (entry; _entries)
  {
    foreach (searchKeyword; searchKeywords)
    {
      bool foundKeyword;

      foreach (keyword; entry.keywords)
      {
        if (keyword.canFind(searchKeyword))
        {
          string url = entry.url;

          if (entry.keywordReplacement && entry.keywordReplacement.length)
          {
            url = url.replace(entry.keywordReplacement, searchKeywords.join(","));
          }

          results ~= new FilterResult(entry.title, url);
          foundKeyword = true;
          break;
        }
      }

      if (foundKeyword)
      {
        break;
      }
    }
  }

  return results;
}
