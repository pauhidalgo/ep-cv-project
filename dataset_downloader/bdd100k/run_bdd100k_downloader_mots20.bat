@echo off
SET RE=0
:start
title Mots20
if %RE% EQU 1 (
echo RESTARTED %TIME% %DATE% >> mots20_log.txt
) ELSE (
echo STARTED %TIME% %DATE% >> mots20_log.txt
)
cscript /nologo cv.bdd100k_downloader_mots20.vbs
IF %ERRORLEVEL% NEQ 127 (
SET RE=1
goto :start
)
pause