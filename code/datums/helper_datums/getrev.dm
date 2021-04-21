/proc/return_revision()
	var/output =  "Sorry, the revision info is unavailable."
	output = file2text(".git/refs/heads/Bleeding-Edge")
	if(!output || output == "")
		output = "Unable to load revision info from HEAD"
	return output

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	var/output =  "Sorry, the revision info is unavailable."
	output = file2text(".git/refs/heads/Bleeding-Edge")
	if(!output || output == "")
		output = "Unable to load revision info from HEAD"

	output += {"Current Infomational Settings: <br>
		Protect Authority Roles From Tratior: [config.protect_roles_from_antagonist]<br>"}
	usr << browse(output,"window=revdata");
	return
