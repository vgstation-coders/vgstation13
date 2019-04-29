//Cyborg Beer
/obj/item/weapon/reagent_containers/glass/replenishing/cyborg
	name = "brobot's space beer"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "beer"
	reagent_list = BEER
	artifact = FALSE
	can_be_placed_into = null
	units_per_tick = 1
	var/synth_cost = 30 // 1500 cell charge for 50u beer

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/fits_in_iv_drip()
	return FALSE

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/process()
	if(isrobot(loc))
		var/mob/living/silicon/robot/robot = loc
		if(robot && robot.cell)
			if(reagents.total_volume < reagents.maximum_volume) // don't recharge reagents and drain power if the storage is full
				robot.cell.use(synth_cost)
				..()

/obj/item/weapon/reagent_containers/glass/replenishing/cyborg/hacked
	name = "mickey finn's special brew"
	reagent_list = BEER2
	units_per_tick = 0.3
	synth_cost = 25 //4165 cell charge for 50u !NotShitterJuice.
