
/*

* /proc/prepare_cult_holomap
* /datum/station_holomap/cult/initialize_holomap
* /obj/item/proc/get_cult_power
* /mob/proc/get_cult_power
* /mob/proc/occult_muted
* /mob/proc/get_convertibility
* /mob/living/carbon/get_convertibility
* /mob/living/carbon/proc/update_convertibility
* /mob/living/carbon/proc/implant_pop
* /mob/living/carbon/proc/boxify
* ///proc/spawn_bloodstones

*/

//Instead of updating in realtime, cult holomaps update every time you check them again, saves some CPU.
/proc/prepare_cult_holomap()
	var/image/I = image(extraMiniMaps[HOLOMAP_EXTRA_CULTMAP])
	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		var/image/markerImage = image(holomarker.icon,holomarker.id)
		markerImage.color = holomarker.color
		if(holomarker.z == map.zMainStation && holomarker.filter & HOLOMAP_FILTER_CULT)
			if(map.holomap_offset_x.len >= map.zMainStation)
				markerImage.pixel_x = holomarker.x-8+map.holomap_offset_x[map.zMainStation]
				markerImage.pixel_y = holomarker.y-8+map.holomap_offset_y[map.zMainStation]
			else
				markerImage.pixel_x = holomarker.x-8
				markerImage.pixel_y = holomarker.y-8
			markerImage.appearance_flags = RESET_COLOR
			I.overlays += markerImage
	return I

/datum/station_holomap/cult/initialize_holomap(var/turf/T, var/isAI=null, var/mob/user=null, var/cursor_icon = "bloodstone-here")
	station_map = image(extraMiniMaps[HOLOMAP_EXTRA_CULTMAP])
	cursor = image('icons/holomap_markers.dmi', cursor_icon)

/obj/item/proc/get_cult_power()
	return 0

var/static/list/valid_cultpower_slots = list(
	slot_wear_suit,
	slot_head,
	slot_shoes,
	)//might add more slots later as I add more items that could fit in them

/*	get_cult_power
	returns: the combined cult power of every item worn by src.

*/
/mob/proc/get_cult_power()
	var/power = 0
	for (var/slot in valid_cultpower_slots)
		var/obj/item/I = get_item_by_slot(slot)
		if (istype(I))
			power += I.get_cult_power()

	return power

/mob/proc/occult_muted()
	if (reagents && reagents.has_reagent(HOLYWATER))
		return 1
	if (is_implanted(/obj/item/weapon/implant/holy))
		return 1
	return 0

/mob/proc/get_convertibility()
	if (!mind || isDead())
		return CONVERTIBLE_NOMIND

	if (iscultist(src))
		return CONVERTIBLE_ALREADY

	return 0

/mob/living/carbon/get_convertibility()
	var/convertibility = ..()

	if (!convertibility)
		//TODO: chaplain stuff
		//this'll do in the meantime
		if (mind.assigned_role == "Chaplain")
			return CONVERTIBLE_NEVER

		var/acceptance = "Never"
		if (client)
			acceptance = get_role_desire_str(client.prefs.roles[CULTIST])

		if (jobban_isbanned(src, CULTIST) || isantagbanned(src) || (acceptance == "Never"))
			return CONVERTIBLE_NEVER

		if (is_loyalty_implanted())
			return CONVERTIBLE_IMPLANT

		if (acceptance == "Always" || acceptance == "Yes")
			return CONVERTIBLE_ALWAYS

		return CONVERTIBLE_CHOICE

	return convertibility//no mind, dead, or already a cultist

/mob/living/carbon/proc/update_convertibility()
	var/convertibility = get_convertibility()
	var/image/I =  new/image/hud('icons/mob/hud.dmi', src, "hudblank")
	switch(convertibility)
		if (CONVERTIBLE_ALWAYS)
			I.icon_state = "convertible"
		if (CONVERTIBLE_CHOICE)
			I.icon_state = "maybeconvertible"
		if (CONVERTIBLE_IMPLANT)
			I.icon_state = "unconvertible"
		if (CONVERTIBLE_NEVER)
			I.icon_state = "unconvertible2"

	I.pixel_y = 16 * PIXEL_MULTIPLIER
	I.plane = ANTAG_HUD_PLANE
	I.appearance_flags |= RESET_COLOR|RESET_ALPHA

	//inspired from the rune color matrix because boy am I proud of it
	animate(I, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 2)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1.7)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1.4)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1.1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.8)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.5)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.2)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.1)//2
	animate(color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 5)//1

	hud_list[CONVERSION_HUD] = I


/mob/living/carbon/proc/implant_pop()
	for(var/obj/item/weapon/implant/loyalty/I in src)
		if (I.imp_in)
			to_chat(src, "<span class='sinister'>Your blood pushes back against the loyalty implant, it will visibly pop out within seconds!</span>")
			spawn(10 SECONDS)
				if (I.remove())
					visible_message("<span class='warning'>\The [I] pops out of \the [src]'s head.</span>")


/mob/living/carbon/proc/boxify(var/delete_body = TRUE, var/new_anim = TRUE, var/box_state = "cult")//now its own proc so admins may atomProcCall it if they so desire.
	var/turf/T = get_turf(src)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'sound/effects/convert_failure.ogg', 75, 0, -4)
	if (new_anim)
		var/obj/effect/cult_ritual/conversion/anim = new(T)
		anim.icon_state = ""
		flick("rune_convert_failure",anim)
		anim.Die()
	var/obj/item/weapon/storage/cult/coffer = new(T)
	coffer.icon_state = box_state
	var/obj/item/weapon/reagent_containers/food/drinks/cult/cup = new(coffer)
	if (istype(src,/mob/living/carbon/human) && dna)
		take_blood(cup, cup.volume)//Up to 60u
		cup.on_reagent_change()//so we get the reagentsfillings overlay
		new/obj/item/weapon/skull(coffer)
	if (ismonkey(src))
		var/list/skulless_monkeys = list(
			/mob/living/carbon/monkey/mushroom,
			/mob/living/carbon/monkey/diona,
			/mob/living/carbon/monkey/rock,
			)
		var/mob/living/carbon/monkey/M = src
		if (!(M.species_type in skulless_monkeys))
			take_blood(cup, cup.volume)//Up to 60u
			new/obj/item/weapon/skull(coffer)
	if (isslime(src))
		cup.reagents.add_reagent(SLIMEJELLY, 50)
	if (isalien(src))//w/e
		cup.reagents.add_reagent(RADIUM, 50)

	for(var/obj/item/weapon/implant/loyalty/I in src)
		I.remove(src)

	for(var/obj/item/I in src)
		u_equip(I)
		if(I)
			I.forceMove(T)
			I.reset_plane_and_layer()
			I.dropped(src)
			I.forceMove(coffer)
	if (delete_body)
		qdel(src)


/* Used in Cult 3.0 to get bloodstone spawn location. Might use that bit of code for something else later so I'll keep it there in the meantime.
/proc/spawn_bloodstones(var/turf/source = null)
	//Called at the beginning of ACT III, this is basically the cult's declaration of war on the crew
	//Spawns 4 structures, one in each quarters of the station
	//When spawning, those structures break and convert stuff around them, and add a wall layer in case of space exposure.
	var/list/places_to_spawn = list()
	for (var/i = 1 to 4)
		for (var/j = 10; j > 0; j--)
			/*
			the value of i governs which corner of the map the bloodstone will try to spawn in.
			from 1 to 4, the corners will be selected in this order: North-West, South-East, North-East, South-West

			the higher j, the further away from the center of the map will the bloodstone be. it tries 10 times per bloodstone, and searches each time closer to the center
			*/
			var/coordX = map.center_x+j*4*(((round(i/2) % 2) == 0) ? -1 : 1 )
			var/coordY = map.center_y+j*4*(((i % 2) == 0) ? -1 : 1 )

			var/turf/T = get_turf(pick(range(j*3,locate(coordX,coordY,map.zMainStation))))
			if (!T)
				message_admins("Blood Cult: !ERROR! spawn_bloodstones() tried to select a null turf at [map.nameLong]. Debug info: i = [i], j = [j]")
				log_admin("Blood Cult: !ERROR! spawn_bloodstones() tried to select a null turf at [map.nameLong]. Debug info: i = [i], j = [j]")
			else if(!is_type_in_list(T,list(/turf/space,/turf/unsimulated,/turf/simulated/shuttle)))
				//Adding some blacklisted areas, specifically solars
				if (!istype(T.loc,/area/solar) && is_type_in_list(T.loc,the_station_areas))
					places_to_spawn += T
					break
	//A 5th bloodstone will spawn if a proper turf was given as arg (up to 100 tiles from the station center, and not in space or on a shuttle)
	if (source && (source.z == map.zMainStation) && !isspace(source.loc) && !is_on_shuttle(source) && get_dist(locate(map.center_x,map.center_y,map.zMainStation),source)<100)
		places_to_spawn.Add(source)
	for (var/T in places_to_spawn)
		new /obj/structure/cult/bloodstone(T)

	//Cultists can use those bloodstones to locate the rest of them, they work just like station holomaps

	for(var/obj/structure/cult/bloodstone/B in bloodstone_list)
		if (!B.loc)
			qdel(B)
			message_admins("Blood Cult: !ERROR! A blood stone was somehow spawned in nullspace. It has been destroyed.")
			log_admin("Blood Cult: !ERROR! A blood stone was somehow spawned in nullspace. It has been destroyed.")
*/
