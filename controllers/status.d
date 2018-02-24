/**
* Copyright © DiamondMVC 2016-2017
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.controllers.status;

import diamond.core.apptype;

static if (isWeb)
{
  /// Enumeration of controller statuses.
  enum Status
  {
      /// Indicates the controller action was executed successfully.
      success,
      /// Indicates the controller action wasn't found.
      notFound,
      /**
      * Indicates the response should end after executing the actions.
      * This is useful if you're redirecting or responding with a different type of data than html such as json etc.
      */
      end,
      /// indicates the user isn't authorized for the action.
      unauthorized
  }
}
