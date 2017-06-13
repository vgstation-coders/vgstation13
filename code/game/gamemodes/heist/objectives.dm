/**
 * vox heist objectives
 */

#define MAX_VOX_KILLS 5 // number of kills during the round before the inviolate is broken
						// would be nice to use vox-specific kills but is currently not feasible

/*
 * heist
 */

/datum/objective/heist/proc/choose_target()
	return

/*
 * kidnap
 */

/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Chief Engineer", "Research Director", "Roboticist", "Chemist", "Medical Doctor", "Janitor", "Bartender")

	for(var/role in shuffle(roles))
		find_target_by_role(role)

		if(target)
			break

	if(isnull(target)) // if we cannot find some target at certain roles
		find_target()

	if(target)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"

	return target

/datum/objective/heist/kidnap/check_completion()
	if(target)
		if(isnull(target.current)/* || target.current.stat == DEAD*/) // Removed dead check, we can clone them after we get them back anyway.
			return FALSE // they're destroyed. fail.

		var/end_area = get_area_master(locate(/area/shuttle/vox/station))

		if(get_area_master(target.current) != end_area)
			return FALSE

		//if(!target.current.restrained())
			//return FALSE // they're loose. close but no cigar.

		return TRUE // they're restrained on the shuttle. success.

/*
 * inviolate
 */

/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = ticker.mode
	return H.is_raider_crew_safe()

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	if(vox_kills > MAX_VOX_KILLS)
		return FALSE

	return TRUE

#undef MAX_VOX_KILLS

/*
 * theft
 */

/*
 * heist
 */

/datum/objective/steal/heist_easy
	target_category = "heist_easy"

/datum/objective/steal/heist_hard
	target_category = "heist_hard"

/datum/objective/steal/heist_easy/format_explanation()
	return "We are lacking in some trivial devices. Steal [steal_target.name]."

/datum/objective/steal/heist_hard/format_explanation()
	return "We are lacking in expensive hardware or bioware. Steal [steal_target.name]."

/datum/theft_objective/number/heist_easy
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/heist_hard
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/heist_easy/check_completion()
	var/list/search = list()
	var/found = 0
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B, typepath)
	for(var/C in search)
		found++
	return (found >= required_amount)

/datum/theft_objective/number/heist_hard/check_completion()
	var/list/search = list()
	var/found = 0
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B, typepath)
	for(var/C in search)
		found++
	return (found >= required_amount)

/* LAME
/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	typepath = /obj/machinery/the_singularitygen
	min = 1
	max = 1

/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	typepath = /obj/machinery/the_singularitygen
	min = 1
	max = 1

/datum/theft_objective/number/heist/emitters
	name = "emitters"
	typepath = /obj/machinery/power/emitter
	min = 4
	max = 4
*/

///easy objectives (near the outside of the station or common///

/datum/theft_objective/number/heist_easy/gun
	name = "guns"
	typepath = /obj/item/weapon/gun
	min = 4
	max = 6

/datum/theft_objective/number/heist_easy/supermatter
	name = "supermatter shard"
	typepath = /obj/machinery/power/supermatter/shard
	min = 1
	max = 1

/datum/theft_objective/number/heist_easy/jukebox
	name = "jukebox"
	typepath = /obj/machinery/media/jukebox
	min = 1
	max = 1

/datum/theft_objective/number/heist_easy/microwave
	name = "microwave ovens"
	typepath = /obj/machinery/microwave
	min = 2
	max = 2

/datum/theft_objective/number/heist_easy/camera
	name = "polaroid cameras"
	typepath = /obj/item/device/camera
	min = 4
	max = 4

/datum/theft_objective/number/heist_easy/canister
	name = "canister of plasma"
	typepath = /obj/machinery/portable_atmospherics/canister/plasma
	min = 1
	max = 1

/datum/theft_objective/number/heist_easy/plants
	name = "house plants"
	typepath = /obj/structure/flora
	min = 6
	max = 10

/datum/theft_objective/number/heist_easy/borgrecharger
	name = "cyborg recharging stations"
	typepath = /obj/machinery/recharge_station
	min = 2
	max = 2

/datum/theft_objective/number/heist_easy/fueltank
	name = "welding fuel tanks"
	typepath = /obj/structure/reagent_dispensers/fueltank
	min = 2
	max = 4

/datum/theft_objective/number/heist_easy/filingcabinet
	name = "filing cabinets"
	typepath = /obj/structure/filingcabinet
	min = 2
	max = 4

///hard objectives (near the inside of the station or rare///

/datum/theft_objective/number/heist_hard/particle_accelerator
	name = "complete and assembled particle accelerator"
	typepath = /obj/structure/particle_accelerator
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/particle_accelerator/check_completion()
	var/list/contents = list(/obj/structure/particle_accelerator/end_cap, \
							/obj/structure/particle_accelerator/fuel_chamber, \
							/obj/structure/particle_accelerator/particle_emitter/center, \
							/obj/structure/particle_accelerator/particle_emitter/left, \
							/obj/structure/particle_accelerator/particle_emitter/right, \
							/obj/structure/particle_accelerator/power_box,)
	var/list/search = list()
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B, /obj/structure/particle_accelerator)
	for(var/C in contents)
		for(var/atom/A in search)
			if(istype(A,C)) //Does search contain this part type
				continue
			return FALSE //It didn't, fail the object
	return TRUE

/datum/theft_objective/number/heist_hard/nuke
	name = "thermonuclear device"
	typepath = /obj/machinery/nuclearbomb
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/cat
	name = "cat"
	typepath = /mob/living/simple_animal/cat
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/duck
	name = "rubber ducky"
	typepath = /obj/item/weapon/bikehorn/rubberducky
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/borgupload
	name = "cyborg upload console circuit board"
	typepath = /obj/item/weapon/circuitboard/borgupload
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/amplifier
	name = "subspace amplifiers"
	typepath = /obj/item/weapon/stock_parts/subspace/amplifier
	min = 4
	max = 6

/datum/theft_objective/number/heist_hard/clownmask
	name = "clown's mask"
	typepath = /obj/item/clothing/mask/gas/clown_hat
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/piano
	name = "space piano"
	typepath = /obj/structure/piano
	min = 1
	max = 1

/datum/theft_objective/number/heist_hard/organs/check_completion()
	var/list/search = list()
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B, typepath)
	var/valid_organs=0
	for(var/atom/A in search)
		if(!istype(A,/obj/item/organ))
			var/obj/item/organ/O = A
			if(O && istype(O, typepath) && !O.is_printed && O.had_mind)
				valid_organs++
	return (valid_organs >= required_amount)

/datum/theft_objective/number/heist_hard/organs/appendix
	name = "appendixes"
	typepath = /obj/item/organ/appendix
	min = 3
	max = 6

/datum/theft_objective/number/heist_hard/organs/eyes
	name = "eyes"
	typepath = /obj/item/organ/eyes
	min = 3
	max = 6

/*
 * salvage


/datum/objective/steal/salvage
	target_category = "salvage"

/datum/objective/steal/salvage/format_explanation()
	return "Ransack the station and escape with [steal_target.name]."

/datum/theft_objective/number/salvage
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/salvage/check_completion()
	var/found_amount = 0
	var/list/search = list()
	for(var/A in areas)
		var/area/B = locate(A)
		search += recursive_type_check(B,typepath)
	if(istype(typepath,/obj/item/stack))
		for(var/obj/item/stack/A in search)
			found_amount += A.amount
	else
		found_amount = search.len
	return (found_amount >= required_amount)

/datum/theft_objective/number/salvage/metal
	name = "metal"
	typepath = /obj/item/stack/sheet/metal
	min = 300
	max = 300

/datum/theft_objective/number/salvage/glass
	name = "glass"
	typepath = /obj/item/stack/sheet/glass/glass
	min = 200
	max = 200

/datum/theft_objective/number/salvage/plasteel
	name = "plasteel"
	typepath = /obj/item/stack/sheet/plasteel
	min = 100
	max = 100

/datum/theft_objective/number/salvage/plasma
	name = "plasma"
	typepath = /obj/item/stack/sheet/mineral/plasma
	min = 100
	max = 100

/datum/theft_objective/number/salvage/silver
	name = "silver"
	typepath = /obj/item/stack/sheet/mineral/silver
	min = 50
	max = 50

/datum/theft_objective/number/salvage/gold
	name = "gold"
	typepath = /obj/item/stack/sheet/mineral/gold
	min = 20
	max = 20

/datum/theft_objective/number/salvage/uranium
	name = "uranium"
	typepath = /obj/item/stack/sheet/mineral/uranium
	min = 20
	max = 20

/datum/theft_objective/number/salvage/diamond
	name = "diamond"
	typepath = /obj/item/stack/sheet/mineral/diamond
	min = 20
	max = 20

	*/
