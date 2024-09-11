@echo off
set "source=%1"
set "destination=%~dp1"
"C:\Program Files\7-Zip\7z.exe" x "%source%" -o"%destination%"