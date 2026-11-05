// SortVideo.js — утилита для сортировки видеофайлов в текущей папке.
// Создаёт подпапки bySize, byDateLastModified, byID с хардлинками
// (без копирования). Работает только с локальными файлами.
// Демонстрация применения скрипта в ВК Видео моего Сообщества: https://vkvideo.ru/video-225923287_456239036
// и на RUTUBE: https://rutube.ru/video/16e5b6adaf0089f114d2241048a2e618/
var fso = new ActiveXObject("Scripting.FileSystemObject"), WshShell = new ActiveXObject("WScript.Shell");
var fn, fc = new Enumerator(fso.GetFolder(".").files);
var list = [], order = [{"name": "bySize", "pos": 0}, {"name": "byDateLastModified", "pos": 1}, {"name": "byID", "pos": 2}];
for(;!fc.atEnd();fc.moveNext())if(/^(?:ts|mkv|mov|mp4)$/.test(fso.GetExtensionName(fn=fc.item().Name)))list.push([fn, []]);
for(listIndex in list){
    list_item = list[listIndex];
    if(fso.FileExists(fn=list_item[0])){fc = fso.GetFile(fn);
        list_item[1].push(fc.Size, fc.DateLastModified, parseInt(fn.replace(/^.+\[[+\-]?([^\]]+)\].*$/, "$1").replace(/[_]/g, ""), 10) || RegExp.$1);
    }
}
for(orderIndex in order){
    order_item = order[orderIndex];
    list.sort(function (a, b){return (b[1][order_item.pos] == a[1][order_item.pos] ? 0 : (b[1][order_item.pos] > a[1][order_item.pos] ? 1 : -1))});
    var i = 1;  if(fso.FolderExists(order_item.name))fso.DeleteFolder(order_item.name, true);   fso.CreateFolder(order_item.name);
    for(listIndex in list){
        list_item = list[listIndex];
        WshShell.Run('fsutil.exe hardlink create "' + order_item.name + "\\" + ("000" + i++).slice(-3) + " " + list_item[0] + '" "' + list_item[0] + '"', 0);
    }
}
WSH.echo(WSH.ScriptName + decodeURIComponent("%3A%20%D0%A1%D0%BF%D0%B8%D1%81%D0%BA%D0%B8%20%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%20%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D1%8B."));