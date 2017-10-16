// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this.</span>")
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Transport back to your core."

	if(blob_core)
		src.forceMove(blob_core.loc)

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= blob_nodes.len; i++)
			nodes["Blob Node #[i]"] = blob_nodes[i]
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/effect/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.forceMove(chosen_node.loc)

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob"
	set desc = "Create a shield blob."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(var/turf/T)


	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	if(!can_buy(BLOBSHICOST))
		return


	B.change_to(/obj/effect/blob/shield)
	return



/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/resource/blob in orange(4, T))
		to_chat(src, "There is a resource blob nearby, move more than 4 tiles away from it!")
		return

	if(!can_buy(BLOBRESCOST))
		return


	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate() in T
	if(R)
		R.overmind = src
		special_blobs += R
		update_specialblobs()
	return

/mob/camera/blob/proc/create_core()
	set category = "Blob"
	set name = "Create Core Blob"
	set desc = "Create another Core Blob to aid in the station takeover"


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/core/blob in orange(15))
		to_chat(src, "There is another core blob nearby, move more than 15 tiles away from it!")
		return
	var/number_of_cores = blob_cores.len
	var/cost = BLOBCOREBASECOST+(BLOBCORECOSTINC*(number_of_cores-1))

	if(!can_buy(cost))
		to_chat(src, "Current cost of a blob core is [cost]!")
		return


	B.change_to(/obj/effect/blob/core, src)

	return

/mob/camera/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/node/blob in orange(5, T))
		to_chat(src, "There is another node nearby, move more than 5 tiles away from it!")
		return

	if(!can_buy(BLOBNODCOST))
		return


	B.change_to(/obj/effect/blob/node)
	var/obj/effect/blob/node/N = locate() in T
	if(N)
		N.overmind = src
		special_blobs += N
		update_specialblobs()
		max_blob_points += BLOBNDPOINTINC
	return


/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/factory/blob in orange(7, T))
		to_chat(src, "There is a factory blob nearby, move more than 7 tiles away from it!")
		return

	if(!can_buy(BLOBFACCOST))
		return

	B.change_to(/obj/effect/blob/factory)
	var/obj/effect/blob/factory/F = locate() in T
	if(F)
		F.overmind = src
		special_blobs += F
		update_specialblobs()
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob."

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(istype(B, /obj/effect/blob/core))
		to_chat(src, "Unable to remove this blob.")
		return

	B.manual_remove = 1
	B.Delete()
	return

/mob/camera/blob/verb/callblobs()
	set category = "Blob"
	set name = "Call Overminds"
	set desc = "Prompts your fellow overminds to come at your location."

	var/turf/T = get_turf(src)
	if(!T)
		return

	to_chat(src,"<span class='notice'>You sent a call to the other overminds...</span>")

	var/they_exist = 0
	for(var/mob/camera/blob/O in blob_overminds)
		if(O != src)
			they_exist++
			to_chat(O,"<span class='notice'>[src] is calling for your attention!</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")

	if(they_exist)
		to_chat(src,"<span class='notice'>...[they_exist] overmind\s heard your call!</span>")
	else
		to_chat(src,"<span class='notice'>...but no one heard you!</span>")

	return


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(var/turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = locate() in T
	if(B)
		to_chat(src, "There is a blob here!")
		return

	var/obj/effect/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "There is no blob adjacent to you.")
		return

	if(!can_buy(BLOBATTCOST))
		return
	OB.expand(T, 0)
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores"
	set desc = "Rally the spores to move to your location."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(var/turf/T)


	if(!can_buy(BLOBRALCOST))
		return

	to_chat(src, "You rally your spores.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blobspore/BS in living_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/telepathy_power()
	set category = "Blob"
	set name = "Psionic Message"
	set desc = "Give a psionic message to all creatures on and around your 'local' vicinity."
	telepathy()

/mob/camera/blob/proc/telepathy(message as text)

	if(!can_buy(BLOBTAUNTCOST))
		return


	to_chat(src.z, "<span class='warning'>Your vision becomes cloudy, and your mind becomes clear.</span>")
	spawn(5)
	to_chat(src.z, "<span class='blob'>[message]</span>") //Only sends messages to things on its own z level
	add_gamelogs(src, "used blob telepathy to convey \"[message]\"", tp_link = TRUE)
	log_blobtelepathy("[key_name(usr)]: [message]")
