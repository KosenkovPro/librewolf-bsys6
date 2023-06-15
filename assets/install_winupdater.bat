@echo "Installing Windows Updater for %USERNAME%"
@echo
@echo "Copying LibreWolf-WinUpdater.exe"
copy /y "%ProgramFiles%\LibreWolf\LibreWolf-WinUpdater.exe" "%APPDATA%\LibreWolf\LibreWolf-WinUpdater.exe"
@echo "Creating shortcut"
mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\LibreWolf"
shortcut.exe /t "%APPDATA%\LibreWolf\LibreWolf-WinUpdater.exe" /d "%APPDATA%\LibreWolf" /i "%APPDATA%\LibreWolf\LibreWolf-WinUpdater.exe" /n "%APPDATA%\Microsoft\Windows\Start Menu\Programs\LibreWolf\LibreWolf WinUpdater.lnk"