/obj/item/clothing/mask/necklace
	body_parts_covered = 0
	ignore_flip = TRUE

/obj/item/clothing/mask/explosive_collar
	name = "explosive collar"
	icon = 'icons/obj/clothing/explosive_collar.dmi'
	icon_override ='icons/mob/explosive_collar.dmi'
	icon_state = "bombcollaroff"
	desc = "It doesn't let go."
	ignore_flip = TRUE
	canremove = FALSE
	clothing_flags = MASKINTERNALS
	var/primed = FALSE
	var/scheduled_explosion_time
	var/condition_for_release_text = ""

/obj/item/clothing/mask/explosive_collar/examine(mob/user)
	if(primed)
		to_chat(user, "<span class='notice'>Its screen reads <span class='binaryradio'>[worldtime2text(scheduled_explosion_time)]</span>.</span>")
	else
		to_chat(user, "<span class='notice'>Its screen is turned off.</span>")

/obj/item/clothing/mask/explosive_collar/update_icon()
	icon_state = primed ? "bombcollaron" : "bombcollaroff"

/obj/item/clothing/mask/explosive_collar/dissolvable()
	return FALSE

/obj/item/clothing/mask/explosive_collar/proc/explode()
	var/mob/living/carbon/victim = loc
	if(istype(victim) && victim.is_wearing_item(src, slot_wear_mask))
		var/datum/organ/external/head/head_organ = victim.get_organ(LIMB_HEAD)
		if(head_organ)
			head_organ.explode()
		explosion(src, -1, -1, 0, 1)
	say("Conditions were not met.")
	visible_message("<span class='danger'>\The [src] explodes!</span>")
	qdel(src)

/obj/item/clothing/mask/explosive_collar/proc/deactivate()
	canremove = TRUE
	primed = FALSE
	processing_objects -= src
	update_icon()
	say("Conditions were met.")
	var/mob/living/carbon/victim = loc
	if(istype(victim) && victim.is_wearing_item(src, slot_wear_mask))
		victim.drop_item(src)

/obj/item/clothing/mask/explosive_collar/proc/activate()
	if(primed)
		return
	canremove = FALSE
	primed = TRUE
	processing_objects += src
	if(condition_for_release_text)
		say("Condition for release: [condition_for_release_text].")
	update_icon()

/obj/item/clothing/mask/explosive_collar/process()
	if(world.time >= scheduled_explosion_time)
		switch(condition_is_fullfilled())
			if(null) // Not implemented, just do nothing
				return PROCESS_KILL
			if(TRUE)
				deactivate()
			if(FALSE)
				explode()

/obj/item/clothing/mask/explosive_collar/proc/condition_is_fullfilled()
	return null // Implement this for subtypes

/obj/item/clothing/mask/explosive_collar/equipped(mob/user, slot, hand_index = 0)
	if(primed || slot != slot_wear_mask)
		return
	activate()

/obj/item/clothing/mask/explosive_collar/mechanic
	var/time_until_explosion = 30 MINUTES
	condition_for_release_text = "Most APCs must be charged or charging, and/or 20 machines must be upgraded within the time limit"

/obj/item/clothing/mask/explosive_collar/mechanic/examine(mob/user)
	..()
	if(condition_for_release_text)
		to_chat(user, "<span class='bold'>Condition for release: [condition_for_release_text].</span>")

/obj/item/clothing/mask/explosive_collar/mechanic/activate()
	scheduled_explosion_time = time_until_explosion + world.time
	..()

/obj/item/clothing/mask/explosive_collar/mechanic/deactivate()
	..()
	slot_flags = NONE // Prevent second-hand griff

/proc/is_power_good_enough()
	var/const/good_apcs_percentage_required = 51
	var/total_apcs = 0
	var/good_apcs = 0
	for(var/obj/machinery/power/apc/some_apc in power_machines)
		if(some_apc.z != map.zMainStation)
			continue
		total_apcs++
		var/obj/item/weapon/cell/battery = some_apc.get_cell()
		var/const/minimum_power_cell_charge_percent = 80
		if(battery?.percent() > minimum_power_cell_charge_percent || some_apc.charging)
			good_apcs++
	return (100*good_apcs/total_apcs) >= good_apcs_percentage_required

/proc/how_many_machines_are_upgraded()
	var/machines_upgraded = 0
	for(var/obj/machinery/machine in all_machines)
		var/cached_rating = machinery_rating_cache[machine.type]
		if(isnull(cached_rating))
			continue
		var/rating = 0
		for(var/obj/item/weapon/stock_parts/SP in machine.component_parts)
			rating += SP.rating
		if(rating > cached_rating)
			machines_upgraded++
	return machines_upgraded

/obj/item/clothing/mask/explosive_collar/mechanic/condition_is_fullfilled()
	var/power_is_good_enough = is_power_good_enough()

	var/const/minimum_machines_to_upgrade = 20
	var/enough_machines_were_upgraded = how_many_machines_are_upgraded() >= minimum_machines_to_upgrade

	return power_is_good_enough || enough_machines_were_upgraded

/obj/item/clothing/mask/necklace/xeno_claw
	name = "xeno necklace"
	desc = "A necklace made out of some cable coils and a xenomorph's claws."
	icon_state = "xeno_necklace"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/mask/necklace/teeth
	name = "teeth necklace"
	desc = "A necklace made out of a bunch of teeth."
	icon_state = "tooth-necklace"

	var/mob/animal_type
	var/teeth_amount = 10

/obj/item/clothing/mask/necklace/teeth/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W, /obj/item/stack/teeth))
		var/obj/item/stack/teeth/T = W
		if(T.animal_type != src.animal_type) //If the teeth came from a different animal, fuck off
			return

		src.teeth_amount += T.amount
		update_name()
		to_chat(user, "<span class='info'>You add [T.amount] [T] to \the [src].</span>")
		T.use(T.amount)

/obj/item/clothing/mask/necklace/teeth/proc/update_name()
	var/animal_name = "teeth"
	if(animal_type)
		if(ispath(animal_type, /mob/living/carbon/human))
			animal_name = "human teeth"
			if(animal_type == /mob/living/carbon/human/skellington)
				animal_name = "skellington teeth"
			if(animal_type == /mob/living/carbon/human/tajaran)
				animal_name = "tajaran teeth"
		else
			animal_name = "[initial(animal_type.name)] teeth"

	var/prefix = ""
	if(teeth_amount >= 20)
		prefix = "fine "
	if(teeth_amount >= 35)
		prefix = "well-made "
	if(teeth_amount >= 50)
		prefix = "masterwork "
	if(teeth_amount >= 100)
		prefix = "legendary "

	name = "[prefix][animal_name] necklace"
	desc = "A necklace made out of [teeth_amount] [animal_name]."
