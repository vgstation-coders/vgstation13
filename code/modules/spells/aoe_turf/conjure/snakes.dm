/spell/aoe_turf/conjure/snakes
	name = "Become Snakes"
	desc = "This spell transforms your body into a den of snakes."

	summon_type = list(/mob/living/simple_animal/cat/snek/wizard)

	price = Sp_BASE_PRICE / 2
	range = 3
	charge_max = 300
	invocation = "WI'L OV SHNISSUGAH"
	hud_state = "wiz_snakes"

	duration = 0
	summon_amt = 49

/spell/aoe_turf/conjure/snakes/cast(list/targets, mob/user)
	if(wizard_snakes)
		for(var/mob/M in wizard_snakes)
			qdel(M)
	if(!..())
		user.visible_message("<span class='warning'>\The [user]'s body splits into a mass of snakes!</span>","<span class='notice'>Your body splits into a mass of snakes.</span>")
		user.transmogrify(/mob/living/simple_animal/cat/snek/wizard, TRUE)