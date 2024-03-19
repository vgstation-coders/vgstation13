/proc/return_revision()
	return file2text(".git/refs/heads/Bleeding-Edge")

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	var/output = return_revision() || "Unable to load revision info from HEAD"

	output += {"Current Infomational Settings: <br>
		BYOND version of server: [world.byond_version].[world.byond_build]<br>
		Protect Authority Roles From Tratior: [config.protect_roles_from_antagonist]<br>"}
	usr << browse(output,"window=revdata");
	return
