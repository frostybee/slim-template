@ECHO OFF
REM This is a batch file that calls the composer.bat file in the Wampoon's root directory.
REM Use it to run composer for installing and updating dependencies for the project.

set "COMPOSER_PATH=..\..\composer.bat"

IF NOT EXIST "%COMPOSER_PATH%" (
    ECHO Required composer.bat not found at "%COMPOSER_PATH%".
    EXIT /B 1
)

CALL "%COMPOSER_PATH%" %*
EXIT /B %ERRORLEVEL%
