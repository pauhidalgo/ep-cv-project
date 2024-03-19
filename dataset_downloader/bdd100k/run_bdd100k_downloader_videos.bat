@echo off
SET RE=0
:start
title Videos
if %RE% EQU 1 (
echo RESTARTED %TIME% %DATE% >> vid_log.txt
) ELSE (
echo STARTED %TIME% %DATE% >> vid_log.txt
)
cscript /nologo cv.bdd100k_downloader_videos.vbs
IF %ERRORLEVEL% NEQ 127 (
SET RE=1
goto :start
)
pause