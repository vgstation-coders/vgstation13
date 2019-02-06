/mob/living/simple_animal/pollywog
	name = "shifting mass"
	desc = "Its dark skin seems to shift and contort, as if it were changing constantly within."
	icon = 'icons/mob/mob.dmi'
	icon_state = "pollywog"
	var/changing = FALSE

/mob/living/simple_animal/pollywog/Life()
	.=..()
	if(!.)
		return

	if(!changing && prob(30))
		changing = TRUE
		var/list/possible_mobs = (minor_mobs + major_mobs) - (boss_mobs+blacklisted_mobs)
		transmogrify(pick(possible_mobs))
		spawn(rand(30 SECONDS, 60 SECONDS))
			completely_untransmogrify()
			changing = FALSE

/mob/living/simple_animal/pollywog/death()
	visible_message("<span class = 'warning'>\The [src] exhales, bursting forth strange energy from within.</span>")
	empulse(get_turf(src),2,4)
	qdel(src)
	..(TRUE)