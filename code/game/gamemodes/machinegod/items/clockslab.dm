/var/global/list/clockslab_components_preset

/datum/initializer/clockcult/slab/components_list/initialize()
	global.clockslab_components_preset = CLOCK_COMP_IDS.Copy()
	for(var/a in global.clockslab_components_preset)	// Make it an assoc list with the assoc value being zeroes.
		global.clockslab_components_preset[a] = 0	

/obj/item/clockslab
	name = "clockwork slab"
	desc = "A bizarre, ticking, glowing device rapidly displaying information."
	icon = 'icons/obj/clockwork/slab.dmi'
	icon_state ="slab"
	throw_speed = 1
	throw_range = 5
	w_class = 2
	flags = FPRINT | HEAR

	var/tmp/datum/html_interface/clockslab/slab/interface // HTML interface datum reference.

	var/next_component = CLOCKSLAB_TICKS_UNTARGETED	// How much process() calls left before we spit out a new component,
	var/target_component // Which component we're targeting to make, slower but targeted.
	var/total_components = 0
	var/list/components = list() // List of stored components.
	var/tmp/list/selected_components = list() // List of selected components (in the recital).
	var/tmp/datum/clockcult_power/selected_power // Selected power.

	var/converting = FALSE
	var/hierophant_remaining = 0 // Amount of ticks left for the hierophant power.

	var/tmp/last_hierophant_stage = 0
	var/tmp/last_converting = FALSE
	
/obj/item/clockslab/New()
	. = ..()

	processing_objects += src
	components = global.clockslab_components_preset.Copy()

/obj/item/clockslab/Destroy()
	. = ..()

	processing_objects -= src

/obj/item/clockslab/Hear(var/datum/speech/speech, var/rendered_speech = "")
	if(!hierophant_remaining) // Ignore clockcult mobs since they are always able to speak globally.
		return

	/*
	if(istype(speech.speaker, /mob/living/simple_animal/clockcult)) // Ignore clockcult mobs since they are always able to speak globally.
		return
	*/

	if(speech.language.name != LANGUAGE_CLOCKCULT)
		return

	clockcult_broadcast(speech, rendered_speech)

/obj/item/clockslab/preattack(var/atom/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if(!proximity_flag || !isclockcult(user))
		return

	if(!isliving(target))
		return

	if(!converting)
		return 1
		
	var/mob/living/M = target
	
	if(!M.mind)
		return 1

	if(isclockcult(M))
		user << "<span class='clockwork'>[M] is already a follower!</span>"
		return 1
	else
		M.visible_message("<span class='warning'>A golden light fills [M]'s eyes.</span>", \
		"<span class='clockwork'>\"You belong to me now.\"</span>", \
		"<span class='warning'>Something feels wrong.</span>")

	if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
		ticker.mode.add_clockcultist(M.mind)
		M.mind.special_role = "Machinegod"
		M << "<span class='clockwork'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='clockwork'>Assist your new compatriots in their righteous efforts. Their goal is yours, and yours is theirs. You serve the Justiciar above all else. Bring Him back.</span>"
		log_admin("[M]([ckey(M.key)]) was converted to Ratvar's cult at [M.loc.x], [M.loc.y], [M.loc.z] by [user]([ckey(user.key)]")

		converting = FALSE
		update_icon()

	else
		M << "<span class='clockwork'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once everything connects to you. The clockwork justiciar lies in exile, derelict and forgotten in an unseen realm.</span>"
		M << "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>"

		// Make them defenseless for a whole minute, to prevent a jobbanned guy ruining a round.
		M.Weaken(60)
		M.silent += 60

	return 1

/obj/item/clockslab/update_icon()
	if(!needs_icon_update())
		return

	overlays.Cut()
	if(converting)
		// overlays += "converting"

	if(hierophant_remaining)
		overlays += "clock-[Clamp(hierophant_remaining, 1, 15)]"

/obj/item/clockslab/proc/needs_icon_update()
	if(converting != last_converting)
		converting = last_converting
		. = 1

	var/clamped = Clamp(hierophant_remaining, 0, 15)
	if(clamped != last_hierophant_stage)
		last_hierophant_stage = clamped
		. = 1

/obj/item/clockslab/process()
	if(hierophant_remaining)
		hierophant_remaining = max(0, --hierophant_remaining)

	update_icon()

	var/mob/living/carbon/M = get(src, /mob/living/carbon)
	if(!istype(M))	//Not being held by a valid mob.
		return

	var/list/L = recursive_type_check(M, type)
	if(L.len > 1)	//The user is trying to CHEAT by having 2 slabs.
		return

	if(!isclockcult(M))	//The mob doesn't obey Ratvar.
		return

	if(--next_component <= 0)	//Done.
		create_component(target_component)
		next_component = target_component ? CLOCKSLAB_TICKS_TARGETED : CLOCKSLAB_TICKS_UNTARGETED

// Will spawn a component, random if no ID specified, mob is for overflow handling, so we don't run get() again.
/obj/item/clockslab/proc/create_component(var/id = pick(CLOCK_COMP_IDS), var/mob/living/carbon/M)
	if(total_components >= CLOCKSLAB_CAPACITY)	//No room, time to handle overflow.
		if(!M)	//No mob, this shouldn't happen but just in case let's drop it on the floor.
			if(!loc)	//Uuuuuuh... this is getting weirder by the minute.
				qdel(src)

			else
				var/obj/item/clock_component/C = getFromPool(get_clockcult_comp_by_id(id, no_alpha = TRUE), get_turf(src))
				animate(C, alpha = initial(C.alpha), 5)

			return

		var/obj/item/clock_component/C = getFromPool(CLOCK_COMP_IDS_PATHS_NO_ALPHA[id])

		//Try to insert it into a storage obj on the mob.
		for(var/obj/item/weapon/storage/S in recursive_type_check(M, /obj/item/weapon/storage))
			if(S.can_be_inserted(C, 1))
				S.handle_item_insertion(C, 1)
				break

		if(!C.loc)	//We didn't manage to insert it somewhere.
			C.forceMove(M.loc)

		animate(C, alpha = initial(C.alpha), 5)

	else	//We have room.
		components[id]++
		total_components++

/obj/item/clockslab/examine(mob/user)
	..()
	if(isclockcult(user))
		user << "The word of Ratvar, The One Who Judges, The Clockwork Justiciar. Contains the details of all the powers his followers can possibly call upon. Without the Justiciar's presence, they're all weakened, however."
	else
		user << "...and not a word of it makes any sense to you."

/obj/item/clockslab/attack_self(mob/living/user as mob)
	. = ..()
	if(.)
		return

	if(iscultist(user))	//Cultists be scared to shit.
		user << "<span class='sinister'>You reek of blood. You’ve got a lot of nerve to even look at that slab.</span>"
		return 1

	//INSERT SMART UI CALLING CODE HERE.

/obj/item/clockslab/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(!isclockcult(usr))
		usr << "<span class='warning'>You don't even have any idea what any of this means, better not touch it...</span>"
		return 1

	//Target a component for production, note that this resets the timer.
	if(href_list["target"])
		if(!(href_list["target"] in CLOCK_COMP_IDS + "null"))
			return 1	//Go away href exploiters.

		if(target_component == "null")
			target_component = null

		else
			target_component = href_list["target"]

		next_component = target_component ? CLOCKSLAB_TICKS_TARGETED : CLOCKSLAB_TICKS_UNTARGETED
		return 1

/obj/item/clockslab/proc/invoke_power(var/mob/user)
	return 1

//Gets the power currently selected with the amounts of parts.
/obj/item/clockslab/proc/get_power()
	for(var/datum/clockcult_power/P in clockcult_powers)
		if(!equal_list(P.req_components, selected_components))
			continue

		//Alright we're sure we have the same selected components, return this one.
		return P


