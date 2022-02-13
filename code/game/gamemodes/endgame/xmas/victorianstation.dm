/**
	Victorianize your station
		At one press of a button, turn every wall on the station to wood, all lighting to lanterns, all lamps to candles,
		And the main hallways to snow.

		Additionally, the bar becomes much more festive, with the addition of a christmas tree!

		Also piss off your server host and set the entire server on fire.
*/

/datum/universal_state/auldlangsyne
	name = "Older times"
	desc = "The clock's ticking backwards!"


/datum/universal_state/auldlangsyne/OnEnter()
	var/target_zlevel = map.zMainStation
	to_chat(map.zLevels[target_zlevel], "<span class='sinister'>There is a certain chill to the air, as bells ring faintly in the distance...</span>")
	//Snow up the halls
	for(var/A in typesof(/area/hallway))
		var/area/to_snow = locate(A)
		if(!to_snow)
			continue
		for(var/turf/simulated/floor/F in to_snow)
			new /obj/structure/snow(F)
			for(var/cdir in cardinal)
				var/turf/TT = get_step(F,cdir)
				if(istype(TT,/turf/simulated/wall))
					new/obj/machinery/xmas_light(TT,cdir)
		for(var/obj/machinery/light/L in to_snow)
			qdel(L)

	for(var/area/A in areas)
		if(!istype(A, /turf/space) && A.z == target_zlevel)
			for(var/turf/T in A)
				if(istype(T, /turf/simulated/wall) && !istype(T, /turf/simulated/wall/r_wall))
					T.ChangeTurf(/turf/simulated/wall/mineral/wood, tell_universe = 0)
			for(var/obj/item/device/flashlight/F in A)
				var/obj/item/candle/C = new /obj/item/candle(F.loc)
				C.light(quiet = 1)
				qdel(F)
			for(var/obj/machinery/light/L in A)
				var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern/dim(L.loc)
				HL.dir = L.dir
				HL.update()
				qdel(L)
			for(var/obj/structure/closet/secure_closet/S in A)
				switch(S.type)
					//Captains locker
					if(/obj/structure/closet/secure_closet/captains)
						new /obj/item/clothing/suit/storage/wintercoat/security/captain(S)

					//HoPs attire
					if(/obj/structure/closet/secure_closet/hop2)
						new /obj/item/clothing/suit/storage/wintercoat/hop(S)

					//Head of security's ling-hunting gear
					if(/obj/structure/closet/secure_closet/hos)
						new /obj/item/clothing/suit/storage/wintercoat/security/hos(S)

					if(/obj/structure/closet/secure_closet/warden)
						new /obj/item/clothing/suit/storage/wintercoat/security/warden(S)

					if(/obj/structure/closet/secure_closet/security)
						new /obj/item/clothing/suit/storage/wintercoat/security(S)

					if(/obj/structure/closet/secure_closet/brig)
						new /obj/item/clothing/suit/storage/wintercoat/prisoner(S)
						new /obj/item/clothing/suit/storage/wintercoat/prisoner(S)

					if(/obj/structure/closet/secure_closet/scientist)
						new /obj/item/clothing/suit/storage/wintercoat/medical/science(S)
						new /obj/item/clothing/suit/storage/wintercoat/medical/science(S)

					if(/obj/structure/closet/secure_closet/RD)
						new /obj/item/clothing/suit/storage/wintercoat/medical/science(S)

					if(/obj/structure/closet/secure_closet/medical3 || /obj/structure/closet/secure_closet/paramedic)
						new /obj/item/clothing/suit/storage/wintercoat/medical(S)
						new /obj/item/clothing/suit/storage/wintercoat/medical(S)

					if(/obj/structure/closet/secure_closet/CMO)
						new /obj/item/clothing/suit/storage/wintercoat/medical/cmo(S)

					if(/obj/structure/closet/secure_closet/engineering_chief)
						new /obj/item/clothing/suit/storage/wintercoat/engineering/ce(S)

					if(/obj/structure/closet/secure_closet/engineering_personal || /obj/structure/closet/secure_closet/engineering_mechanic)
						new /obj/item/clothing/suit/storage/wintercoat/engineering(S)
						new /obj/item/clothing/suit/storage/wintercoat/engineering(S)

					if(/obj/structure/closet/secure_closet/engineering_atmos)
						new /obj/item/clothing/suit/storage/wintercoat/engineering/atmos(S)
						new /obj/item/clothing/suit/storage/wintercoat/engineering/atmos(S)

					else
						if(prob(50))
							new /obj/item/clothing/suit/storage/wintercoat(S)
							if(prob(80))
								new /obj/item/clothing/suit/storage/wintercoat(S)


	var/area/christmas_bar = locate(/area/crew_quarters/bar)
	if(christmas_bar)
		var/list/turf/simulated/floor/valid = list()
		//Loop through each floor in the supply drop area
		for(var/turf/simulated/floor/F in christmas_bar)
			if(!F.has_dense_content() && istype(F, /turf/simulated/floor/wood))
				valid.Add(F)
		if(valid.len)
			new/obj/structure/snow_flora/tree/pine/xmas/vg/(pick(valid))

	var/area/santadog = locate(/area/crew_quarters/hop)
	if(santadog)
		var/mob/living/simple_animal/corgi/corg = locate(/mob/living/simple_animal/corgi/Ian) in santadog
		if(corg)
			corg.remove_inventory("head")
			corg.remove_inventory("back")
			var/obj/item/I = new/obj/item/clothing/head/christmas/santahat/red
			corg.place_on_head(I)
	/*
	var/mob/living/simple_animal/corgi/corg = locate(/mob/living/simple_animal/corgi/Ian) in world
	if(corg)
		corg.remove_inventory("head")
		corg.remove_inventory("back")
		var/obj/item/I = new/obj/item/clothing/head/christmas/santahat/red
		corg.place_on_head(I)
	*/
