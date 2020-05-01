/**
	Makes an instant station
**/

/obj/item/weapon/grenade/station
	name = "Syndicate pocket sat"
	desc = "A pocket satellite for your nefarious deeds. Find a nice empty space to prime and set it down - don't be right under it when you trigger it."
	var/range = 7
	var/walltype = /turf/simulated/wall/syndicate
	var/floortype = /turf/simulated/floor/dark
	var/doortype = /obj/structure/airshield
	var/soundpath = 'sound/effects/bumpinthenight.ogg'

/obj/item/weapon/grenade/station/prime()
	playsound(src, soundpath, 75, 1)
	var/turf/source = get_turf(src)
	for(var/mob/living/M in view(source, range))
		if(get_turf(M) == source)
			below_center(M)
			continue
		under_edge(M, source)
	decorate(generate_room(source, range, walltype, floortype, doortype))
	centerpiece(source)
	qdel(src)

/proc/get_empty_cardinal(var/turf/T)
	var/list/trydir = cardinal.Copy()
	while(trydir.len)
		pick_n_take(trydir)
		var/turf/U = get_step(T,trydir)
		if(!U.contents.len)
			return U
	return null

/obj/item/weapon/grenade/station/proc/decorate(var/list/interior)
	var/list/possible_gear = list(/obj/machinery/optable,/obj/machinery/computer/security/selfpower,/obj/machinery/computer/crew/selfpower,/obj/structure/rack,/obj/machinery/recharger, /obj/machinery/sleeper, /obj/machinery/station_map/strategic)
	var/list/put_gear_here = interior.Copy()
	//First, go around looking for empty spaces and throw in gear
	while(possible_gear.len)
		var/turf/T = pick_n_take(put_gear_here)
		if(T.contents.len)
			continue
		var/objpath = pick_n_take(possible_gear)
		new objpath(T)
		switch(objpath)
			if(/obj/machinery/optable) //place a computer
				var/turf/U = get_empty_cardinal(T)
				if(U)
					var/obj/O = new /obj/machinery/computer/operating/selfpower(U)
					O.dir = get_dir(O,T)

			if(/obj/machinery/computer/security/selfpower,/obj/machinery/computer/crew/selfpower) //make a chair
				var/turf/U = get_empty_cardinal(T)
				if(U)
					var/obj/O = new /obj/structure/bed/chair/comfy/black(U)
					O.dir = get_dir(O,T)

			if(/obj/structure/rack) //some gear here
				new /obj/item/clothing/under/syndicate/tacticool(T)
				new /obj/item/clothing/mask/gas/syndicate(T)
				new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical(T)
				new /obj/item/clothing/gloves/swat(T)
				new /obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating(T)
				new /obj/item/weapon/storage/toolbox/syndicate(T)
				new /obj/item/clothing/accessory/storage/bandolier(T)

			if(/obj/machinery/recharger) //place a table under
				new /obj/structure/table/reinforced(T)
	//Fill in 5% of the leftover spaces with potted plants
	for(var/turf/T in put_gear_here)
		if(!T.contents.len && prob(5))
			new /obj/structure/flora/pottedplant/random(T)



/obj/item/weapon/grenade/station/proc/below_center(mob/M)
	M.gib()

/obj/item/weapon/grenade/station/proc/under_edge(mob/M, turf/source)
	var/turf/T = get_turf(M)
	T.turf_animation('icons/effects/effects.dmi',"at_shield2")
	to_chat(M, "<span class='sinister'>The Syndicate Satellite beeps, \"Welcome aboard\".</span>")

/obj/item/weapon/grenade/station/proc/centerpiece(var/turf/source)
	new /obj/item/beacon(source)

/obj/item/weapon/grenade/station/discount
	name = "Discount Dan's Inflatable Station-in-a-Can"
	desc = "Packed full of inflatable bits! Do not chew."
	walltype = /obj/structure/inflatable/wall
	floortype = /turf/simulated/floor/inflatable/air
	doortype = /obj/structure/inflatable/door
	soundpath = 'sound/items/zip.ogg'

/obj/item/weapon/grenade/station/discount/decorate(var/list/interior)
	var/list/possible_trash = subtypesof(/obj/item/trash)-typesof(/obj/item/trash/mannequin)
	for(var/turf/T in interior)
		if(prob(30))
			var/new_trash = pick(possible_trash)
			new new_trash(T)

/obj/item/weapon/grenade/station/discount/centerpiece(var/turf/source)
	var/obj/structure/inflatable/R = new /obj/structure/inflatable/wall(source)
	R.spawn_undeployed = FALSE

/obj/item/weapon/grenade/station/discount/below_center(mob/living/M)
	if(istype(M))
		return
	M.apply_effects(10,10) //10 stun, 10 weaken
	to_chat(M, "<big><span class = 'warning'>BOING!</span></big>")

/obj/item/weapon/grenade/station/discount/under_edge(mob/M, turf/source)
	to_chat(M, "<span class = 'warning'>You are bounced away from \the [src] as it deploys!</span>")
	M.throw_at(get_ranged_target_turf(source, get_dir(source, M), range*3), 50, 3)

///Objects for the syndiesat
/obj/machinery/computer/crew/selfpower/powered(channel)
	return TRUE

/obj/machinery/computer/security/selfpower/powered(channel)
	return TRUE

/obj/machinery/computer/operating/selfpower/powered(channel)
	return TRUE