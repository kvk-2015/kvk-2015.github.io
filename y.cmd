@echo off
chcp 65001 >nul
setlocal
set VideoURL=https://www.1tv.ru/doc/pro-zhizn-zamechatelnyh-lyudey/ya-ne-zhaleyu-ni-o-chem-dokumentalnyy-film-k-80-letiyu-yuriya-antonova
set template=%%(title)s [%%(id)s].%%(ext)s
set format=b
set extension=mov
set AppPath=D:\kvk\Utilities\GitHub\yt-dlp\yt-dlp.cmd
if not exist %AppPath% set AppPath=yt-dlp.exe
if not -%1- == -- set format=%1
set tempFileName=%random%.tmp
call %AppPath% -o "%%template:.!=%%" --windows-filenames --socket-timeout 45 --print-to-file filename %%tempFileName%% --skip-download %%VideoURL%%
if not errorlevel 0 if exist %tempFileName% del /q %tempFileName%
if not exist %tempFileName% exit /b
set /p filename=<%tempFileName%
set filename=%filename:.mp4=.mov%.txt
echo %VideoURL% > "%filename%" && del /q %tempFileName%
echo.>> "%filename%"
call :size "%filename%"
set tempsize=%filsize%
call %AppPath% --socket-timeout 45 --print formats_table %%VideoURL%% >> "%filename%"
if not errorlevel 0 exit /b
call :size "%filename%"
if %tempsize% == %filsize% exit /b
if -%1- == ---- exit /b
rem --limit-rate 8.5M
start "yt-dlp: %VideoURL%" %AppPath% -o "%template%" --split-chapters --video-multistreams --audio-multistreams --windows-filenames --remux-video %extension% --concurrent-fragments 10 --socket-timeout 45 --abort-on-unavailable-fragment --exec "pause " --embed-metadata --format %format% %VideoURL% ^&exit/b
:size
set filsize=%~z1