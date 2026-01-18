
// Abyss tiles!
// Objects and mobs walking over an abyss fall into it, unless there's an object like a catwalk placed on top!
// Abyss tiles are unsimmed floors, meaning they always have the same gas contents. However, they also block airflow, so they're safe use them with simmed tiles.

/turf/unsimulated/floor/abyss
	name = "abyss"
	desc = "You can't see the bottom."
	icon_state = "blackpit"
	plane = BELOW_PLATING_PLANE
	explosion_block = 0

	// I've been thinking a lot on whether or not these should block air.
	// On one hand, it makes sense for a near-bottomless abyss to act as a limitless source of gas.
	// On the other hand, unsimmed tiles with gas flow would cause problems if gas is allowed to flow between two unsimmed tiles with different gas contents.
	// i.e. (snow floor -> simmed floor -> space tile) = endless ZASflow
	blocks_air = TRUE


	var/abyss_link_tag = ""								// Sends any mob that falls into the abyss to a corpse chute with a matching tag.
	var/initialized = FALSE
	var/list/exclude_types = list(						// Mobs and objects in this list should never fall. Mobs/Objects locked to atoms in this list won't fall either.
		/obj/structure/bed/chair/vehicle/adminbus/, 	// NOPE!
		/obj/structure/catwalk
//		/obj/structure/bed/chair/vehicle/firebird/,		// See can_fall() comment.
	)
	var/list/prevents_fall = list(						// Objects in this list prevent things from falling.
		/obj/structure/catwalk,
	)

/turf/unsimulated/floor/abyss/vox
	oxygen=0
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD

/atom/movable
	// Adding a variable for this probably isn't the best approach, but it's the easiest.
	// This variable ensures that the falling sequence only starts once, in case an object is thrown across an abyss.
	var/abyssfall = FALSE


/turf/unsimulated/floor/abyss/initialize()
	. = ..()
	initialized = TRUE

/turf/unsimulated/floor/abyss/proc/can_abyssfall(var/atom/movable/AM)
	for(var/atom/A in contents)
		if(is_type_in_list(A, prevents_fall))
			return FALSE
	if(!isobj(AM) && !isliving(AM))				// Objects and living mobs only!
		return FALSE
	if(is_type_in_list(AM, exclude_types))
		return FALSE
	if(is_type_in_list(AM.locked_to, exclude_types))
		return FALSE

	// 		I thought about allowing players to flying things like powered jetpacks and firebirds to traverse the abyss.
	// 		but this just invites a headache because of the out-of-bounds "fake-z" areas, which are not meant to be accessible.
	// 		What should happen if someone's jetpack runs out of fuel or someone exits their firebird above one of those areas?
	//		It's a lot of extra complexity for a niche interaction. If I can find out what to do about those OOB areas, I'll implement this.
	//		The adminbus remains excluded because the adminbus don't care

	/*
	var/mob/living/carbon/human/H
	if(ishuman(H))
		if(istype(H.back, /obj/item/weapon/tank/jetpack))
			var/obj/item/weapon/tank/jetpack/J = H.back
			if((J.allow_thrust(0.01, src)))
				return FALSE
	*/

	return TRUE

/turf/unsimulated/floor/abyss/Crossed(var/atom/movable/AM)
	if(AM.abyssfall || !initialized || !can_abyssfall(AM))
		..()
	else
		abyssfall(AM)


/turf/unsimulated/floor/abyss/proc/abyssfall(var/atom/movable/AM)
	AM.abyssfall = TRUE
	AM.visible_message("<span class='warning'>[AM] falls down into the abyss, disappearing from view!</span>")
	var/color_cache = AM.color

	// There's some weird quirk with animate where non-mobs take longer to have their color adjusted.
	// Don't know why that happens, but here's a workaround...
	if(isobj(AM))
		animate(AM, color = "#000000", time = 3)
	else
		animate(AM, color = "#000000", time = 1 SECONDS)
	// Play a falling sound here

	var/list/mob_list = recursive_type_check(AM, /mob/living)
	var/list/human_list = recursive_type_check(AM, /mob/living/carbon/human)
	mob_list = mob_list - human_list

	for(var/mob/living/M in mob_list)
		M.Knockdown(10)
		M.Stun(10)
		M.captured = TRUE	// The captured var exists for other things like mannequins and the adminbus, but it works perfectly fine here.
		M.update_canmove()

	for(var/mob/living/carbon/human/M in human_list)
		if(M.client)
			if(M.pulledby) 		// If we have a client, we add attack logs
				add_logs(M.pulledby, M, "pulled into an abyss", TRUE, src, get_coordinates_string(src))
				message_admins("[M] was pulled into an abyss by [M.pulledby].")
			else if(M.last_bumped_by_timestamp - 0.1 SECONDS <= world.time <= M.last_bumped_by_timestamp + 0.1 SECONDS) // If got bumped into a supermatter
				var/mob/hostile = M.last_bumped_by.get()
				add_logs(hostile, M, "bumped into an abyss", TRUE, src, get_coordinates_string(src))
				message_admins("[M] was bumped into an abyss by [hostile].")
			else if(M.last_thrown_by_timestamp - 0.1 SECONDS <= world.time <= M.last_thrown_by_timestamp + 2 SECONDS) // If got thrown into a supermatter
				var/mob/hostile = M.last_thrown_by.get()
				add_logs(hostile, M, "thrown into an abyss", TRUE, src, get_coordinates_string(src))
				message_admins("[M] was thrown into an abyss by [hostile].")
			else
				M.attack_log += "\[[time_stamp()]\]: walked into an abyss (no bumper/no pusher)"
				message_admins("[M] walked into an abyss! (no bumper/pusher)")

		if(M.pulledby)
			M.pulledby.stop_pulling()
		to_chat(M, "<span class='danger'>Everything turns dark as you tumble down the pit...</span>")
		M.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)
		M.update_fullscreen_alpha("blindblack", 255, 10)
		if(prob(5) || Holiday == APRIL_FOOLS_DAY)
			playsound(M, 'sound/effects/kirbyfall.ogg', 25, 0)
		else
			M.audible_scream()
		M.captured = TRUE
		M.Knockdown(10)
		M.Stun(10)
		M.update_canmove()

	spawn(1 SECONDS + 1)
		if(human_list.len != 0)					// If AM is a human or contains a human, it gets collected by any corpse chutes.
			var/obj/structure/disposaloutlet/D = get_connected_chute()
			var/obj/structure/disposalholder/H
			if(D)
				H = new(D)
				AM.forceMove(H)
			else
				AM.loc = null
				qdel(AM)
				CRASH("no abyss corpse chutes exist in the world OR no chutes exist with a matching abyss_link_tag var!")

			for(var/mob/living/carbon/human/M in human_list)
				M.captured = FALSE

				var/total_damage = 100 		// Falling always enough to knock the person into crit.

				// Damage is dealt onto every lower limb, with any remaining damage getting splashed onto the torso.
				var/limbs_to_damage = list()
				limbs_to_damage += M.pick_usable_organ(LIMB_LEFT_LEG)
				limbs_to_damage += M.pick_usable_organ(LIMB_RIGHT_LEG)
				limbs_to_damage += M.pick_usable_organ(LIMB_RIGHT_FOOT)
				limbs_to_damage += M.pick_usable_organ(LIMB_LEFT_FOOT)

				for(var/datum/organ/external/O in limbs_to_damage)
					if(total_damage < O.min_broken_damage - 10)
						continue
					var/dam = rand(O.min_broken_damage - 10, min(O.min_broken_damage+10, total_damage))
					O.take_damage(dam, 0)
					total_damage -= dam

				var/datum/organ/external/chest = M.pick_usable_organ(LIMB_CHEST)
				if(chest)
					chest.take_damage(total_damage,0)	// Any remaining damage gets splashed to the chest.
				else
					M.adjustBruteLoss(total_damage)		// There should always be a chest organ, but just in case.

				to_chat(M, "<span class='big danger'>Ouch...</span>")
				M.playsound_local(src, 'sound/effects/falldamage.ogg', 75, 0)
				M.clear_fullscreen("blindblack", 30)

				M.UpdateDamageIcon()
				M.updatehealth()
				M.Life()		// Update just about everything else.

			for(var/mob/living/M in mob_list)
				M.captured = TRUE
				M.death()							// Kill any non-humans instantly.

			AM.color = color_cache
			AM.abyssfall = FALSE

			spawn(20)
				D.expel(H)
		else										// If AM isn't a human or contains a human, it's lost forever.
			for(var/mob/living/M in mob_list)
				qdel(M)			// We want to delete any mobs first so their ghosts (if they're player-controlled) end up in the spot where they fell.
			AM.loc = null
			qdel(AM)

/turf/unsimulated/abyss/proc/get_connected_chute()
	var/list/valid_chutes = list()
	for(var/obj/structure/disposaloutlet/no_deconstruct/abysschute/D in abyss_chutes)	// First, we try to pick a chute with a matching tag.
		if(D.abyss_link_tag == abyss_link_tag)											// If the tags match, add the chute to the list of possible picks.
			valid_chutes += D
	var/obj/structure/disposaloutlet/D = null
	if(valid_chutes.len)
		D = pick(valid_chutes)			// Then we pick one of the valid chutes.
	return D


var/global/list/abyss_chutes = list()
/obj/structure/disposaloutlet/no_deconstruct/abysschute
	name = "corpse chute"
	var/abyss_link_tag = ""

/obj/structure/disposaloutlet/no_deconstruct/abysschute/New()
	..()
	abyss_chutes += src

/obj/structure/disposaloutlet/no_deconstruct/abysschute/Destroy()
	abyss_chutes -= src
	..()


// This is a mapping object that links that sets the abyss_link_tag of the abyss turf it's placed on.
// It's whole purpose is just to make it easier to visualize which abyss turfs are linked in the map editor. That's all it does.
// Directly varediting the abyss_link_tag of the turf achieves the same effect.
/obj/effect/abysslinker
	name = "abyss linker"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	w_type=NOT_RECYCLABLE
	invisibility = 101
	var/abyss_link_tag = ""

/obj/effect/abysslinker/New()
	..()
	if(istype(loc, /turf/unsimulated/floor/abyss))
		var/turf/unsimulated/floor/abyss/A = loc
		A.abyss_link_tag = abyss_link_tag
	qdel(src) // Then we die!

/obj/effect/abysslinker/prisonarea
	abyss_link_tag = "prisonarea"
