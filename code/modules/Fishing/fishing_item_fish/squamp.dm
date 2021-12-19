/obj/item/weapon/stamp/squamp
	name = "squamp"
	desc = ""
	icon = ''
	icon_state = ""
	item_state = ""
	_color = "squamp"
	attack_verb = list("squamps")
	var/squink = 0
	var/squRange = 1

/obj/item/weapon/stamp/squamp/New()
	..()
	create_reagents(1200)
	reagents.add_reagent(INK, 5)

/obj/item/weapon/stamp/squamp/angler_effect(obj/item/weapon/bait/baitUsed)
	//You need to look at smoke code again to see if each cloud is the volume or if it's divided between them
	//Also squRange can probably be replaced with squink and some math
	//Also also make ink transferrable via squamp milking into a beaker

/obj/item/weapon/stamp/squamp/throw_impact(var/atom/hit_atom, var/speed, var/mob/user)
	for(var/turf/T in range(squRange, get_turf(src)))
		var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
		S.attach(T)
		S.set_up(src, squRange, 0, T)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1)
		S.start()
		reagents.clear_reagents()


/datum/reagent/ink	//NtS: Make super sure bleach and washing machines actually removes this
	name = "Ink"
	id = INK
	description = "A standard multipurpose dye."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#000000"
	var/dyePotency = 5	//Just so you can't make everything black with an eye dropper

/datum/reagent/ink/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(2)

/datum/reagent/ink/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1
	if(method == TOUCH)
		for(var/obj/item/I in M.get_all_slots())
			if(!dyeThing(I))
				break	//Attempts to dye the thing, stops the loop if there's no volume left
		dyeThing(M)

/datum/reagent/ink/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1
	dyeThing(O)

/datum/reagent/ink/proc/dyeThing(var/atom/movable/A)
	if(volume >= dyePotency)
		A.color = color		//This is actually adding color to the existing icon, not just making it entirely black.
		volume -= dyePotency
		return TRUE
	return FALSE
