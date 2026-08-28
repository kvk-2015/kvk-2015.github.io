@set @x=0 /*
@echo off
chcp 65001 >nul
.\yt-dlp.exe -U
call :update_script y.cmd /coding:Windows-1251 /rep:"^(set test_prev_downloaded=)1$`$10;(^set extension=)\S+$`$1mp4"
::call :update_script Search.js
exit /b
:update_script
del /f %1.bak 2>nul
rename .\%1 %1.bak 2>nul
curl.exe  --output .\%1 https://kvk-2015.github.io/%1
cscript /nologo /e:javascript "%~dpnx0" %*
goto:eof */

// Для скачанного скрипта можно выполнить патчинг согласно вашим предпочтениям

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
    with(new ActiveXObject("ADODB.Stream")){Type=2; Mode=3;
        if(coding || processing){Open(); Charset="utf-8"; LoadFromFile(scriptName); Position=0; newText=ReadText().replace(/\r\n|\n|\r/g, "\r\n"); Close();
            lines = newText.split("\r\n"); newText = "";
            for(lineIndex in lines){
                line = lines[lineIndex];
                for(var i=0; i<processing.length; i++)line = line.replace(processing[i][0], processing[i][1]);
                newText += "\r\n" + line;
            }
            if(fso.FileExists(scriptName))fso.DeleteFile(scriptName);
            Open(); Charset=coding || "utf-8"; Position=0; WriteText(newText.slice(2)); SaveToFile(scriptName); Close();
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