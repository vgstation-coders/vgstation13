
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	stat_collection.artifacts_discovered++

	artifact_id = generate_artifact_id()

	artifact_find_type = pick(
	5;/obj/machinery/syndicate_beacon,
	5;/obj/item/clothing/mask/stone,
	5;/obj/item/changeling_vial,
	5;/obj/item/weapon/bloodcult_pamphlet/oneuse,
	25;/obj/item/clothing/gloves/warping_claws,
	25;/obj/machinery/singularity_beacon,
	25;/obj/machinery/power/supermatter,
	50;/obj/structure/constructshell,
	50;/obj/machinery/vending/artifact,
	100;/obj/machinery/cryopod,
	100;/obj/machinery/auto_cloner,
	100;/obj/structure/bed/chair/vehicle/gigadrill,
	100;/obj/mecha/working/hoverpod,
	100;/obj/structure/essence_printer,
	100;/obj/machinery/replicator,
	100;/obj/machinery/communication,
	100;/mob/living/simple_animal/hostile/roboduck,
	1000;/obj/machinery/artifact)

var/list/all_generated_artifact_ids = list()

/proc/generate_artifact_id()
	var/artifact_id
	var/custom = TRUE
	for (var/i = 1 to 3)//three tries. cosmically low chance to get an already existing ID each time, but if we do, we'll settle with a custom one
		artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"
		if (!(artifact_id in all_generated_artifact_ids))
			custom = FALSE
			break
	if (custom)
		artifact_id = "sirius-[add_zero("[all_generated_artifact_ids.len]",3)]"
	all_generated_artifact_ids += artifact_id
	return artifact_id

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

var/list/boulders = list()

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation. May or may not contain an artifact, but if it does you better use a small pickaxe, lest you destroy it along with the debris."
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
	boulders -= src
	geological_data = null
	artifact_find = null
	..()

/obj/structure/boulder/New()
	..()
	boulders += src
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5,50)

/obj/structure/boulder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/core_sampler) && geological_data)
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
		to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [src.excavation_level]cm.</span>")
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		if(!(P.diggables & DIG_ROCKS))
			return

		to_chat(user, "<span class='rose'>You start [P.drill_verb] [src].</span>")

		busy = 1

		if(do_after(user,src, (MINE_DURATION * P.toolspeed)))

			busy = 0

			to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
			excavation_level += P.excavation_amount

			if(excavation_level > 100)
				//failure
				visible_message("<span class='danger'>\The [src] suddenly crumbles away.</span>")
				if(artifact_find)//destroyed artifacts have weird, unpleasant effects
					var/datum/artifact_postmortem_data/destroyed = new(null, FALSE, TRUE)
					destroyed.artifact_id = artifact_find.artifact_id
					destroyed.last_loc = get_turf(src)
					destroyed.artifact_type = artifact_find.artifact_find_type
					if (artifact_find.artifact_find_type == /obj/machinery/artifact)
						destroyed.primary_effect = "???"
						destroyed.secondary_effect = "???"
					razed_large_artifacts[artifact_find.artifact_id] += destroyed
					to_chat(user, "<span class='red'>As \the [src] disintegrates under your onslaught...</span>")//continued by the message from ArtifactRepercussion()
					ArtifactRepercussion(src, usr, "", "[artifact_find.artifact_find_type]")
				else
					to_chat(user, "<span class='rose'>\The [src] has disintegrated under your onslaught.</span>")
				qdel(src)
				return

			if(prob(excavation_level))
				//success
				visible_message("<span class='danger'>[src] suddenly crumbles away.</span>")
				if(artifact_find)
					var/spawn_type = artifact_find.artifact_find_type
					if (spawn_type == /obj/machinery/artifact)
						new spawn_type(get_turf(src), artifact_find.artifact_id)
					else if (spawn_type == /obj/machinery/power/supermatter)
						spawn(rand(10 MINUTES, 30 MINUTES))//The time it takes for Nanotrasen to detect it and make the Science dept an offer they cannot refuse.
							if (!(locate(/datum/centcomm_order/department/science/supermatter) in SSsupply_shuttle.centcomm_orders))
								SSsupply_shuttle.add_centcomm_order(new /datum/centcomm_order/department/science/supermatter)
						new spawn_type(get_turf(src))
					else
						var/atom/movable/AM = new spawn_type(get_turf(src))
						excavated_large_artifacts[artifact_find.artifact_id] = AM
				else
					to_chat(user, "<span class='notice'>[src] has been whittled away under your careful excavation, but there was nothing of interest inside.</span>")
				qdel(src)
		else
			busy = 0

/obj/structure/boulder/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		playsound(loc, 'sound/weapons/heavysmash.ogg', 75, 1)
		if(do_after(user, src, 20))
			qdel(src)
		return 1
	return 0

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

	else if(istype(AM,/mob/living/simple_animal/construct/armoured))
		attack_construct(AM)
