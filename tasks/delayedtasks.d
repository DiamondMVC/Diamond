/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.tasks.delayedtasks;

import diamond.core.apptype;

static if (isWeb)
{

  public import core.time : Duration, dur, weeks, days, hours, minutes, seconds,
                            msecs, usecs, hnsecs, nsecs;

  import diamond.tasks.core;

  /**
  * Executes a delayed asynchronous task.
  * Params:
  *   delay = The time to delay the task.
  *   task =  The task to execute.
  *   args =  The arguments to pass to the task.
  */
  void delayTask(ARGS...)(Duration delay, void delegate(ARGS) @safe task, auto ref ARGS args)
  {
    sleep(delay);

    executeTask(task, args);
  }

  /**
  * Executes a delayed asynchronous task.
  * Params:
  *   delay = The time to delay the task.
  *   task =  The task to execute.
  *   args =  The arguments to pass to the task.
  */
  void delayTask(ARGS...)(Duration delay, void delegate(ARGS) @system task, auto ref ARGS args) @system
  {
    sleep(delay);

    executeTask(task, args);
  }

  /**
  * Executes a delayed asynchronous task.
  * Params:
  *   delay = The time to delay the task.
  *   task =  The task to execute.
  *   args =  The arguments to pass to the task.
  */
  void delayTask(CALLABLE, ARGS...)(Duration delay, CALLABLE task, auto ref ARGS args)
  if (!is(CALLABLE : void delegate(ARGS)) && is(typeof(CALLABLE.init(ARGS.init))))
  {
    sleep(delay);

    executeTask(task, args);
  }
}
