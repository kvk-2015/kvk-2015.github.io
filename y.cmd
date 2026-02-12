@set @x=0 /*
@echo off
chcp 65001 >nul
setlocal
set VideoURL=https://smotrim.ru/video/1979922
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
cscript /nologo /e:javascript "%~dpnx0" %tempFileName%
set /p filename=<%tempFileName%
set processed_series=%filename:!.=!%
if not "%processed_series%" == "%filename%" (setlocal enabledelayedexpansion & set series=!series:~0,-2! & setlocal disabledelayedexpansion & call :set_template & set filename=%processed_series%)
set filename_without_series=%filename:NA. =%
if not "%filename_without_series%" == "%filename%" (set series=& call :set_template & set filename=%filename_without_series%)
setlocal enabledelayedexpansion
set filename=!filename:.mp4=.%extension%!
set filename=!filename:.webm=.%extension%!.txt
setlocal disabledelayedexpansion
echo %VideoURL% > "%filename%" && del /q %tempFileName%
cscript /nologo /e:javascript "%~dpnx0" "%filename%"
echo.>> "%filename%"
call :size "%filename%"
set tempsize=%filesize%
call %AppPath% --socket-timeout 45 --print formats_table %%VideoURL%% >> "%filename%"
if not errorlevel 0 exit /b
call :size "%filename%"
if %tempsize% == %filesize% exit /b
cscript /nologo /e:javascript "%~dpnx0" "%filename%"
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
if(WSH.Arguments.Unnamed.Count && fso.FileExists(fName=WSH.Arguments.Unnamed(0))){
    with(new ActiveXObject("ADODB.Stream")){Type=2; Mode=3; Open(); Charset="UTF-8"; LoadFromFile(fName);
        Position=0; var newName=ReadText().replace(/\s*$/, ""); Close();
        newName = ((isTemp=/^\d+\.tmp$/.test(fName)) ? newName.replace(/\(/g, "{").replace(/\)/g, "}") : newName.replace(/\r\n|\n/g, "\r\n"));
        fso.DeleteFile(fName);
        Open(); Charset="UTF-8"; Position=0; WriteText(newName + (isTemp ? "" : "\r\n")); SaveToFile(fName); Close();
    }
}