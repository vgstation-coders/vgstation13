/spell/aoe_turf/conjure/snakes
	name = "Become Snakes"
	desc = "This spell transforms your body into a den of snakes."
	user_type = USER_TYPE_WIZARD
	specialization = DEFENSIVE

	summon_type = list(/mob/living/simple_animal/cat/snek/wizard)

	price = Sp_BASE_PRICE / 2
	range = 3
	charge_max = 300
	invocation = "WI'L OV SHNISSUGAH"
	hud_state = "wiz_snakes"

	duration = 0
	summon_amt = 49

/spell/aoe_turf/conjure/snakes/cast(list/targets, mob/user)
	delete_snakes()
	if(!..())
		user.visible_message("<span class='warning'>\The [user]'s body splits into a mass of snakes!</span>","<span class='notice'>Your body splits into a mass of snakes.</span>")
		user.transmogrify(/mob/living/simple_animal/cat/snek/wizard, TRUE)

/spell/aoe_turf/conjure/snakes/summon_object(var/type, var/location)
	return new type(location, holder)

/spell/aoe_turf/conjure/snakes/on_holder_death(mob/user)
	delete_snakes(user)

/spell/aoe_turf/conjure/snakes/proc/delete_snakes(mob/user)
	if(!user)
		user = holder
	if(wizard_snakes)
		for(var/mob/M in wizard_snakes)
			if(wizard_snakes[M] == user)
				wizard_snakes[M] = null
				wizard_snakes -= M
				qdel(M)

/spell/aoe_turf/conjure/snakes/choose_targets(mob/user = usr)
	center = pick(view_or_range(range, holder, selection_type))
	return ..()