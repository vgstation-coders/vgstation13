
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/crap"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/Taser.ogg'
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/taser/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/taser/cyborg/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/taser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0

	if(!power_supply)
		return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			R.cell.use(charge_cost) 		//Take power from the borg...
			power_supply.give(charge_cost)	//... to recharge the shot

	update_icon()
	return 1

/obj/item/weapon/gun/energy/taser/cyborg/restock()
	if(power_supply.charge < power_supply.maxcharge)
		power_supply.give(charge_cost)
		update_icon()
	else
		charge_tick = 0


/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
	icon_state = "stunrevolver"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/Gunshot.ogg'
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=3;" + Tc_POWERSTORAGE + "=2"
	charge_cost = 125
	projectile_type = "/obj/item/projectile/energy/electrode"
	cell_type = "/obj/item/weapon/cell"

/obj/item/weapon/gun/energy/stunrevolver/failure_check(var/mob/living/carbon/human/M)
	if(damaged && prob(25))
		power_supply.use(125)
		to_chat(M, "<span class='warning'>The [name] buzzes.</span>")
		return 1
	if(damaged && prob(10))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		M.apply_effects(8,8,,,8)
		power_supply.use(250)
		to_chat(M, "<span class='danger'>The [name] shocks you!.</span>")
		return 0
	if(damaged && prob(1))
		to_chat(M, "<span class='danger'>The [name] explodes!.</span>")
		explosion(get_turf(loc), 0, 0, 1)
		M.drop_item(src, force_drop = 1)
		qdel(src)
		return 0
	return 1



/obj/item/weapon/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = W_CLASS_SMALL
	item_state = "crossbow"
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_COMBAT + "=2;" + Tc_MAGNETS + "=2;" + Tc_SYNDICATE + "=5"
	silenced = 1
	fire_sound = 'sound/weapons/ebow.ogg'
	projectile_type = "/obj/item/projectile/energy/bolt"
	cell_type = "/obj/item/weapon/cell/crap"
	var/charge_tick = 0


/obj/item/weapon/gun/energy/crossbow/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/crossbow/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/crossbow/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	return 1


/obj/item/weapon/gun/energy/crossbow/update_icon()
	return


/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate infiltration teams."
	w_class = W_CLASS_LARGE
	force = 10
	starting_materials = list(MAT_IRON = 200000)
	w_type = RECYK_ELECTRONIC
	projectile_type = "/obj/item/projectile/energy/bolt/large"

/obj/item/weapon/gun/energy/crossbow/largecrossbow/failure_check(var/mob/living/carbon/human/M)
	if(damaged && silenced && prob(50))
		silenced = 0
		to_chat(M, "<span class='warning'>The [name] makes a noise.</span>")
		return 1
	if(damaged && prob(20))
		M.apply_effect(rand(10,25), IRRADIATE)
		to_chat(M, "<span class='warning'>The [name] feels warm for a moment.</span>")
		return 1
	if(damaged && prob(5))
		power_supply.maxcharge = 0
		power_supply.charge = 0
		to_chat(M, "<span class='warning'>The [name] fizzles.</span>")
		return 0
	return 1


