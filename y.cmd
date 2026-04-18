@set @x=0 /*
@echo off
chcp 65001 >nul
setlocal
set VideoURL=https://smotrim.ru/video/4011283
set head=
set suffix=
set series=%%(series)s. 
call :set_template
set format=b
set enable_format_recommendations=1
set extension=mkv
set AppPath=D:\kvk\Utilities\GitHub\yt-dlp\yt-dlp.cmd
if not exist %AppPath% set AppPath=yt-dlp.exe
if not -%1- == -- (set format=%1 & set enable_format_recommendations=0)
set tempFileName=%random%.tmp
call %AppPath% -o "%%template:.!=%%" --windows-filenames --socket-timeout 45 --print-to-file filename %%tempFileName%% --skip-download %%VideoURL%%
if not errorlevel 0 if exist %tempFileName% del /q %tempFileName%
if exist %tempFileName% goto :normal_process
:: Пример временного "патча", когда yt-dlp ещё не может выполнить скачивание, например, из-за редизайна сайта,
:: как пока обстоят дела для новых видео на smotrim.ru, но описание изменений api уже можно найти
for /f "tokens=1,2,3 delims=," %%i in ('cscript /nologo /e:javascript "%~dpnx0" %tempFileName% /GetSmotrimData:"%VideoURL%"') do if not "%%i" == "" set new_url="%%i"&set id=%%j&set json_url=%%k
if not defined new_url exit /b
set /p title=<%tempFileName%
set template=%title% [%id%].%extension%
if exist %tempFileName% del /q %tempFileName%
set filename="%template%.txt"
echo %VideoURL% > %filename%
echo. >> %filename%
echo %json_url% >> %filename%
echo %new_url% >> %filename%
cscript /nologo /e:javascript "%~dpnx0" %filename%
if -%1- == ---- exit /b
set VideoURL=%new_url%
start "yt-dlp: smotrim" %AppPath% -k -o "%template%" --split-chapters --postprocessor-args "SplitChapters+ffmpeg:-map_metadata -1" --video-multistreams --audio-multistreams --windows-filenames --remux-video %extension% --concurrent-fragments 10 --socket-timeout 45 --abort-on-unavailable-fragment --exec "pause " --embed-metadata --format %format% %VideoURL%^&exit/b
exit /b
:normal_process
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
call %AppPath% --socket-timeout 45 --print "<%%%%(webpage_url_domain)s:%%%%(uploader)s>" %%VideoURL%% >> "%filename%"
cscript /nologo /e:javascript "%~dpnx0" "%filename%" /toUTF-8:1
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
start "yt-dlp: %VideoURL%" %AppPath% -k -o "%template%" --split-chapters --postprocessor-args "SplitChapters+ffmpeg:-map_metadata -1" --video-multistreams --audio-multistreams --windows-filenames --remux-video %extension% --concurrent-fragments 10 --socket-timeout 45 --abort-on-unavailable-fragment --exec "pause " --embed-metadata --format %format% %VideoURL% ^&exit/b
:set_template
set template=%head%%series%%%(title)s [%%(id)s]%suffix%.%%(ext)s
exit /b
:size
set filesize=%~z1
goto:eof */

// Описание работы скрипта на основании подготовленного видео о скачивании с его помошью (с размышлениями о юридических тонкостях при этом),
// статьи в Дзене у меня, также текстов скриптов (там ещё про получение оглавления папки с видеофайлами)
// в Алисе Про: https://alicepro.yandex.ru/expert/projects/5f35ee4ef1a511f081018e7d0d775479
// (этот вариант описательного ИИ может использоваться только на территории Российской Федерации и Республики Беларусь)
// Ссылка на свежий вариант этого батника у меня на GitHub: https://kvk-2015.github.io/y.cmd
// У меня на компьютере установлена кодировка utf-8, если нужно, чтобы скрипт корректно выполнял поиск по регулярным выражениям на кирилице,
// сохраните его в кодировке Windows-1251

var fso = new ActiveXObject("Scripting.FileSystemObject"), fName = "", newText = "", WshShell = new ActiveXObject("WScript.Shell"), url, id, json_url;
var CodePagesTestsDone = false, CodePages = [];
if(url=WSH.Arguments.Named.Item("GetSmotrimData")){
    if(!/:\/\/smotrim\.ru.*\/([^/]+)$/.test(url))WSH.Quit();
    with(str=new ActiveXObject("ADODB.Stream")){Type=2; Mode=3;}
    var oExec = WshShell.Exec((json_url='curl "https://player-api.smotrim.ru/api/v1/video/' + (id=RegExp.$1)) + '"');
    while(!oExec.Status || !oExec.StdOut.AtEndOfStream){
        if(/"title":\s+"([^"]+)"/.test(line = oExec.StdOut.ReadLine()))newText += ". " + DosToWin(RegExp.$1);
        if(/"m3u8":\s+"([^"]+)"/.test(line))var new_url=RegExp.$1;
    }
    if(new_url && id && json_url)WSH.echo(new_url + "," + id + "," + json_url.slice(6));
    if(newText)newText = newText.slice(2);
}
if(WSH.Arguments.Unnamed.Count && (fso.FileExists(fName=WSH.Arguments.Unnamed(0)) || newText)){
    if(1*WSH.Arguments.Named.Item("toUTF-8")){
        var oExec = WshShell.Exec('reg.exe query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\CodePage" -v ACP');
        var Windows_codepage = getCodepageName(oExec);
    } else Windows_codepage = "UTF-8";
    with(new ActiveXObject("ADODB.Stream")){Type=2; Mode=3;
        if(!newText){Open(); Charset=Windows_codepage; LoadFromFile(fName); Position=0; newText=ReadText().replace(/(?:\s*<[^:]*:NA>)?\s*$/g, ""); Close()}
        newText = ((isTemp=/^\d+\.tmp$/.test(fName)) ? newText.replace(/\(/g, "{").replace(/\)/g, "}") : newText.replace(/ *\r\n|\n(\r\n|\n)?/g, "\r\n$1"));
        if(fso.FileExists(fName))fso.DeleteFile(fName);
        Open(); Charset="UTF-8"; Position=0; WriteText(newText + (isTemp ? "" : "\r\n")); SaveToFile(fName); Close();
    }
}
if(1*WSH.Arguments.Named.Item("FORMATRECOMMENDATIONS") && newText){
    var lines = newText.split("\r\n"), recommended_audio_format = "", recommended_video_format = "", recommended_format = "";
    var audio_regexp = "", video_regexp = "", regexp = "", page_specific = {
        "AM_Live":                      [/:\/\/vkvideo\.ru\/video-21732035_/, /(^hls\S+_2\D\S*)\s/, /(^hls\S+)\s.+25 \|/],
        "vkvideo.ru:Mobile-Review.com": [/<vkvideo\.ru:Mobile-Review\.com>/, /(^hls\S+_2\D\S*)\s/, /(^hls\S+)\s.+1920x1080\s+25 \|/],
        "rutube.ru:Константин Кулаков": [/<rutube\.ru:Константин Кулаков>/, /(^default-\S+)\s/]
    }
    for(var lineIndex in lines){
        var line = lines[lineIndex];
        if(lineIndex<=1)for(var i in page_specific)if(page_specific[i][0].test(line))
            if(page_specific[i].length==3){audio_regexp = page_specific[i][1]; video_regexp = page_specific[i][2]; break}
            else {regexp = page_specific[i][1]; break}
        if(regexp && regexp.test(line))recommended_format = RegExp.$1;
        else if(!audio_regexp && !video_regexp && /(^\S+)\s+mp4\s+1920x1080\s+25\D.*m3u8\s+\|\s+(?:unknown\s+unknown|avc1[.\d]+\s+mp4a[.\d]+)(?:\s|$)/.test(line))recommended_format = RegExp.$1;
        if(/audio only/.test(line)){
            if(audio_regexp){if(audio_regexp.test(line))recommended_audio_format = RegExp.$1}
            else if(/(^hls\S+)\s/.test(line))recommended_audio_format = RegExp.$1;
            else if(!/^hls/.test(recommended_audio_format) && /(^\S+)\s+m4a/.test(line))recommended_audio_format = RegExp.$1;
        } else if(/video only/.test(line)){
            if(video_regexp){if(video_regexp.test(line))recommended_video_format = RegExp.$1}
            else if(/(^hls\S+)\s/.test(line))recommended_video_format = RegExp.$1;
            else if(!/^hls/.test(recommended_video_format) && /(^\S+)\s+mp4\s+1920x1080\s+.*avc1/.test(line))recommended_video_format = RegExp.$1;
        }
    }
    if(recommended_format)WSH.echo(recommended_format);
    else WSH.echo(recommended_audio_format && recommended_video_format ? recommended_audio_format + "+" + recommended_video_format : "");
}

function getCodepage(oExec){
    while(!oExec.Status || !oExec.StdOut.AtEndOfStream){
        var new_codepage = /^[\s\S]*(?:REG_SZ|:)\s+(\S+)\s*$/.test(oExec.StdOut.ReadAll()) ? RegExp.$1 : "";
    }
    return new_codepage;
}

function getCodepageName(oExec){
    var commandHead = 'reg.exe query "HKCR\\MIME\\Database\\Codepage\\', codepage, WebCharset;
    oExec = WshShell.Exec(commandHead + (codepage = getCodepage(oExec)) + '" -v BodyCharset'); var tempCodepageName = getCodepage(oExec);
    oExec = WshShell.Exec(commandHead + codepage + '" -v WebCharset'); return (WebCharset = getCodepage(oExec)) ? WebCharset : tempCodepageName;
}
function DosToWin(dosString){
    var result;
    if(!CodePagesTestsDone){
        var oExec = WshShell.Exec('cmd.exe /c chcp');   var DOS_codepage = getCodepageName(oExec);
        oExec = WshShell.Exec('reg.exe query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\CodePage" -v ACP');    var Windows_codepage = getCodepageName(oExec);
        if(DOS_codepage != Windows_codepage)CodePages = [DOS_codepage, Windows_codepage];
        CodePagesTestsDone = true;
    }
    if(!CodePages.length)return dosString;
    with(str){
        Open();
        Charset = CodePages[1];
        WriteText(dosString);
        Position = 0;
        Charset = CodePages[0];
        result = ReadText();
        Close();
    }
    return result;
}