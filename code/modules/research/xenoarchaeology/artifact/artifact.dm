
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	stat_collection.artifacts_discovered++

	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	artifact_find_type = pick(\
	5;/obj/machinery/syndicate_beacon,\
	5;/obj/item/clothing/mask/stone,\
	5;/obj/item/changeling_vial,\
	10;/obj/structure/constructshell,\
	25;/obj/machinery/power/supermatter,\
	100;/obj/item/clothing/gloves/warping_claws,\
	100;/obj/machinery/auto_cloner,\
	100;/obj/structure/bed/chair/vehicle/gigadrill,\
	100;/obj/mecha/working/hoverpod,\
	100;/obj/machinery/replicator,\
	100;/obj/machinery/communication,\
	150;/obj/structure/crystal,\
	1000;/obj/machinery/artifact)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = 1
	opacity = 1
	anchored = 1
	var/busy = 0 //No message spam, thanks
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find

/obj/structure/boulder/Destroy()
	..()
	geological_data = null
	artifact_find = null

/obj/structure/boulder/New()
	..()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5,50)

/obj/structure/boulder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice>[user] extends [P] towards [src].","<span class='notice'>You extend [P] towards [src].</span></span>")
		to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*src.excavation_level]cm.</span>")
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		if(!(P.diggables & DIG_ROCKS))
			return

		to_chat(user, "<span class='rose'>You start [P.drill_verb] [src].</span>")

		busy = 1

		if(do_after(user,src, P.digspeed))

			busy = 0

			to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
			excavation_level += P.excavation_amount

			if(excavation_level > 100)
				//failure
				src.visible_message("<span class='danger'>\The [src] suddenly crumbles away.</span>")
				to_chat(user, "<span class='rose'>\The [src] has disintegrated under your onslaught, any secrets it was holding are long gone.</span>")
				returnToPool(src)
				return

			if(prob(excavation_level))
				//success
				src.visible_message("<span class='danger'>[src] suddenly crumbles away.</span>")
				if(artifact_find)
					var/spawn_type = artifact_find.artifact_find_type
					if (spawn_type == /obj/machinery/artifact)
						new spawn_type(get_turf(src), artifact_find.artifact_id)
					else
						new spawn_type(get_turf(src))
				else
					to_chat(user, "<span class='notice'>[src] has been whittled away under your careful excavation, but there was nothing of interest inside.</span>")
				returnToPool(src)
		else
			busy = 0
		return

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(istype(H.get_active_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_active_hand(), H)
		else if(istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_inactive_hand(), H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active, R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)
