/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.web.file.upload;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.http.client;

  /**
  * Simplified upload handler to handle file uploads.
  * Params:
  *   client =          The client that performed the upload.
  *   uploadedHandler = Handler for handling the uploaded files.
  */
  void uploaded(HttpClient client, void delegate(string tempPath) uploadedHandler)
  {
    if (!uploadedHandler)
    {
      return;
    }

    foreach (name, file; client.files)
    {
      uploadedHandler(file.tempPath.toString());
    }
  }
}
