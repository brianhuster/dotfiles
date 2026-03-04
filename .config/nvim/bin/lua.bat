@echo off
setlocal

SET PARENT=%~dp0

nvim -l %PARENT%/nlua %*

exit /b %ERRORLEVEL%
