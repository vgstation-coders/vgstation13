::This script generates the hook script for any defined hook steps
::Scripts are kept in the [hook-name]-hooks folder
::The installer generates a master script which loops through the folder and
::executes any scripts it finds there

:: List of client-sided Git hooks
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set BASEDIR=%~dp0

::This is one of the few good ways to get a command output into a var
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
	set REPO_ROOT=%%F
)

FOR /F "tokens=* USEBACKQ" %%G IN (`git rev-parse --git-dir`) DO (
	set REPO_GIT_DIR=%%G
)

for %%h in (applypatch-msg pre-applypatch post-applypatch pre-commit prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-auto-gc post-rewrite pre-push) do (
	::Where the hooks are currently stored
	set HOOKS_FOLDER=%BASEDIR%%%h-hooks
	::The path needs to be built properly with /
	set SH_HOOKS_FOLDER=!HOOKS_FOLDER:\=/!
	
	::The target file for the hook master
	set GIT_HOOKS_FILE="%REPO_GIT_DIR%\hooks\%%h"
	
	::Continue doesn't exist in batch
	IF EXIST !HOOKS_FOLDER! (
		::The master script hasn't been created yet
		IF NOT EXIST !GIT_HOOKS_FILE! (
		set TIMESTAMP=%date%
echo #^^!/bin/sh >> !GIT_HOOKS_FILE!
echo.  >> !GIT_HOOKS_FILE!
echo #Master script autogenerated by install-hooks.bat on !TIMESTAMP! >> !GIT_HOOKS_FILE!
echo #This script runs everything in %%h-hooks as part of the git %%h hook >> !GIT_HOOKS_FILE!
echo #A non-zero exit indicates the script number which was failed on >> !GIT_HOOKS_FILE!
echo.  >> !GIT_HOOKS_FILE!
echo SCRIPT_COUNTER=0 >> !GIT_HOOKS_FILE!
echo for SCRIPT in !SH_HOOKS_FOLDER!/* >> !GIT_HOOKS_FILE!
echo do >> !GIT_HOOKS_FILE!
echo 	echo "Running : $SCRIPT" >> !GIT_HOOKS_FILE!
echo 	SCRIPT_COUNTER=$^(expr $USCOUNTER + 1^) >> !GIT_HOOKS_FILE!
echo 	#If the script file exists and can be executed >> !GIT_HOOKS_FILE!
echo 	if [ -f "$SCRIPT" -a -x "$SCRIPT" ] >> !GIT_HOOKS_FILE!
echo 	then >> !GIT_HOOKS_FILE!
echo 		$SCRIPT >> !GIT_HOOKS_FILE!
echo 		if [ ^^! $? -eq 0 ] >> !GIT_HOOKS_FILE!
echo 		then >> !GIT_HOOKS_FILE!
echo 			echo "Failed : $SCRIPT" >> !GIT_HOOKS_FILE!
echo 			exit $SCRIPT_COUNTER >> !GIT_HOOKS_FILE!
echo 		fi >> !GIT_HOOKS_FILE!
echo 	fi >> !GIT_HOOKS_FILE!
echo done >> !GIT_HOOKS_FILE!
			echo %%h: installed correctly
		) else (
			echo %%h: existing hook found, skipping...
		)
	)
)
ENDLOCAL
