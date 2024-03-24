var/list/infected_cleanables = list()

/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null	//Used so cleanbots can claim a mess.
	mouse_opacity = 0 //N3X made this 0, which made it impossible to click things, and in the current 510 version right-click things.
	w_type = NOT_RECYCLABLE
	anchored = 1

	var/reagent = null //what reagent did we come from? for wet/dry vac

	// For tracking shit across the floor.
	var/amount = 0 // 0 = don't track
	var/counts_as_blood = 0 // Cult
	var/transfers_dna = 0
	var/list/viruses = list()
	blood_DNA = list()
	var/basecolor = DEFAULT_BLOOD // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/list/absorbs_types = list() // Types to aggregate.

	var/on_wall = 0 //Wall on which this decal is placed on
	var/image/pathogen

	var/persistence_type = SS_CLEANABLE
	var/age = 1 //For map persistence. +1 per round that this item has survived. After a certain amount, it will not carry on to the next round anymore.
	var/persistent_type_replacement //If defined, the persistent item generated from this will be of this type rather than our own.
	var/fake_DNA = "random splatters"//for DNA-less splatters
	var/stain_name //a stained item will be described as "<stain_name>-stained" if stain_name isn't null. eg. stain_name = "vomit" -> "vomit-stained"

/obj/effect/decal/cleanable/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y)
	if(age)
		setPersistenceAge(age)
	if(icon_state)
		src.icon_state = icon_state
	else if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	if(color)
		src.color = color
	if(dir)
		src.dir = dir
	if(pixel_x)
		src.pixel_x = pixel_x
	if(pixel_y)
		src.pixel_y = pixel_y

	if(ticker)
		initialize()

	fixDNA()

	..(loc)

	blood_list += src
	update_icon()

	if(counts_as_blood)

		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (cult)
			cult.add_bloody_floor(get_turf(src))

		var/datum/faction/cult/narsie/legacy_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
		if(legacy_cult)
			var/turf/T = get_turf(src)
			if(T && (T.z == map.zMainStation))//F I V E   T I L E S
				if(istype(T, /turf/simulated/floor) && !isspace(T.loc) && !istype(T.loc, /area/asteroid) && !istype(T.loc, /area/mine) && !istype(T.loc, /area/vault) && !istype(T.loc, /area/prison) && !istype(T.loc, /area/vox_trading_post))
					if(!(locate("\ref[T]") in legacy_cult.bloody_floors))
						legacy_cult.bloody_floors += T
						legacy_cult.bloody_floors[T] = T
						if (legacy_cult.has_enough_bloody_floors())
							legacy_cult.getNewObjective()
		if(src.loc && isturf(src.loc))
			for(var/obj/effect/decal/cleanable/C in src.loc)
				if(C.type in absorbs_types && C != src)
					// Transfer DNA, if possible.
					if (transfers_dna && C.blood_DNA)
						blood_DNA |= C.blood_DNA.Copy()
					amount += C.amount
					qdel(C)
	spawn(1)//cleanables can get infected in many different ways when they spawn so it's much easier to handle the pathogen overlay here after a delay
		if (virus2 && virus2.len > 0)
			infected_cleanables += src
			if (!pathogen)
				pathogen = image('icons/effects/effects.dmi',src,"pathogen_blood")
				pathogen.plane = HUD_PLANE
				pathogen.layer = UNDER_HUD_LAYER
				pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
			for (var/mob/L in science_goggles_wearers)
				if (L.client)
					L.client.images |= pathogen


/obj/effect/decal/cleanable/proc/fixDNA()
	if (!istype(blood_DNA, /list))
		blood_DNA = list()
	blood_DNA[fake_DNA] = stain_name ? stain_name : "N/A"

/obj/effect/decal/cleanable/throw_impact(atom/hit_atom)
	if (isliving(hit_atom) && blood_DNA?.len)
		var/mob/living/L = hit_atom
		var/blood_data = list(
			"viruses"		=null,
			"blood_DNA"		=null,
			"blood_colour"	=null,
			"blood_type"	=null,
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/H = L
			if (blood_DNA?.len > 0)
				blood_data["blood_DNA"] = blood_DNA[1]
				blood_data["blood_type"] = blood_DNA[blood_DNA[1]]
			blood_data["virus2"] = virus_copylist(virus2)
			blood_data["blood_colour"] = basecolor
			H.bloody_body_from_data(copy_blood_data(blood_data),0,src)
			H.bloody_hands_from_data(copy_blood_data(blood_data),2,src)
			if (amount > 1)
				H.add_blood_to_feet(amount, basecolor, blood_DNA)
				amount--
		for(var/i = 1 to L.held_items.len)
			var/obj/item/I = L.held_items[i]
			if(istype(I))
				I.add_blood_from_data(blood_data)
	anchored = TRUE

/obj/effect/decal/cleanable/initialize()
	..()
	if(persistence_type)
		SSpersistence_map.track(src, persistence_type)

/obj/effect/decal/cleanable/getPersistenceAge()
	return age
/obj/effect/decal/cleanable/setPersistenceAge(nu)
	age = nu
	if(nu > 1)
		counts_as_blood = FALSE

/obj/effect/decal/cleanable/atom2mapsave()
	. = ..()
	if(persistent_type_replacement)
		.["type"] = persistent_type_replacement


/obj/effect/decal/cleanable/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/mop))
		return ..()
	return 0 //No more "X HITS THE BLOOD WITH AN RCD"

/obj/effect/decal/cleanable/Destroy()
	infected_cleanables -= src
	if (pathogen)
		for (var/mob/L in science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null

	blood_list -= src
	for(var/datum/disease/D in viruses)
		D.cure(0)
		D.holder = null

	if(counts_as_blood)
		bloodspill_remove()

	if(persistence_type)
		SSpersistence_map.forget(src, persistence_type)
	..()

/obj/effect/decal/cleanable/proc/dry(var/drying_age)
	name = "dried [replacetext(initial(src.name), "wet ", "")]"
	desc = "It's dry and crusty. Someone is not doing their job."
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/Crossed(atom/movable/A)
	if(ishuman(A))
		var/mob/living/carbon/human/perp = A
		if(amount > 1 && perp.on_foot())
			perp.add_blood_to_feet(amount, basecolor, blood_DNA)
			amount--

/obj/effect/decal/cleanable/proc/messcheck(var/obj/effect/decal/cleanable/M)
	return 1




///////////////////CULT BLOODSPILL STUFF/////////////////////////////////////

/obj/effect/decal/cleanable/proc/bloodspill_add()

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult)
		cult.add_bloody_floor(get_turf(src))

	//old cult
	var/datum/faction/cult/narsie/legacy_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
	if(legacy_cult)
		var/turf/T = get_turf(src)
		if(T && (T.z == map.zMainStation))//F I V E   T I L E S
			if(!(locate("\ref[T]") in legacy_cult.bloody_floors))
				legacy_cult.bloody_floors |= T
				legacy_cult.bloody_floors[T] = T
				if (legacy_cult.has_enough_bloody_floors())
					legacy_cult.getNewObjective()

/obj/effect/decal/cleanable/proc/bloodspill_remove()

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult)
		cult.remove_bloody_floor(get_turf(src))

	//old cult
	var/datum/faction/cult/narsie/legacy_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
	if(legacy_cult)
		var/turf/T = get_turf(src)
		if(T && (T.z == map.zMainStation))
			legacy_cult.bloody_floors -= T

/obj/effect/decal/cleanable/clean_act(var/cleanliness)
	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		qdel(src)
