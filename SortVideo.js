var fso = new ActiveXObject("Scripting.FileSystemObject"), WshShell = new ActiveXObject("WScript.Shell");
var fn, fc = new Enumerator(fso.GetFolder(".").files);
var list = [], processed_list = [], order = [{"name": "bySize", "pos": 0}, {"name": "byDateLastModified", "pos": 1}, {"name": "byID", "pos": 2}];
for(;!fc.atEnd();fc.moveNext())list.push(fc.item().Name);
for(listIndex in list){
    list_item = list[listIndex];
    if(fso.FileExists(fn=list_item) && /^ts|mkv|mov|mp4$/.test(fso.GetExtensionName(fn))){
        fc = fso.GetFile(list_item); 
        processed_list.push([fn, [fc.Size, fc.DateLastModified, list_item.replace(/^.+\[\+?([^\]]+)\].*$/, "$1")]]);
    }
}
for(orderIndex in order){
    order_item = order[orderIndex];
    processed_list.sort(function (a, b){return (b[1][order_item.pos] == a[1][order_item.pos] ? 0 : (b[1][order_item.pos] > a[1][order_item.pos] ? 1 : -1))});
    if(fso.FolderExists(order_item.name))fso.DeleteFolder(order_item.name, true);
    fso.CreateFolder(order_item.name);
    var i = 1;
    for(processed_listIndex in processed_list){
        processed_list_item = processed_list[processed_listIndex];
        WshShell.Run('fsutil.exe hardlink create "' + order_item.name + "\\" + ("000" + i++).slice(-3) + " " + processed_list_item[0] + '" "' + processed_list_item[0] + '"', 0);
    }
}
WSH.echo(WSH.ScriptName + decodeURIComponent("%3A%20%D0%A1%D0%BF%D0%B8%D1%81%D0%BA%D0%B8%20%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%20%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D1%8B."));