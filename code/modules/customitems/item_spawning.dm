
/proc/EquipCustomItems(mob/living/carbon/human/M)
	if(!SSdbcore.Connect())
		return

	// SCHEMA
	/**
	* customitems
	*
	* cuiCKey VARCHAR(36) NOT NULL,
	* cuiRealName VARCHAR(60) NOT NULL,
	* cuiPath VARCHAR(255) NOT NULL,
	* cuiDescription TEXT NOT NULL,
	* cuiReason TEXT NOT NULL,
	* cuiPropAdjust TEXT NOT NULL,
	* cuiJobMask TEXT NOT NULL,
	* PRIMARY KEY(cuiCkey,cuiRealName,cuiPath)
	*/

	// Grab the info we want.
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT cuiPath, cuiPropAdjust, cuiJobMask FROM customitems WHERE cuiCKey=:ckey AND (cuiRealName=:real_name OR cuiRealName='*')",
		list(
			"ckey" = "[M.ckey]",
			"real_name" = "[M.real_name]"
	))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		ApplyCustomItem(M, query.item[1], query.item[2], query.item[3])
	qdel(query)

// batch custom item db lookup rather than calling one by one at roundstart for redaied players
/proc/GetCustomItemsByCkey(list/ckeys)
	if(!ckeys || !ckeys.len)
		return list()
	if(!SSdbcore.Connect())
		return null

	var/list/in_placeholders = list()
	var/list/arguments = list()
	for(var/i = 1, i <= ckeys.len, i++)
		in_placeholders += ":ckey_[i]"
		arguments["ckey_[i]"] = "[ckeys[i]]"

	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT cuiCKey, cuiRealName, cuiPath, cuiPropAdjust, cuiJobMask FROM customitems WHERE cuiCKey IN ([in_placeholders.Join(", ")])", arguments)
	if(!query.Execute())
		log_sql("DB Error: [query.ErrorMsg()]")
		qdel(query)
		return null

	var/list/by_ckey = list()
	while(query.NextRow())
		var/row_ckey = ckey("[query.item[1]]")
		var/list/rows = by_ckey[row_ckey]
		if(!rows)
			rows = list()
			by_ckey[row_ckey] = rows
		rows += list(list(query.item[2], query.item[3], query.item[4], query.item[5]))
	qdel(query)
	return by_ckey

// pass key separately because still not assigned to M at this stage
/proc/EquipCustomItemsPrefetched(mob/living/carbon/human/M, player_key, list/by_ckey)
	if(!player_key || !islist(by_ckey))
		return
	var/list/rows = by_ckey[ckey(player_key)]
	if(!rows)
		return
	for(var/list/row in rows)
		if(row[1] != "*" && lowertext(row[1]) != lowertext(M.real_name))
			continue
		ApplyCustomItem(M, row[2], row[3], row[4])

/proc/ApplyCustomItem(mob/living/carbon/human/M, path_text, propadjust, jobmask)
	var/path = text2path(path_text)
	var/ok=0
	if(jobmask!="*")
		var/allowed_jobs = splittext(jobmask,",")
		var/alt_blocked=0
		if(M.mind.role_alt_title)
			if(!(M.mind.role_alt_title in allowed_jobs))
				alt_blocked=1
		if(!(M.mind.assigned_role in allowed_jobs) || alt_blocked)
			return

	var/obj/item/Item = new path()
	if(istype(Item,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = Item
		for(var/obj/item/weapon/card/id/C in M)
			//default settings
			I.name = "[M.real_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
			I.registered_name = M.real_name
			I.access = C.access
			I.assignment = C.assignment
			I.blood_type = C.blood_type
			I.dna_hash = C.dna_hash
			I.fingerprint_hash = C.fingerprint_hash
			//replace old ID
			QDEL_NULL(C)
			ok = M.equip_if_possible(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
			break
	else if(istype(M.back, /obj/item/weapon/storage)) // Try to place it in something on the mob's back
		var/obj/item/weapon/storage/backpack = M.back
		if(backpack.contents.len < backpack.storage_slots)
			Item.forceMove(M.back)
			ok = 1
			to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [M.back.name].</span>")
	else
		for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
			if (S.contents.len < S.storage_slots)
				Item.forceMove(S)
				ok = 1
				to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [S.name].</span>")
				break

	if (ok == 0) // Finally, since everything else failed, place it on the ground
		Item.forceMove(get_turf(M.loc))

	HackProperties(Item,propadjust)

	// This is hacky, but since it's difficult as fuck to make a proper parser in BYOND without killing the server, here it is. - N3X
/proc/HackProperties(var/mob/living/carbon/human/M,var/obj/item/I,var/script)
	/*
	A=string:b lol {REALNAME} {ROLE} {ROLE_ALT};
	B=icon:icons/dmi/lol.dmi:STATE;
	B=number:29;
	*/
	var/list/statements=splittext(script,";")
	if(statements.len==0)
		return // Don't even bother.
	for(var/statement in statements)
		var/list/assignmentChunks = splittext(statement,"=")
		var/varname = assignmentChunks[1]
		//var/operator = "="

		var/list/typeChunks=splittext(script,":")
		var/desiredType=typeChunks[1]
		//var/value
		switch(desiredType)
			if("string")
				var/output = typeChunks[2]
				output = replacetext(output,"{REALNAME}", M.real_name)
				output = replacetext(output,"{ROLE}",     M.mind.assigned_role)
				output = replacetext(output,"{ROLE_ALT}", "[M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role]")
				I.vars[varname]=output
			if("number")
				I.vars[varname]=text2num(typeChunks[2])
			if("icon")
				if(typeChunks.len==2)
					I.vars[varname]=new /icon(typeChunks[2])
				if(typeChunks.len==3)
					I.vars[varname]=new /icon(typeChunks[2],typeChunks[3])
