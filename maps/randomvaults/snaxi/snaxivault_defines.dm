/************************************
            SNAXI VAULTS
    Please try to limit size to
    15x15 for ease of placement.

Included in this file
- Vault datums
- Vault atoms

************************************/

//Datums

/datum/map_element/snowvault
	type_abbreviation = "SV"
	var/base_turf_type = /turf/unsimulated/floor/snow

/datum/map_element/snowvault/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	var/zlevel_base_turf_type = get_base_turf(location.z)
	if(!zlevel_base_turf_type)
		zlevel_base_turf_type = /turf/space

	for(var/turf/new_turf in objects)
		if(new_turf.type == base_turf_type) //New turf is vault's base turf
			if(new_turf.type != zlevel_base_turf_type) //And vault's base turf differs from zlevel's base turf
				new_turf.ChangeTurf(zlevel_base_turf_type)

		new_turf.turf_flags |= NO_MINIMAP //Makes the spawned turfs invisible on minimaps

/datum/map_element/snowvault/cabin
	file_path = "maps/randomvaults/snaxi/cabin.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/crash
	file_path = "maps/randomvaults/snaxi/crash.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/kennel
	file_path = "maps/randomvaults/snaxi/kennel.dmm"

/datum/map_element/snowvault/grove
	file_path = "maps/randomvaults/snaxi/grove.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/hotspring
	file_path = "maps/randomvaults/snaxi/hotspring.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/deerfeeder
	file_path = "maps/randomvaults/snaxi/deerfeeder.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/wolfcave
	file_path = "maps/randomvaults/snaxi/wolfcave.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/thermalplant
	file_path = "maps/randomvaults/snaxi/thermalplant.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/construction_site
	file_path = "maps/randomvaults/snaxi/construction_site.dmm"

/datum/map_element/snowvault/santacabin
	file_path = "maps/randomvaults/snaxi/santacabin.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/frozenpond
	file_path = "maps/randomvaults/snaxi/frozenpond.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/rockysnow
	file_path = "maps/randomvaults/snaxi/rockysnow.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/bus_stop
	file_path = "maps/randomvaults/snaxi/bus_stop.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/buriedbody
	file_path = "maps/randomvaults/snaxi/buriedbody.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/guncache
	file_path = "maps/randomvaults/snaxi/guncache.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/mine_patch
	file_path = "maps/randomvaults/snaxi/mine_patch.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/lostsnowmobile
	file_path = "maps/randomvaults/snaxi/lostsnowmobile.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/bearcave
	file_path = "maps/randomvaults/snaxi/bearcave.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/trees
	file_path = "maps/randomvaults/snaxi/trees.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/geysercluster
	file_path = "maps/randomvaults/snaxi/geysercluster.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/unfrozen_pond
	file_path = "maps/randomvaults/snaxi/unfrozen_pond.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/greatwhite
	file_path = "maps/randomvaults/snaxi/greatwhite.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/witchsabbath
	file_path = "maps/randomvaults/snaxi/witchsabbath.dmm"
	can_rotate = TRUE

/datum/map_element/snowvault/huntinggrounds
	file_path = "maps/randomvaults/snaxi/huntinggrounds.dmm"
	can_rotate = TRUE

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
		spawn(1 MINUTES)
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