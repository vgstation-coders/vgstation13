// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/weapon/cell/New()
	..()
	charge = maxcharge
	if(maxcharge <= 2500)
		desc = "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it."
	else
		desc = "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!"
	spawn(5)
		updateicon()

/obj/item/weapon/cell/proc/updateicon()
	overlays.len = 0

	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('icons/obj/power.dmi', "cell-o2")
	else
		overlays += image('icons/obj/power.dmi', "cell-o1")

/obj/item/weapon/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

// use power from a cell
/obj/item/weapon/cell/proc/use(var/amount)
	if(rigged && amount > 0)
		explode()
		return 0

	if(charge < amount)
		return 0
	charge = max(0,charge - amount)
	return 1

// recharge the cell
/obj/item/weapon/cell/proc/give(var/amount)
	if(rigged && amount > 0)
		explode()
		return 0

	if(maxcharge <= charge)
		return 0
	var/power_used = min(maxcharge-charge,amount)
	if(crit_fail)
		return 0
	if(!prob(reliability))
		minor_fault++
		if(prob(minor_fault))
			crit_fail = 1
			return 0
	charge += power_used
	return power_used


/obj/item/weapon/cell/examine(mob/user)
	..()
	if(crit_fail)
		to_chat(user, "<span class='warning'>This power cell seems to be faulty.</span>")
	else
		to_chat(user, "<span class='info'>The charge meter reads [round(src.percent() )]%.</span>")

/obj/item/weapon/cell/attack_self(mob/user as mob)
	src.add_fingerprint(user)

/obj/item/weapon/cell/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = W

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent(PLASMA, 5))

			rigged = 1

			log_admin("LOG: [user.name] ([user.ckey]) injected a power cell with plasma, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a power cell with plasma, rigging it to explode.")

		S.reagents.clear_reagents()


/obj/item/weapon/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = 0
		corrupt()
		return FALSE
	//explosion(T, 0, 1, 2, 2)

	. = TRUE

	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")

	charge = 0
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	qdel(src)

/obj/item/weapon/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if (prob(10))
		rigged = 1 //broken batterys are dangerous

/obj/item/weapon/cell/emp_act(severity)
	var/powerloss = round(16 * sqrt(maxcharge) / severity, 50) //at severity 1, ~500 for 1000 power cells, ~2750 for 30,000 power cells
	charge = max(charge - powerloss, 0)
	if(reliability != 100 && prob(50/severity))
		reliability -= 10 / severity
	..()

/obj/item/weapon/cell/ex_act(severity)

	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(3.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
	return

/obj/item/weapon/cell/blob_act()
	if(prob(75))
		explode()

/obj/item/weapon/cell/proc/get_electrocute_damage()
	return round(charge**(1/3)*(rand(100,125)/100)) //Cube root of power times 1,5 to 2 in increments of 10^-1
	//For instance, gives an average of 81 damage for 100k W and 175 for 1M W
	//Best you're getting with BYOND's mathematical funcs. Not even a fucking exponential or neperian logarithm

/obj/item/weapon/cell/get_rating()
	return maxcharge / 10000
