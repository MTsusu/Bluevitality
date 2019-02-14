Dim RunKcptun
Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")
currentPath = fso.GetFile(Wscript.ScriptFullName).ParentFolder.Path & "\"
exeConfig = "client_windows_amd64.exe -c conf.json"
logFile = "kcptun.log"
cmdLine = "cmd /c " & currentPath & exeConfig  & " > " & currentPath & logFile & " 2>&1"
WshShell.Run cmdLine, 0, False
'等待1秒
'WScript.Sleep 1000
'打印运行命令
'Wscript.echo cmdLine
Set WshShell = Nothing
Set fso = Nothing
WScript.quit
