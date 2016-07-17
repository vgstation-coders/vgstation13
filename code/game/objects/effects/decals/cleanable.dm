/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null	//Used so cleanbots can claim a mess.
	mouse_opacity = 1 //N3X made this 0, which made it impossible to click things, and in the current 510 version right-click things.
	w_type = NOT_RECYCLABLE
	anchored = 1

	// For tracking shit across the floor.
	var/amount=0 // 0 = don't track
	var/counts_as_blood=0 // Cult
	var/transfers_dna=0
	var/list/viruses = list()
	blood_DNA = list()
	var/basecolor="#A10808" // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/list/absorbs_types=list() // Types to aggregate.

	var/on_wall = 0 //Wall on which this decal is placed on

/obj/effect/decal/cleanable/New()
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	..()


/obj/effect/decal/cleanable/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/mop))
		return ..()
	return 0 //No more "X HITS THE BLOOD WITH AN RCD"

/obj/effect/decal/cleanable/Destroy()
	blood_list -= src
	for(var/datum/disease/D in viruses)
		D.cure(0)
		D.holder = null

	if(counts_as_blood)
		var/datum/game_mode/cult/cult_round = find_active_mode("cult")
		if(cult_round)
			var/turf/T = get_turf(src)
			if(T && (T.z == map.zMainStation))
				cult_round.bloody_floors -= T
				cult_round.blood_check()
	..()

/obj/effect/decal/cleanable/proc/dry()
	name = "dried [src.name]"
	desc = "It's dry and crusty. Someone is not doing their job."
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/Crossed(mob/living/carbon/human/perp)
	if(amount > 0)
		add_blood_to(perp, amount)

/obj/effect/decal/cleanable/attack_hand(mob/living/carbon/human/user)
	..()
	if (amount && istype(user))
		add_fingerprint(user)
		if (user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		to_chat(user, "<span class='notice'>You get some of \the [src] on your hands.</span>")
		if(transfers_dna)
			if (!user.blood_DNA)
				user.blood_DNA = list()
			user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.hand_blood_color = basecolor
		user.update_inv_gloves(1)
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/resetVariables()
	Destroy()
	..("viruses","virus2", "blood_DNA", "random_icon_states", args)
	viruses = list()
	virus2 = list()
	blood_DNA = list()

/obj/effect/decal/cleanable/New()
	..()
	blood_list += src
	update_icon()

	if(counts_as_blood)
		var/datum/game_mode/cult/cult_round = find_active_mode("cult")
		if(cult_round)
			var/turf/T = get_turf(src)
			if(T && (T.z == map.zMainStation))//F I V E   T I L E S
				if(!(locate("\ref[T]") in cult_round.bloody_floors))
					cult_round.bloody_floors += T
					cult_round.bloody_floors[T] = T
					cult_round.blood_check()
		if(src.loc && isturf(src.loc))
			for(var/obj/effect/decal/cleanable/C in src.loc)
				if(C.type in absorbs_types && C != src)
					// Transfer DNA, if possible.
					if (transfers_dna && C.blood_DNA)
						blood_DNA |= C.blood_DNA.Copy()
					amount += C.amount
					returnToPool(C)

/obj/effect/decal/cleanable/proc/messcheck(var/obj/effect/decal/cleanable/M)
	return 1


/obj/effect/decal/cleanable/proc/add_blood_to(var/mob/living/carbon/human/perp, var/amount)
	if (!istype(perp))
		return
	if(amount < 1)
		return
	if(perp.shoes)
		var/obj/item/clothing/shoes/S = perp.shoes
		S.track_blood = max(0, amount, S.track_blood)                //Adding blood to shoes

		if(!blood_overlays[S.type]) //If there isn't a precreated blood overlay make one
			S.generate_blood_overlay()

		if(S.blood_overlay != null) // Just if(blood_overlay) doesn't work.  Have to use isnull here.
			S.overlays.Remove(S.blood_overlay)
		else
			S.blood_overlay = blood_overlays[S.type]

		S.blood_overlay.color = basecolor
		S.overlays += S.blood_overlay
		S.blood_color=basecolor

		if(!S.blood_DNA)
			S.blood_DNA = list()
		if(blood_DNA)
			S.blood_DNA |= blood_DNA.Copy()
		perp.update_inv_shoes(1)

	else
		perp.track_blood = max(amount, 0, perp.track_blood)                                //Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		if(!istype(blood_DNA, /list))
			blood_DNA = list()
		else
			perp.feet_blood_DNA |= blood_DNA.Copy()
		perp.feet_blood_color=basecolor

	amount--
