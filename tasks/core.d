/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.tasks.core;

import diamond.core.apptype;

static if (isWeb)
{
  private import vibecore = vibe.core.core;

  public alias runTask = vibecore.runTask;
  public alias sleep = vibecore.sleep;

  /**
  * Executes an asynchronous task.
  * This is a wrapper around vibe.core.core.runTask.
  * Params:
  *   task = The task to execute.
  *   args = The arguments to pass to the task.
  */
  void executeTask(ARGS...)(void delegate(ARGS) @safe task, auto ref ARGS args)
  {
    runTask(task, args);
  }

  /**
  * Executes an asynchronous task.
  * This is a wrapper around vibe.core.core.runTask.
  * Params:
  *   task = The task to execute.
  *   args = The arguments to pass to the task.
  */
  void executeTask(ARGS...)(void delegate(ARGS) @system task, auto ref ARGS args) @system
  {
    runTask(task, args);
  }

  /**
  * Executes an asynchronous task.
  * This is a wrapper around vibe.core.core.runTask.
  * Params:
  *   task = The task to execute.
  *   args = The arguments to pass to the task.
  */
  void executeTask(CALLABLE, ARGS...)(CALLABLE task, auto ref ARGS args)
  if (!is(CALLABLE : void delegate(ARGS)) && is(typeof(CALLABLE.init(ARGS.init))))
  {
    runTask(task, args);
  }
}
