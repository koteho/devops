E:
cd E:\QA_BACKUPS
FORFILES /S /D -30 /C "cmd /c IF @isdir == TRUE rd /S /Q @path"