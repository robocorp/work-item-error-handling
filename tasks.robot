*** Settings ***
Library           Collections
Library           RPA.Robocorp.WorkItems
Library           RPA.Browser.Selenium
Task Teardown     Handle Teardown Actions

*** Variables ***
@{ERROR_MESSAGES}    @{EMPTY}

*** Keywords ***
User Keyword
    [Documentation]    Keyword that for demonstration purposes fails randomly
    [Arguments]    ${number}
    IF    $number % 2 == 0
        Fail    Number ${number} failed in the execution
    END

Handle Teardown Actions
    # ${PREV_TEST_STATUS}==FAIL indicates that task execution failed with
    # unhandled error -> APPLICATION error
    ${business_error_string}=    Get Business Error Message String
    IF    "${PREV_TEST_STATUS}" == "FAIL"
        ${error_message}=    Set Variable
        ...    APPLICATION ERROR:\n${PREV_TEST_MESSAGE}\n\n${business_error_string}
        Log To Console    ${error_message}
        Release Input Work Item
        ...    FAILED
        ...    exception_type=APPLICATION
        ...    code=1001
        ...    message=${error_message}
    ELSE IF    $business_error_string
        Release Input Work Item
        ...    FAILED
        ...    exception_type=BUSINESS
        ...    code=2001
        ...    message=${business_error_string}
        # Optional step - marking task FAILED in case of business errors
        # Log To Console    ${business_error_string}
        Fail    ${business_error_string}
    ELSE
        Release Input Work Item    DONE
    END

Get Business Error Message String
    ${error_string}=    Set Variable    ${EMPTY}
    IF    ${ERROR_MESSAGES}
        ${error_string}=    Catenate    SEPARATOR=\n    BUSINESS ERRORS:    @{ERROR_MESSAGES}
    END
    [Return]    ${error_string}

*** Tasks ***
Only business failures
    FOR    ${i}    IN RANGE    1    10
        #
        # Using "Run Keyword And Ignore Error" to prevent failures from "User Keyword" breaking
        # the execution of the task. The status and error_msg from "User Keyword" execution
        # is received as return values.
        #
        # On FAIL the error_msg is appended to global @{ERROR_MESSAGES} list which will be
        # processed at Suite Teardown step which handles overall task error reporting.
        #
        ${status}    ${error_msg}=    Run Keyword And Ignore Error    User Keyword    ${i}
        IF    "${status}" == "FAIL"
            #
            # Add error messages to internal @{ERROR_MESSAGES} list.
            #
            Append To List    ${ERROR_MESSAGES}    ${error_msg}
        END
    END
    Log    Done.

Application and Business failures
    # Browser keywords are used to simulate "random" application error
    Open Available Browser    about:blank
    FOR    ${i}    IN RANGE    1    10
        #
        # Using "Run Keyword And Ignore Error" to prevent failures from "User Keyword" breaking
        # the execution of the task. The ${status} and ${error_msg} from "User Keyword" execution
        # is received as return values.
        #
        # On FAIL the ${error_msg} is appended to global @{ERROR_MESSAGES} list which will be
        # processed at Suite Teardown step which handles overall task error reporting.
        #
        ${status}    ${error_msg}=    Run Keyword And Ignore Error    User Keyword    ${i}
        IF    "${status}" == "FAIL"
            #
            # Add error messages to internal @{ERROR_MESSAGES} list.
            #
            Append To List    ${ERROR_MESSAGES}    ${error_msg}
        END
    END
    #
    # "Click Element" will FAIL execution because button does not exist on the page
    # "Log    Done." step is not executed
    # 'Suite Teardown' keyword "Handle Teardown" will be executed at the end (regardless of PASS or FAIL)
    #
    Click Element    id:button1
    Log    Done.

Passing execution
    No Operation
