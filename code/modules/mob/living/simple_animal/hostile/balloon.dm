/mob/living/simple_animal/hostile/balloon
	name = "balloon animal"
	desc = "More dangerous than it looks."
	icon = 'icons/obj/toy.dmi'
	icon_state = "dog_balloon"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = 1
	maxHealth = 25
	health = 25
	size = SIZE_SMALL
	mob_property_flags = MOB_CONSTRUCT

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "balloon"

	var/datum/gas_mixture/air_contents = null
	var/col = "#FFFFFF"

/mob/living/simple_animal/hostile/balloon/New(atom/A, var/chosen_col, var/new_icon_state)
	..(A)
	if(col)
		if(chosen_col)
			col = chosen_col
		else
			col = rgb(rand(0,255),rand(0,255),rand(0,255))
		color = col
	if(new_icon_state)
		icon_state = new_icon_state
	update_icon()

/mob/living/simple_animal/hostile/balloon/update_icon()
	overlays.len = 0
	var/image/shine_overlay = image('icons/obj/toy.dmi', src, "[icon_state]_shine")
	shine_overlay.appearance_flags = RESET_COLOR
	overlays += shine_overlay

/mob/living/simple_animal/hostile/balloon/CanAttack(var/atom/the_target)
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(M_CLUMSY in L.mutations)
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/balloon/FindTarget()
	. = ..()
	if(.)
		emote("me",,"squeaks at [.].")

/mob/living/simple_animal/hostile/balloon/AttackingTarget()
	if(!target)
		return

	. =..()
	var/mob/living/carbon/L = .
	if(istype(L))
		if(prob(15))
			L.Knockdown(3)
			L.Stun(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/balloon/attackby(obj/item/W, mob/user)
	if(W.sharpness_flags & (SHARP_TIP|HOT_EDGE))
		user.visible_message("<span class='warning'>\The [user] pops \the [src]!</span>","You pop \the [src].")
		pop()
		return
	..()

/mob/living/simple_animal/hostile/balloon/proc/pop()
	playsound(src, 'sound/misc/balloon_pop.ogg', 100, 1)
	if(air_contents)
		loc.assume_air(air_contents)
	if(living_balloons.len)
		for(var/obj/item/toy/balloon/inflated/long/shaped/B in living_balloons)
			if(get_turf(src) in view(B))
				B.live()
	death()

/mob/living/simple_animal/hostile/balloon/death(var/gibbed = FALSE)
	..(TRUE)
	qdel(src)
