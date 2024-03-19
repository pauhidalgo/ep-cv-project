@echo off
SET RE=0
:start
title Mot20
if %RE% EQU 1 (
echo RESTARTED %TIME% %DATE% >> mot20_log.txt
) ELSE (
echo STARTED %TIME% %DATE% >> mot20_log.txt
)
cscript /nologo cv.bdd100k_downloader_mot20.vbs
IF %ERRORLEVEL% NEQ 127 (
SET RE=1
goto :start
)
pause