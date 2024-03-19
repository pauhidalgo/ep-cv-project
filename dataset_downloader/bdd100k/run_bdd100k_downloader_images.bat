@echo off
SET RE=0
:start
title Images
if %RE% EQU 1 (
echo RESTARTED %TIME% %DATE% >> images_log.txt
) ELSE (
echo STARTED %TIME% %DATE% >> images_log.txt
)
cscript /nologo cv.bdd100k_downloader_images.vbs
IF %ERRORLEVEL% NEQ 127 (
SET RE=1
goto :start
)
pause