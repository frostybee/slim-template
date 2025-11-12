@ECHO OFF
REM This is a batch file that calls the composer.bat file in the Wampoon's root directory.
REM Use it to run composer for installing and updating dependencies for the project.
call "../../composer.bat" %*
exit /b %errorlevel%
