REM From TGstation: https://github.com/tgstation/tgstation/tree/master/tools/dmi

@call "%~dp0\..\bootstrap\python.bat" -m dmi.merge_driver --posthoc %*
@pause
