@echo off
call "%~dp0\..\tools\build\build.bat" --wait-on-error tgui-dev %*
