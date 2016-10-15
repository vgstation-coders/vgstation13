/client/proc/mentor_follow(var/mob/living/M)
	if(!check_mentor())
		return

	if(isnull(M))
		return

	if(!istype(usr, /mob))
		return

	usr.client.adminobs = 1
	usr.reset_view(M)

	admins << "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is now following <EM>[key_name(M)]</span>"
	log_mentor("[key_name(usr)] began following [key_name(M)]")

	alert("Click to cease following.", "Mentor Follow")

	usr.client.adminobs = 0
	usr.reset_view(null)

	admins << "<span class='mentor'><span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(M)]</span>"
	log_mentor("[key_name(usr)] stopped following [key_name(M)]")
