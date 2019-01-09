/**
* Copyright © DiamondMVC 2019
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.file.download;

import diamond.core.apptype;

static if (isWeb)
{
  /**
  * Downloads data from a remote url.
  * Params:
  *   url =               The url of the data to download.
  *   downloadedHandler = A handler for when the data has been downloaded.
  */
  void download(string url, scope void delegate(scope ubyte[] data) downloadedHandler)
  {
    import diamond.http;

    remoteRequest(
      url,
      HttpMethod.GET,
      (scope resp)
      {
        import vibe.stream.operations : readAll;

        if (downloadedHandler)
        {
          downloadedHandler(resp.bodyReader.readAll());
        }
      }
    );
  }

  /**
  * Downloads a remote file and places in the file system.
  * Params:
  *   url =         The url of the file to download.
  *   destination = The destination path of the file in the file system.
  */
  void downloadFile(string url, string destination)
  {
    download(url, (scope data)
    {
      import std.file : write;

      write(destination, data);
    });
  }
}
