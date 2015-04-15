/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light. Runs on batteries, and usually runs out of power whenever least convenient."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = 2
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	m_amt = 50
	g_amt = 20
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL //Assuming big beefy fucking maglite.
	action_button_name = "Toggle Light"
	var/on = 0
	var/brightness_on = 4 //luminosity when on
	var/battery_needed = 1 //Penlights and flares shouldn't use batteries, the rest should
	var/obj/item/weapon/cell/fcell = null //That's our cell !
	var/panelopen = 0 //The battery panel is open or closed, not used if there's no battery
	var/powercost = 5 //How much juice does it use per tick when lit ? For reference, the starting cell has 1000 W
	var/flickerprob = 0 //How likely that we go through flickering
	var/flickering = 0 //Used to avoid spam
	var/flickerthreshold = 60 //To make sure full flashlight batteries don't cause flickering

/obj/item/device/flashlight/New() //All flashlights start with a cell, otherwise we don't care

	if(battery_needed)
		fcell = new(src)
		fcell.charge = fcell.maxcharge //Charge this shit
		fcell.updateicon()
	..()

/obj/item/device/flashlight/initialize()

	..()
	if(on)
		SetLuminosity(brightness_on)
	else
		SetLuminosity(0)
	update_icon()

/obj/item/device/flashlight/update_icon()

	if(on)
		icon_state = "[initial(icon_state)]-on"
		item_state = "[initial(item_state)]-on"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	if(battery_needed)
		if(panelopen)
			if(fcell)
				icon_state = "[icon_state]-p-c"
			else
				icon_state = "[icon_state]-p-nc"

//This thing uses a hack to circumvent lighting not working in containers (a mob's hands or pockets being a container)
//It tends to break sometimes too, for good measure
//Now uses ismob(loc) to cut down on the bullshit, the proc checks if it needs to deduct lighting from a mob itself
//Note to coders : DO NOT EVER FIRE THIS UNLESS YOU TOGGLE A LIGHT ON OR OFF BEFOREHAND. AND NO, CERTAINLY NOT IF YOU UPDATE BRIGHTNESS_ON (see flare process for a work-around)
/obj/item/device/flashlight/proc/update_brightness()

	if(on)
		processing_objects += src //We add it here because this proc always fire (or is supposed to) when the flashlight is toggled
		if(ismob(loc))
			var/mob/carrier = loc
			carrier.SetLuminosity(carrier.luminosity + brightness_on)
		else if(isturf(loc))
			SetLuminosity(brightness_on)
	else
		processing_objects -= src //Ditto above
		if(ismob(loc))
			var/mob/carrier = loc
			carrier.SetLuminosity(carrier.luminosity - brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)
	update_icon()

/obj/item/device/flashlight/attack_self(mob/user)

	if(panelopen)
		if(fcell)
			fcell.updateicon()
			fcell.loc = get_turf(src.loc)
			fcell = null
			user.visible_message("<span class='notice'>[user] removes the cell from \the [src].</span>", \
			"<span class='notice'>You remove the cell from \the [src].</span>")
			if(on)
				on = 0
				update_brightness()
			update_icon()
			return 1
	else
		if(!isturf(user.loc)) //This shouldn't happen
			user << "<span class='warning'>You cannot use the light while in this [user.loc].</span>" //To prevent some lighting anomalities.
			return 0
		if(battery_needed && (!fcell || fcell.charge < powercost)) //We need a battery and there's none, or it's out of juice
			user << "<span class='warning'>You toggle \the [src]'s power switch, to no effect.</span>"
			return 0
		on = !on
		update_brightness()
		return 1

/obj/item/device/flashlight/examine(mob/user)

	..()
	if(on)
		user << "<span class='info'>\The [src] is lit</span>"
	if(panelopen)
		if(fcell)
			user <<"<span class='info'>\The [src]'s battery is [round(fcell.percent())]% charged.</span>"
		else
			user <<"<span class='info'>\The [src] lacks a battery.</span>"

/obj/item/device/flashlight/attackby(obj/item/weapon/W, mob/user)

	if(battery_needed) //We don't care about any of this shit if we don't use batteries
		if(istype(W, /obj/item/weapon/cell))
			if(panelopen)
				if(!fcell)
					user.drop_item(W, src)
					fcell = W
					user.visible_message("<span class='notice'>[user] installs \a [W] into \the [src].</span>", \
					"<span class='notice'>You install \a [W] into \the [src].</span>")
					update_icon()
					return
				else
					user << "<span class='notice'>\The [src] already has a cell.</span>"
					return

		else if(istype(W, /obj/item/weapon/screwdriver))
			panelopen = !panelopen
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user.visible_message("<span class='notice'>[user] [panelopen ? "opens" : "closes"] \the [src]'s panel</span>", \
			"<span class='notice'>You [panelopen ? "open" : "close"] \the [src]'s panel</span>")
			update_icon()
			return
	..()
	return

//A lot of code to blind people by flicking light into their eyes
/obj/item/device/flashlight/attack(mob/living/M as mob, mob/living/user as mob)

	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if(((M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//Too dumb to use a flashlight properly
			return ..()	//Just hit them in the head

		if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")	//Don't have dexterity
			user << "<span class='notice'>You don't have the dexterity to do this!</span>"
			return

		if(iscarbon(M))

			var/mob/living/carbon/C = M
			var/safe = C.eyecheck()

			if(safe <= 0) //Anything that doesn't grant eye protection will be pretty bad
				C.Weaken(-2.5 * safe) //No protection means nothing. Prescription glasses means 2.5 seconds, thermals/NVGs means 5 seconds
				flick("e_flash", C.flash) //Blind them
				user.visible_message("<span class='warning'>[user] directs \the [src]'s light at [C == user ? "their" : "[C]'s"] eyes, blinding [safe < 0 ? "and stunning" : ""] them.</span>", \
				"<span class='warning'>You direct \the [src]'s light at [C == user ? "yourself" : "[C]'s"] eyes, blinding [safe < 0 ? "and stunning" : ""] [C == user ? "yourself" : "them"].</span>")

			else //Nothing happens, honk
				user.visible_message("<span class='warning'>[user] directs \the [src]'s light at [C == user ? "their" : "[C]'s"] eyes, but it doesn't seem to have any effect on them.</span>", \
				"<span class='warning'>You direct \the [src]'s light at [C == user ? "your" : "[C]'s"] eyes, but it doesn't seem to have any effect on [C == user ? "you" : "them"].</span>")
				return

	else
		return ..()

//The dreaded process() proc, now available at a flashlight near you. Needed for battery gimmicks, includes fancy effects
/obj/item/device/flashlight/process()

	if(battery_needed) //If we don't use batteries, we don't care
		if(fcell && on) //Make sure there's a cell and that we're using it
			if(fcell.use(powercost)) //Drain juice out of the battery
				if(fcell.charge < powercost) //Not enough for the next tick, so we're out
					on = 0
					update_brightness()
					visible_message("<span class='warning'>\The [src] shuts down.</span>")
			else //We're out of juice
				on = 0
				update_brightness()
				visible_message("<span class='warning'>\The [src] shuts down.</span>")
			flickerprob = 100 - (fcell.charge/fcell.maxcharge)*100
			//The following is used to make sure flashlights with good batteries don't flicker
			if(flickerprob < flickerthreshold)
				flickerprob = 0
			if(prob(flickerprob/10) && !flickering)
				flicker()

//Spoopy event. Happens when the flashlight's battery is really drained, or when a ghost spookifies shit
//More complex light sources use special flicker procs, aka none for the moment
/obj/item/device/flashlight/proc/flicker()

	if(on && !flickering)
		flickering = 1
		for(var/i = 1, i <= rand(4, 7), i++)
			if(battery_needed && (!fcell || fcell.charge < powercost)) //We need a battery and there's none, or it's out of juice
				flickering = 0
				return
			on = !on
			update_brightness()
			sleep(5)
		if(!on)
			if(battery_needed && (!fcell || fcell.charge < powercost)) //We need a battery and there's none, or it's out of juice
				flickering = 0
				return
			on = 1
			update_brightness()
		flickering = 0

//The hack continues, make sure we register picking up and dropping lit sources
//Since we're transfering items, we can't just use update_brightness()
/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity + brightness_on)
		SetLuminosity(0)

//Needs to keep old behavior since it happens after we ripped it out of the mob's inventory
/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity - brightness_on)
		SetLuminosity(brightness_on)

//Penlights, runs on magic and the tormented souls of the patients stuck in the cryo cells
/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff to check someone's sight, and blind them along the way."
	icon_state = "penlight"
	item_state = ""
	flags = FPRINT
	siemens_coefficient = 1
	brightness_on = 2
	battery_needed = 0 //Where do you want to fit a battery ?

//The penlight is used to check someone's pupils, so you don't use them the same way you use a flashlight
/obj/item/device/flashlight/pen/attack(mob/living/M as mob, mob/living/user as mob)

	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if(((M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//Too dumb to use a penlight properly
			return ..()	//Just hit them in the head

		if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")	//Don't have dexterity
			user << "<span class='notice'>You don't have the dexterity to do this!</span>"
			return

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//We cannot work on aliens and robots, and can't blind them anyways
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//Mob is dead or completely blind
				user << "<span class='warning'>[M]'s pupils do not react to the light!</span>"
			else if(M_XRAY in M.mutations)	//Mob has X-RAY vision
				flick("flash", M.flash) //Yes, you can still get flashed with X-Ray.
				user << "<span class='warning'>[M]'s pupils glow eerily. <I>Tapetum Lucidum ?</I></span>" //If you don't know what that is, just look it up
			else	//Nothing special about this one, so they react naturally to light
				if(!M.blinded)
					flick("flash", M.flash)	//flash the affected mob
					user << "<span class='notice'>[M]'s pupils narrow.</span>"

//The desk lamps are a bit special, and they run on batteries since an object can't bode well with the powernet
//Have them start off, otherwise they'll drain their battery real quick
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount. Runs on a battery, lamps connected to the powernet became obsolete centuries ago."
	icon_state = "lamp"
	item_state = "lamp"
	brightness_on = 4 //This is a desk lamp, not a nuclear spotlight
	w_class = 4
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/device/flashlight/lamp/cultify()
	new /obj/structure/cult/pylon(loc)
	qdel(src)

//Green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A novelty green-shaded desk lamp. Runs on a battery, lamps connected to the powernet became obsolete centuries ago."
	icon_state = "lampgreen"
	item_state = "lampgreen"


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle Lamp"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

//FLARES. Who doesn't like flares ?
/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are pictograms on the side, they read 'pull cord, make light'."
	w_class = 2.0
	brightness_on = 6 //Pretty bright, but not blinding. This is updated down below !
	icon_state = "flare"
	item_state = "flare"
	action_button_name = null //Just pull it manually, neckbeard.
	battery_needed = 0 //Hahaha no
	var/fuel = 0
	var/maxfuel = 0 //Needed for maths below
	var/on_damage = 7 //For attacking people
	var/produce_heat = 1500
	var/H_color = ""
	var/fuelratio = 100 //Used to measure how used the flare is, in percentage. Yes I know, flares are pretty bright until totally burnt out, but hey, spess

	l_color = "#AA0033" //It makes a pretty red light, that is all

/obj/item/device/flashlight/flare/New()
	fuel = rand(300, 500) //Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	maxfuel = fuel
	..()

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5, surfaces = istype(loc, /turf))
	fuel = max(fuel - 1, 0)
	fuelratio = fuel/maxfuel*100
	//Now, we update based on percentage
	//Oh god I hate myself so much for this
	on = 0 //This is NEEDED to update brightness in a process() proc, and should hopefully not cause major artifacts
	update_brightness() //Remove the old brightness, otherwise we'll have a major fuck-up for mobs
	brightness_on = max(round(initial(brightness_on) - (100 - fuelratio)/20), 1)  //Magic flare formula. Don't ask don't tell. Just update the brightness
	on = 1 //Turn it back on for calculation
	update_brightness() //Once more and for all
	if(!fuel || !on)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty" //It's dead Jim
		processing_objects -= src

/obj/item/device/flashlight/flare/attack_self(mob/user)

	//Usual checks
	if(!fuel)
		user << "<span class='warning'>It's completely burn out.</span>"
		return
	if(on)
		user << "<span class='warning'>It's already on, you dolt.</span>"
		return
	//All good, turn it on.
	user.visible_message("<span class='warning'>[user] lights \the [src].</span>", \
	"<span class='notice'>You pull the cord on \the [src], lighting it!</span>")
	light(user)

/obj/item/device/flashlight/flare/proc/turn_off()

	on = 0
	force = initial(force)
	damtype = initial(damtype)
	update_brightness()
	visible_message("<span class='warning'>\The [src] lets one last pulse of warm red light out before burning out completely.</span>")

/obj/item/device/flashlight/flare/proc/light(var/mob/user as mob)

	if(user)
		if(!isturf(user.loc))
			user << "<span class='warning'>You cannot light the flare while in this [user.loc].</span>" //To prevent some lighting anomalities.
			return 0
	on = 1
	force = on_damage
	damtype = "fire"
	processing_objects += src
	if(user)
		user.l_color = l_color
	update_brightness()

//Flares don't flicker
/obj/item/device/flashlight/flare/flicker()

	return

/obj/item/device/flashlight/flare/pickup(mob/user)

	..()
	if(on)
		user.l_color = l_color

/obj/item/device/flashlight/flare/dropped(mob/user)

	..()
	user.l_color = initial(user.l_color)

// SLIME LAMP
/obj/item/device/flashlight/lamp/slime
	name = "slime lamp"
	desc = "A lamp powered by a slime core. You can adjust its brightness by touching it, SCIENCE!"
	icon_state = "slimelamp"
	item_state = ""
	l_color = "#333300"
	on = 0
	luminosity = 2
	var/brightness_max = 6
	var/brightness_min = 2
	battery_needed = 0 //It works on slime magic, enough said

/obj/item/device/flashlight/lamp/slime/initialize()

	..()
	if(on)
		SetLuminosity(brightness_max)
	else
		SetLuminosity(brightness_min)
	update_icon()

/obj/item/device/flashlight/lamp/slime/proc/slime_brightness()

	if(on)
		if(ismob(loc))
			var/mob/carrier = loc
			carrier.SetLuminosity(carrier.luminosity + brightness_max - brightness_min)
		else if(isturf(loc))
			SetLuminosity(brightness_max)
	else
		if(ismob(loc))
			var/mob/carrier = loc
			carrier.SetLuminosity(carrier.luminosity - brightness_max + brightness_min)
		else if(isturf(loc))
			SetLuminosity(brightness_min)
	update_icon()

/obj/item/device/flashlight/lamp/slime/attack_self(mob/user)

	if(!isturf(user.loc))
		user << "<span class='warning'>You cannot use the light while in this [user.loc].</span>" //To prevent some lighting anomalities.
		return 0
	on = !on
	slime_brightness()
	return 1

/obj/item/device/flashlight/lamp/slime/pickup(mob/user)

	user.l_color = l_color
	if(on)
		user.SetLuminosity(user.luminosity + brightness_max)
		SetLuminosity(0)
	else
		user.SetLuminosity(user.luminosity + brightness_min)
		SetLuminosity(0)


/obj/item/device/flashlight/lamp/slime/dropped(mob/user)

	user.l_color = initial(user.l_color)
	if(on)
		user.SetLuminosity(user.luminosity - brightness_max)
		SetLuminosity(brightness_max)
	else
		user.SetLuminosity(user.luminosity - brightness_min)
		SetLuminosity(brightness_min)

//Slime lamps don't flicker
/obj/item/device/flashlight/flare/flicker()

	return
