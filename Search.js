//  Проверка не просматривали ли уже видео, скачанное недавно при помощи yt-dlp (имена файлов, из которых для целей поиска выделяется только id,
// передаются в виде параметров командной строки). Предполагается, что просмотренные видео удаляются вручную из истории файлов Windows 10 из-за сбоев,
// в то же время информация о них продолжает присутствовать в базе данных.
// Если contains_only = true, просто проверяется наличие указанного id в базе, а не сравнение отдалённости по оси времени условно.

var fso = new ActiveXObject("Scripting.FileSystemObject"), WshShell = new ActiveXObject("WScript.Shell"), s = "", i;
var contains_only = true, head = decodeURIComponent("%C3%BE%D0%81%C5%80");
with(fso)if(FileExists(fn=WshShell.ExpandEnvironmentStrings("Y:\\%USERNAME%\\%USERDOMAIN%\\Configuration\\Catalog1.edb")))
    with(OpenTextFile(fn, 1, false, -1)){dbase = ReadAll(); Close()} else WSH.Quit();
with(WSH.Arguments)for(i=0; i<length; i++)if(fso.FileExists(fn=Item(i))){
    var result, found = false, index = contains_only, prev_names = [];
    var re = new RegExp(head + "([^" + head.slice(0, 1) + "]+\\[\\+?" + fn.replace(/^.+\[\+?/, "").replace(/\]\..+$/,
        "\\]([\\._\\-a-z0-9]{4,})?[\\.!a-z0-9]+((?:\\.part(?:[\\-a-zA-Z0-9]*))?))"), "g");
    while(result=re.exec(dbase))if(!RegExp.$2 && !RegExp.$3 && result.lastIndex - index > 1024){
        prev_names.push(RegExp.$1 + "\n"); found |= index; index = result.lastIndex;
    }
    if(found)s += "\n------\n" + (contains_only ? prev_names : prev_names.slice(0, -1)).join("") + fn;
}
if(s)WSH.Quit(WshShell.popup(s.slice(1), 0, WSH.ScriptFullName, 1));
