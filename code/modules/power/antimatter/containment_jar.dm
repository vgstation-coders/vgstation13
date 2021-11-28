/obj/item/weapon/am_containment
	name = "antimatter containment jar"
	desc = "Holds antimatter. A few of these could blow an entire 21st-century lunar installation."
	icon = 'icons/obj/machines/new_ame.dmi'
	icon_state = "jar"
	item_state = "am_jar"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	density = 0
	anchored = 0
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 2

	var/fuel = 1000 // WAS ORIGINALLY 10000
	var/fuel_max = 1000//Lets try this for now
	var/stability = 100//TODO: add all the stability things to this so its not very safe if you keep hitting in on things
	var/exploded = 0
	var/gauge_offset = 0

/obj/item/weapon/am_containment/New()
	..()
	update_icon()

/obj/item/weapon/am_containment/update_icon()
	overlays.len = 0

	var/fullness = round((fuel/fuel_max) * 8)

	var/image/I = image(icon, src, "gauge_[fullness]")
	I.pixel_x = gauge_offset
	overlays += I

/obj/item/weapon/am_containment/proc/boom()
	var/percent = 0
	if(fuel)
		percent = (fuel / fuel_max) * 100
	if(!exploded && percent >= 10)
		explosion(get_turf(src), 1, 2, 3, 5)//Should likely be larger but this works fine for now I guess
		exploded=1
	if(src)
		qdel(src)

/obj/item/weapon/am_containment/ex_act(severity)
	switch(severity)
		if(1.0)
			boom()
		if(2.0)
			if(prob((fuel/10)-stability))
				boom()
			stability -= 40
		if(3.0)
			stability -= 20
	//check_stability()
	return

/obj/item/weapon/am_containment/proc/usefuel(var/wanted)
	if(fuel < wanted)
		wanted = fuel
	fuel -= wanted
	update_icon()
	return wanted

/obj/item/weapon/am_containment/big
	icon_state = "jar_big"
	fuel = 10000
	fuel_max = 10000
	gauge_offset = 2

/obj/item/weapon/am_containment/huge
	icon_state = "jar_huge"
	fuel = 30000
	fuel_max = 30000
	gauge_offset = 6
