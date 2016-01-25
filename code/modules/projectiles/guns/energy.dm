/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	fire_sound = 'sound/weapons/Taser.ogg'

	var/obj/item/weapon/cell/power_supply //What type of power cell this uses
	var/charge_cost = 100 //How much energy is needed to fire.
	var/cell_type = "/obj/item/weapon/cell"
	var/projectile_type = "/obj/item/projectile/beam/practice"
	var/modifystate
	var/charge_states = 1 //if the gun changes icon states depending on charge, this is 1. Uses a var so it can be changed easily

/obj/item/weapon/gun/energy/emp_act(severity)
	power_supply.use(round(power_supply.maxcharge / severity))
	update_icon()
	..()

/obj/item/weapon/gun/energy/process_chambered()
	if(in_chamber)	return 1
	if(!power_supply)	return 0
	if(!power_supply.use(charge_cost))	return 0
	if(!projectile_type)	return 0
	in_chamber = new projectile_type(src)
	return 1

/obj/item/weapon/gun/energy/update_icon()
	var/ratio = 0

	if(power_supply && power_supply.maxcharge > 0) //If the gun has a power cell, calculate how much % power is left in it
		ratio = power_supply.charge / power_supply.maxcharge

	//If there's no power cell, the gun looks as if it had an empty power cell

	ratio *= 100
	ratio = Clamp(ratio, 0, 100) //Value between 0 and 100

	if(ratio >= 50)
		ratio = Floor(ratio, 25)
	else
		ratio = Ceiling(ratio, 25)

	if(modifystate && charge_states)
		icon_state = "[modifystate][ratio]"
	else if(charge_states)
		icon_state = "[initial(icon_state)][ratio]"

/obj/item/weapon/gun/energy/New()
	. = ..()

	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)

	power_supply.give(power_supply.maxcharge)

/*
/obj/item/weapon/gun/energy/Destroy()
	if(power_supply)
		power_supply.loc = get_turf(src)
		power_supply = null

	..()
*/