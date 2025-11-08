@set @x=0 /*
@echo off
chcp 65001 >nul
setlocal
set VideoURL=https://smotrim.ru/video/3043739
set head=
set suffix=
set series=%%(series)s. 
call :set_template
set format=b
set extension=mov
set AppPath=D:\kvk\Utilities\GitHub\yt-dlp\yt-dlp.cmd
if not exist %AppPath% set AppPath=yt-dlp.exe
if not -%1- == -- set format=%1
set tempFileName=%random%.tmp
call %AppPath% -o "%%template:.!=%%" --windows-filenames --socket-timeout 45 --print-to-file filename %%tempFileName%% --skip-download %%VideoURL%%
if not errorlevel 0 if exist %tempFileName% del /q %tempFileName%
if not exist %tempFileName% exit /b
cscript /nologo /e:javascript %0 %tempFileName%
set /p filename=<%tempFileName%
set filename_without_series=%filename:NA. =%
if not "%filename_without_series%" == "%filename%" (set series=& call :set_template & set filename=%filename_without_series%)
setlocal enabledelayedexpansion
set filename=!filename:.mp4=.%extension%!
set filename=!filename:.webm=.%extension%!.txt
setlocal disabledelayedexpansion
echo %VideoURL% > "%filename%" && del /q %tempFileName%
echo.>> "%filename%"
call :size "%filename%"
set tempsize=%filesize%
call %AppPath% --socket-timeout 45 --print formats_table %%VideoURL%% >> "%filename%"
if not errorlevel 0 exit /b
call :size "%filename%"
if %tempsize% == %filesize% exit /b
if -%1- == ---- exit /b
rem --limit-rate 8.5M
start "yt-dlp: %VideoURL%" %AppPath% -o "%template%" --split-chapters --postprocessor-args "SplitChapters+ffmpeg:-map_metadata -1" --video-multistreams --audio-multistreams --windows-filenames --remux-video %extension% --concurrent-fragments 10 --socket-timeout 45 --abort-on-unavailable-fragment --exec "pause " --embed-metadata --format %format% %VideoURL% ^&exit/b
:set_template
set template=%head%%series%%%(title)s [%%(id)s]%suffix%.%%(ext)s
exit /b
:size
set filesize=%~z1
goto:eof */

var fso = new ActiveXObject("Scripting.FileSystemObject");
if(fso.FileExists(fName=WSH.Arguments.Unnamed(0))){
    newName = (inp=fso.OpenTextFile(fName, 1, -2)).ReadAll().replace(/\s*$/, "").replace(/\(/g, "{").replace(/\)/g, "}"); inp.Close();
    fso.OpenTextFile(fName, 2, -2).Write(newName);
}