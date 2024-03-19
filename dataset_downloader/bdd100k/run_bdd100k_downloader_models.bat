@echo off
SET RE=0
:start
title Models
if %RE% EQU 1 (
echo RESTARTED %TIME% %DATE% >> models_log.txt
) ELSE (
echo STARTED %TIME% %DATE% >> models_log.txt
)
cscript /nologo cv.bdd100k_downloader_models.vbs
IF %ERRORLEVEL% NEQ 127 (
SET RE=1
goto :start
)
pause