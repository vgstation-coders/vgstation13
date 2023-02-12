
/proc/EquipCustomItems(mob/living/carbon/human/M)
//	testing("\[CustomItem\] Checking for custom items for [M.ckey] ([M.real_name])...")
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
		var/path = text2path(query.item[1])
		var/propadjust = query.item[2]
		var/jobmask = query.item[3]
//		testing("\[CustomItem\] Setting up [path] for [M.ckey] ([M.real_name]).  jobmask=[jobmask];propadjust=[propadjust]")
		var/ok=0
		if(jobmask!="*")
			var/allowed_jobs = splittext(jobmask,",")
			var/alt_blocked=0
			if(M.mind.role_alt_title)
				if(!(M.mind.role_alt_title in allowed_jobs))
					alt_blocked=1
			if(!(M.mind.assigned_role in allowed_jobs) || alt_blocked)
//				testing("Failed to apply custom item for [M.ckey]: Role(s) [M.mind.assigned_role][M.mind.role_alt_title ? " (nor "+M.mind.role_alt_title+")" : ""] are not in allowed_jobs ([english_list(allowed_jobs)])")
				continue


		var/obj/item/Item = new path()
//		testing("Adding new custom item [query.item[1]] to [key_name_admin(M)]...")
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
				//I.pin = C.pin
				//replace old ID
				QDEL_NULL(C)
				ok = M.equip_if_possible(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
				break
//			testing("Replaced ID!")
		else if(istype(M.back, /obj/item/weapon/storage)) // Try to place it in something on the mob's back
			var/obj/item/weapon/storage/backpack = M.back
			if(backpack.contents.len < backpack.storage_slots)
				Item.forceMove(M.back)
				ok = 1
	//			testing("Added to [M.back.name]!")
				to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [M.back.name].</span>")
		else
			for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
				if (S.contents.len < S.storage_slots)
					Item.forceMove(S)
					ok = 1
//					testing("Added to [S]!")
					to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [S.name].</span>")
					break

		//skip:
		if (ok == 0) // Finally, since everything else failed, place it on the ground
//			testing("Plopped onto the ground!")
			Item.forceMove(get_turf(M.loc))

		HackProperties(Item,propadjust)
	qdel(query)

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
