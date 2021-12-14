/obj/item/weapon/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = Tc_POWERSTORAGE + "=1"
	flags = FPRINT
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL // Rugged
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/brute_damage = 0 //Used by cyborgs
	var/electronics_damage = 0 //Used by cyborgs
	var/starch_cell = 0
	var/mob/living/simple_animal/hostile/pulse_demon/occupant

/obj/item/weapon/cell/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	electrocute_mob(user, get_area(src), src, 2)
	return (SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/cell/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = Tc_POWERSTORAGE + "=0"
	maxcharge = 500
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 40)

/obj/item/weapon/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/crap/better
	name = "\improper Nanotrasen brand rechargeable D battery"
	maxcharge = 700 //for the ion carbine

/obj/item/weapon/cell/secborg
	name = "\improper Security borg rechargeable D battery"
	origin_tech = Tc_POWERSTORAGE + "=0"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 40)


/obj/item/weapon/cell/secborg/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/miningborg
	name = "\improper Mining borg rechargeable D battery"
	origin_tech = Tc_POWERSTORAGE + "=0"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 40)


/obj/item/weapon/cell/miningborg/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/high
	name = "high-capacity power cell"
	origin_tech = Tc_POWERSTORAGE + "=2"
	icon_state = "hcell"
	maxcharge = 10000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 60)

/obj/item/weapon/cell/high/cyborg
	name = "cyborg rechargeable power cell"
	maxcharge = 7500

/obj/item/weapon/cell/high/mecha
	name = "custom high-capacity power cell"
	maxcharge = 15000

/obj/item/weapon/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/super
	name = "super-capacity power cell"
	origin_tech = Tc_POWERSTORAGE + "=5"
	icon_state = "scell"
	maxcharge = 20000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 70)

/obj/item/weapon/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = Tc_POWERSTORAGE + "=6"
	icon_state = "hpcell"
	maxcharge = 30000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 80)

/obj/item/weapon/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	origin_tech = Tc_POWERSTORAGE + "=1"
	icon = 'icons/obj/power.dmi'
	icon_state = "potato_cell"
	charge = 100
	maxcharge = 300
	starting_materials = null
	w_type = RECYK_BIOLOGICAL
	minor_fault = 1
	starch_cell = 1

/obj/item/weapon/cell/potato/soviet
	charge = 15000
	maxcharge = 15000
	minor_fault = 0

/obj/item/weapon/cell/crepe
	name = "power crêpe"
	desc = "Warning: May contain dairy products, 12,000kJ of searing death, gluten."
	origin_tech = Tc_POWERSTORAGE + "=3"
	icon_state = "power_crepe"
	maxcharge = 12000
	charge = 12000
	w_type = RECYK_BIOLOGICAL
	minor_fault = 1
	starch_cell = 1

/obj/item/weapon/cell/crepe/mommi
	maxcharge = 10000
	charge = 10000
	minor_fault = 0

/obj/item/weapon/cell/crepe/attack_self(var/mob/living/user)
	if(charge)
		user.visible_message("<span class = 'notice'>\The [user] takes a bite out of \the [src]</span>", "<span class = 'warning'>You take a bite out of \the [src]</span>")
		spawn(rand(1,3) SECONDS)
			var/power_to_use = min(charge, rand(800,1200))
			playsound(loc, 'sound/effects/eleczap.ogg', 80, 1)
			if(use(power_to_use))
				user.adjustFireLoss(power_to_use/100) //So 8 to 12 damage
				user.visible_message("<span class = 'notice'>\The [user] is electrocuted by \the [src]</span>", "<span class = 'warning'>You are [pick("frazzled","electrocuted","zapped")] by \the [src]!</span>")
				if(!user.light_range)
					user.set_light(2,2,"#ffff00")
					spawn(power_to_use/100 SECONDS)
						user.kill_light()
	else
		to_chat(user, "<span class = 'notice'>\The [src] doesn't seem to have much of a tingle to it.</span>")

/obj/item/weapon/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = Tc_POWERSTORAGE + "=2;" + Tc_BIOTECH + "=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 30000
	starting_materials =  null
	w_type = RECYK_BIOLOGICAL


/obj/item/weapon/cell/temperaturegun
	name = "temperature gun cell"
	desc = "A specially designed power cell for heating and cooling projectiles."
	icon_state = "icell"
	maxcharge = 900

/obj/item/weapon/cell/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"charge",
		"rigged",
		"minor_fault",
		"brute_damage",
		"electronics_damage")

	reset_vars_after_duration(resettable_vars, duration)


/obj/item/weapon/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech = null
	maxcharge = 35000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 80)

/obj/item/weapon/cell/infinite/New()
	..()
	desc = "This cell is the latest in NT technology, having the capability to perpetually recharge itself. It has a power rating of Infinity!"

/obj/item/weapon/cell/infinite/use()
	..()
	charge = maxcharge
	return 1

/obj/item/weapon/cell/ultra
	name = "ultra-capacity power cell"
	origin_tech = Tc_POWERSTORAGE + "=8"
	icon_state = "ucell"
	maxcharge = 50000
	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 80)

/obj/item/weapon/cell/ultra/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/rad
	name = "RTG power cell"
	origin_tech = Tc_POWERSTORAGE + "=7"
	icon_state = "rcell"
	maxcharge = 1000
	starting_materials = list(MAT_IRON = 600, MAT_GLASS = 90, MAT_URANIUM = 40)
	var/charge_rate = 100
	var/damaged = FALSE
	
/obj/item/weapon/cell/rad/empty/New()
	..()
	charge = 0

/obj/item/weapon/cell/rad/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/cell/rad/Destroy()
	..()
	processing_objects.Remove(src)

/obj/item/weapon/cell/rad/give()
	return

/obj/item/weapon/cell/rad/process()
	if(!maxcharge && prob(5)) //5% chance to explode every 2 seconds if the cell is broken
		explosion(loc, 0, 1, 2, 2)
		qdel(src)
	if(maxcharge <= charge)
		return 0
	var/power_used = min(maxcharge-charge,charge_rate)
	charge += power_used
	if(prob(5))
		for(var/mob/living/L in view(get_turf(src), max(5,(maxcharge/charge))))
			L.apply_radiation(charge_rate/10, RAD_EXTERNAL)
	if(charge_rate < (initial(charge_rate)/10))	//turns into a broken cell with no charge rate, 0 max charge and a 5% chance to explode every 2s
		name = "broken cell"
		icon_state = "cell"
		starting_materials = list(MAT_IRON = 200, MAT_GLASS = 30)
		charge = 0
		maxcharge = 0
		charge_rate = 0
		damaged = FALSE //so you don't get the damaged examine if the cell is broken
		desc = "The inner circuitry melted and the paint flaked off. It bulges slightly at the sides. <span class='warning'>It's going to explode any moment now.</span>"

		
/obj/item/weapon/cell/rad/emp_act(severity)
	..()
	if(maxcharge > 0)
		switch(rand(3))
			if(0)
				charge_rate *= severity*0.2
				damaged = TRUE
			if(1)
				maxcharge *= severity*0.2
				charge = 0
			if(2)
				maxcharge *= severity*0.2
				charge = 0
				charge_rate *= severity*0.2
				damaged = TRUE
			
/obj/item/weapon/cell/rad/examine(mob/user)
	..()
	if(damaged)
		to_chat(user, "<span class='warning'>Seems to be damaged as if it were leaking power, you estimate that it selfcharges [(1-charge_rate/initial(charge_rate))*100]% slower than normal.</span>")

/obj/item/weapon/cell/rad/large
	name = "PDTG power cell"
	origin_tech = Tc_POWERSTORAGE + "=9"
	icon_state = "pcell"
	maxcharge = 2500
	starting_materials = list(MAT_IRON = 600, MAT_GLASS = 90, MAT_PHAZON = 100)
	charge_rate = 250

/obj/item/weapon/cell/rad/large/empty/New()
	..()
	charge = 0
