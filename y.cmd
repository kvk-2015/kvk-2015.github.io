@set @x=0 /*
@echo off
chcp 65001 >nul
setlocal
set VideoURL=gaRy9U0yiSA
set head=
set suffix=
set series=%%(series)s. 
call :set_template
set format=b
set enable_format_recommendations=1
set extension=mov
set AppPath=D:\kvk\Utilities\GitHub\yt-dlp\yt-dlp.cmd
if not exist %AppPath% set AppPath=yt-dlp.exe
if not -%1- == -- (set format=%1 & set enable_format_recommendations=0)
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
for /f %%i in ('cscript /nologo /e:javascript "%~dpnx0" "%filename%" /FORMATRECOMMENDATIONS:%enable_format_recommendations%') do if defined enable_format_recommendations if "%enable_format_recommendations%" == "1" if not "%%i" == "" set format=%%i
if -%1- == ---- exit /b
rem --limit-rate 8.5M
start "yt-dlp: %VideoURL%" %AppPath% -o "%template%" --split-chapters --postprocessor-args "SplitChapters+ffmpeg:-map_metadata -1" --video-multistreams --audio-multistreams --windows-filenames --remux-video %extension% --concurrent-fragments 10 --socket-timeout 45 --abort-on-unavailable-fragment --exec "pause " --embed-metadata --format %format% %VideoURL% ^&exit/b
:set_template
set template=%head%%series%%%(title)s [%%(id)s]%suffix%.%%(ext)s
exit /b
:size
set filesize=%~z1
goto:eof */

var fso = new ActiveXObject("Scripting.FileSystemObject"), fName = "", newText = "";
if(WSH.Arguments.Unnamed.Count && fso.FileExists(fName=WSH.Arguments.Unnamed(0))){
    with(new ActiveXObject("ADODB.Stream")){Type=2; Mode=3; Open(); Charset="UTF-8"; LoadFromFile(fName);
        Position=0; var newText=ReadText().replace(/\s*$/, ""); Close();
        newText = ((isTemp=/^\d+\.tmp$/.test(fName)) ? newText.replace(/\(/g, "{").replace(/\)/g, "}") : newText.replace(/\r\n|\n/g, "\r\n"));
        fso.DeleteFile(fName);
        Open(); Charset="UTF-8"; Position=0; WriteText(newText + (isTemp ? "" : "\r\n")); SaveToFile(fName); Close();
    }
}
if(1*WSH.Arguments.Named.Item("FORMATRECOMMENDATIONS") && newText){
    var line, lines = newText.split("\r\n"), recommended_audio_format = "", recommended_video_format = "";
    for(var lineIndex in lines){
        if(/audio only/.test(line=lines[lineIndex])){
            if(/(^hls\S+)\s.+audio only.*$/.test(line))recommended_audio_format = RegExp.$1;
            else if(!/^hls/.test(recommended_audio_format) && /(^\S+)\s+m4a/.test(line))recommended_audio_format = RegExp.$1;
        } else if(/video only/.test(line)){
            if(/(^hls\S+)\s.+video only.*$/.test(line))recommended_video_format = RegExp.$1;
            else if(!/^hls/.test(recommended_video_format) && /(^\S+)\s+mp4\s+1920x1080\s+.*avc1/.test(line))recommended_video_format = RegExp.$1;
        }
    }
    WSH.echo(recommended_audio_format && recommended_video_format ? recommended_audio_format + "+" + recommended_video_format : "");
}