//Vault atoms

/area/vault/thermalplant
	name = "thermal plant"
	requires_power = 1

/area/vault/wolfcave
	name = "wolf cave"

/area/vault/kennel
	name = "kennels"

/area/vault/hotspring
	name = "hotspring"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/bahamamama/New()
	..()
	reagents.add_reagent(BAHAMA_MAMA, 30)

/mob/living/simple_animal/capybara
	name = "capybara"
	desc = "The capybara is the largest of the rodents. This one looks rather peaceful."
	pacify_aura = TRUE
	icon_state = "capybara"
	icon_living = "capybara"
	icon_dead = "capybara-dead"
	response_help = "pets"
	var/rest_time = 1 MINUTES

/mob/living/simple_animal/capybara/examine(mob/user)
	..()
	if(!isDead() && pacify_aura)
		to_chat(user, "<span class = 'notice'>It looks so comforting, you feel like the world, at least in the general vicinity, is at peace.</span>")

/mob/living/simple_animal/capybara/update_icons()
	if(isDead())
		icon_state = "capybara-dead"
		return
	icon_state = "capybara[lying ? "-rest" : ""]"

/mob/living/simple_animal/capybara/wander_move()
	if(prob(15)) //15% chance that instead of wandering, he'll rest for a minute
		lying = TRUE
		wander = FALSE
		update_icons()
		spawn(rest_time)
			lying = FALSE
			wander = TRUE
			update_icons()
	else
		..()

/mob/living/simple_animal/capybara/Move(NewLoc,Dir=0,step_x=0,step_y=0,var/glide_size_override = 0)
	if(lying && !isDead()) //He'll get up if something moves him
		lying = FALSE
		wander = TRUE
		update_icons()
	return ..()

/area/vault/cabin
	name = "cabin"

/obj/machinery/space_heater/campfire/stove/fireplace/preset/New()
	..()
	new /obj/item/clothing/shoes(src) //create stockings
	cell.charge = cell.maxcharge
	update_icon()

/obj/structure/reagent_dispensers/cauldron/witch/New()
	..()
	name = "witch's cauldron"
	reagents.add_reagent(MUTAGEN, 100)

/area/vault/bearcave
	name = "bear cave"

/mob/living/simple_animal/hostile/asteroid/goliath/snow/great
	name = "great white goliath"
	size = SIZE_HUGE
	maxHealth = 400
	health = 400
	pixel_y = 16 * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/asteroid/goliath/snow/great/New()
	..()
	appearance_flags |= PIXEL_SCALE
	var/matrix/M = matrix()
	M.Scale(2,2)
	transform = M

/mob/living/simple_animal/hostile/asteroid/goliath/snow/great/death(gibbed)
	..()
	for(var/amount = 1 to 3)
		new /obj/item/bluespace_crystal(src)
