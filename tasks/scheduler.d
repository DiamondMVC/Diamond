/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.tasks.scheduler;

import diamond.core.apptype;

static if (isWeb)
{  
  import diamond.errors.checks;

  /// Global lock to ensure tasks etc. are synced properly between threads.
  private static shared globalSchedulerLock = new Object;

  /// The next scheduler id.
  private static __gshared size_t _nextSchedulerId;

  public import core.time : Duration, dur, weeks, days, hours, minutes, seconds,
                            msecs, usecs, hnsecs, nsecs;

  /// Wrapper around a asynchronous scheduler.
  final class Scheduler
  {
    private:
    /// The id of the scheduler.
    size_t _id;
    /// The collection of tasks associated with the scheduler.
    ScheduledTask[size_t] _tasks;
    /// The next task id.
    size_t _nextTaskId;

    public:
    final:
    /// Creates a new asynchronous scheduler.
    this()
    {
      synchronized (globalSchedulerLock)
      {
        _nextSchedulerId++;
        _id = _nextSchedulerId;
      }
    }

    @property
    {
      /// Gets the id of the scheduler.
      size_t id() { return _id; }
    }

    /**
    * Addds a scheduled task to the scheduler.
    * Params:
    *   task = the task to add.
    */
    void addTask(ScheduledTask task)
    {
      synchronized (globalSchedulerLock)
      {
        enforce(!task.scheduler, "The task is associated with a scheduler.");

        _nextTaskId++;
        task._id = _nextTaskId;
        task._scheduler = this;

        _tasks[task.id] = task;

        task.execute();
      }
    }

    /**
    * Removes a task from the scheduler and halts its execution.
    * Params:
    *   task = The task to remove.
    */
    void removeTask(ScheduledTask task)
    {
      synchronized (globalSchedulerLock)
      {
        enforce(task.scheduler && task.scheduler.id == _id, "The task is not associated with this scheduler.");

        task._scheduler = null;
        _tasks.remove(task._id);
      }
    }
  }

  /// Wrapper around an asynchronous scheduled task.
  final class ScheduledTask
  {
    private:
    /// The id of the task.
    size_t _id;
    /// The amount of times the task should be repeated.
    size_t _repeat;
    /// The remaining amount of times the task should be repeated.
    size_t _remaningRepeats;
    /// The time to wait between each execution of the task.
    Duration _waitTime;
    /// The associated execution task.
    void delegate() _task;
    /// The scheduler.
    Scheduler _scheduler;

    public:
    final:
    /**
    * Creates a new asynchronous scheduled task.
    * Params:
    *   waitTime = the time to wait between each execution of the task.
    *   task =     The task to execute.
    *   repeat =   (optional) The amount of times the task should be repeated. 0 = forever.
    */
    this(Duration waitTime, void delegate() task, size_t repeat = 0)
    {
      _waitTime = waitTime;
      _task = task;
      _repeat = repeat;
      _remaningRepeats = _repeat;
    }

    @property
    {
      /// Gets the id of the task.
      size_t id() { return _id; }

      /// Gets the time to wait between each execution of the task.
      Duration waitTime() { return _waitTime; }

      /// Gets the amount of times the task should be repeated.
      size_t repeat() { return _repeat; }

      /// Gets the scheduler of the task.
      Scheduler scheduler() { return _scheduler; }
    }

    private:
    /// Executes the task.
    void execute()
    {
      import diamond.tasks.core;

      executeTask(
      {
        while (_scheduler !is null && (_repeat == 0 || _remaningRepeats > 0))
        {
          sleep(_waitTime);

          if (_scheduler)
          {
            _task();

            if (_repeat != 0)
            {
              _remaningRepeats--;
            }
          }
        }
      });
    }
  }
}
