var/list/mentor_datums = list()

/datum/mentors
	var/client/owner	= null
	var/following		= null

/datum/mentors/New(ckey)
	if(!ckey)
		warning("Mentor datum created without a ckey argument. Datum has been deleted")
		del(src)
		return
	mentor_datums[ckey] = src

/datum/mentors/proc/associate(client/C)
	if(istype(C))
		owner = C
		mentors |= C

/datum/mentors/proc/disassociate()
	if(owner)
		mentors -= owner
		owner = null

/client/proc/dementor()
	mentor_datums -= ckey
	return 1

/proc/check_mentor()
	if(usr && usr.client)
		var/mentor = mentor_datums[usr.client.ckey]
		if(mentor)
			return 1

/proc/check_mentor_other(var/client/C)
	if(C)
		var/mentor = mentor_datums[C.ckey]
		if(C.holder && C.holder.rank)
			if(C.holder.rights & R_ADMIN)
				return 1
		else if(mentor)
			return 1
	return 0