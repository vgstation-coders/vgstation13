/obj/item/am_containment
	name = "antimatter containment jar"
	desc = "Holds antimatter."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "jar"
	density = FALSE
	anchored = FALSE
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	var/fuel = 10000
	var/fuel_max = 10000//Lets try this for now
	var/stability = 100//TODO: add all the stability things to this so its not very safe if you keep hitting in on things


/obj/item/am_containment/ex_act(severity, target)
	switch(severity)
		if(1)
			explosion(get_turf(src), 1, 2, 3, 5)//Should likely be larger but this works fine for now I guess
			if(src)
				qdel(src)
		if(2)
			if(prob((fuel/10)-stability))
				explosion(get_turf(src), 1, 2, 3, 5)
				if(src)
					qdel(src)
				return
			stability -= 40
		if(3)
			stability -= 20
	//check_stability()
	return

/obj/item/am_containment/proc/usefuel(wanted)
	if(fuel < wanted)
		wanted = fuel
	fuel -= wanted
	return wanted