/proc/copy_logs()
	if(config.copy_logs)
		ext_python("copy_logs.py", "data/logs \"[config.copy_logs]\"")

///////////////////////////////////////////////////////////////////////
//Populate bracketed regions and uncomment the following to enable log copy exit codes and IRC notification:
///////////////////////////////////////////////////////////////////////
		// send2mainirc("Copying rounds logs to <WEB LOG LOCATION>")
		// var/exitcode = shell(<LOCAL INSTANCE LOG LOCATION>)
		// switch(exitcode)
		// 	if(null)
		// 		send2mainirc("Copying failed, program failed to run.")
		// 	if(1)
		// 		send2mainirc("Copying successful, program exited with code 1.")
		// 	else
		// 		send2mainirc("Copying partially successful, program exited with code [exitcode].")
