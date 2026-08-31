@set @x=0 /*
@echo off
chcp 65001 >nul
setlocal
:: Договор публичной оферты на оказание услуг технической поддержки.docx: https://disk.yandex.ru/i/9S5LApHY89QuDg
call :update_file "Платёжная информация.html"
call :update_file "Некоторые отсоединённые GnuPG подписи/Платёжная информация.html.sig" /raw
::  Для использования yt-dlp форкните/клонируйте соответствующий репозиторий или скачайте оттуда екзешник: https://github.com/yt-dlp/yt-dlp
:: Он потом будет автоматически обновляться этим батником (при отсутствии проблем с блокированием интернета)
.\yt-dlp.exe -U
call :update_file "Обновить скрипты для скачивания видео.cmd" new
call :update_file y.cmd /coding:Windows-1251 /rep:"^(set test_prev_downloaded=)1$`$10;(^set extension=)\S+$`$1mp4"
call :update_file "Monitor2-2013/refs/heads/main/Video processing/Оглавление.js" https://raw.githubusercontent.com/kvk-2015 /coding:Windows-1251
::call :update_file Search.js
exit /b
::  Если вам будут мной предоставлены в рамках технической поддержки индивидуально настроенные под ваши потребности скрипты,
:: обновить их можно будет при помощи https://download.kde.org/stable/kdiff3/ Методику или сами найдёте, или я подскажу...
:update_file
set head=%2
set is_url=
if -%2- == -new- (set new=.new) else (set new=&if not -%2- == -- (set head=%head:~10%&set is_url=%head:*-=%))
set head=https://kvk-2015.github.io
if -%is_url%- == -2015- set head=%2
set output_file=%1
set output_file=%output_file:*и/=%
set output_file=%output_file:*g/=%
set output_file=%output_file:"=%%new%
del /f "%output_file%.bak" 2>nul
rename ".\%output_file%" "%output_file%.bak" 2>nul
set page=%1
setlocal enabledelayedexpansion
set page=!page: =%%20!
setlocal disabledelayedexpansion
set page=%page:"=%
curl.exe --output ".\%output_file%" %head%/%page%
if not defined new cscript /nologo /e:javascript "%~dpnx0" ".\%output_file%" %2 %3 %4 %5 %6 %7 %8 %9
goto:eof */

// Для скачанного скрипта можно выполнить патчинг согласно вашим предпочтениям

if(WSH.Arguments.Named.Exists("raw"))WSH.Quit();
var fso = new ActiveXObject("Scripting.FileSystemObject"), WshShell = new ActiveXObject("WScript.Shell"), newText, CodePagesTestsDone = false, CodePages = [];
var str, coding = WSH.Arguments.Named.Item("coding"), processing = [], pair, lineIndex, line, lines, splitter = "`";

with(str = new ActiveXObject("ADODB.Stream")){Type = 2; Mode = 3;}

if(WSH.Arguments.Unnamed.Count && (fso.FileExists(scriptName=WSH.Arguments.Unnamed(0)))){
    if(rep=WSH.Arguments.Named.Item("rep")){
        lines = rep.split(";");
        for(lineIndex in lines){
            pair = lines[lineIndex].split(splitter);
            if(pair.length != 2)WSH.echo(DosToWin("\r\nОшибка в правиле: " + lines[lineIndex] + " - между шаблоном поиска и замены должен быть разделитель '" + splitter + "'...\r\n"));
            processing.push([new RegExp(pair[0]), pair[1]]);
        }
    }
    with(new ActiveXObject("ADODB.Stream")){Type = 2; Mode = 3;
        if(coding || processing){Open(); Charset = "utf-8"; LoadFromFile(scriptName); Position = 0; newText=ReadText().replace(/\r\n|\n|\r/g, "\r\n"); Close();
            lines = newText.split("\r\n"); newText = "";
            for(lineIndex in lines){
                line = lines[lineIndex];
                for(var i=0; i<processing.length; i++)line = line.replace(processing[i][0], processing[i][1]);
                newText += "\r\n" + line;
            }
            Open(); Charset = coding || "utf-8"; Position = 0; WriteText(newText.slice(2)); SaveToFile(scriptName, 2); Close();
            if(!coding){
                Mode = 3; Type = 1; Open(); LoadFromFile(scriptName); Position = 3;
                var new_stream = new ActiveXObject("ADODB.Stream");
                new_stream.Mode = 3; new_stream.Type = 1; new_stream.Open(); CopyTo(new_stream); Close();
                new_stream.SaveToFile(scriptName, 2); new_stream.Close();
            }
        }
    }
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
        if(DOS_codepage != Windows_codepage)CodePages = ["utf-8" || DOS_codepage, Windows_codepage];
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