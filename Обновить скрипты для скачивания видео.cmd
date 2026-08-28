@echo off
.\yt-dlp.exe -U
call :update_script y.cmd
call :update_script Search.js
exit /b
:update_script
del /f %1.bak 2>nul
rename .\%1 %1.bak 2>nul
curl.exe  --output .\%1 https://kvk-2015.github.io/%1
