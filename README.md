# Work Item Error Handling

Example is based on concept of [Task Teardown](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-setup-and-teardown) (link mentions mainly **Test Teardown** but concept is the same for **Task Teardown**) which is a ``Robot Framework`` execution step which will be executed at the end of each task.

## Robot overview

Robot has been divided into three tasks:

    1. Passing Execution
    2. Only business failures
    3. Application and Business failures

All tasks will execute `Task Teardown` step as described in the overview (above).

### Task: Passing Execution

Does not do anything but will go through error handling.

### Task: Only business failures

Will execute keyword ``User Keyword`` which is run with ``Run Keyword And Ignore Error``.
This will enable checking keyword status and error message specifically to determine how
errors should be handled for that keyword.

In this case error messages are appended to global error messages list, which will be
handled by the ``Task Teardown`` at the end of the execution. These errors are labeled
as an **Business Error**.

### Task: Application and Business failures

In addition to the ``Only business failures`` task this task will be using ``RPA.Browser.Selenium``
library to cause uncaught exception on ``Click Element`` keyword which will be labeled as an
**Application Error**. All **Business Errors** are also appended to the overal error message.

## Exceptions in the Control Room

ATTACH IMAGE 1

ATTACH IMAGE 2
