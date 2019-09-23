/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = W_CLASS_LARGE
	canhear_range = 2
	var/number = 0
	var/anyai = 1
	var/circuitry_installed=1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	var/buildstage = 0

/obj/item/device/radio/intercom/supports_holomap()
	return TRUE

/obj/item/device/radio/intercom/universe/GhostsAlwaysHear()
	return TRUE

/obj/item/device/radio/intercom/initialize()
	..()
	add_self_to_holomap()

/obj/item/device/radio/intercom/New(turf/loc, var/ndir = 0, var/building = 3)
	..()
	buildstage = building
	if(buildstage)
		processing_objects.Add(src)
	else
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir=ndir
		b_stat=1
		on = 0
	update_icon()

/obj/item/device/radio/intercom/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on || b_stat || isWireCut(WIRE_RECEIVE))
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	if(freq == RAID_FREQ)
		if(!(src.raider))
			return -1//Prevents broadcast of messages over devices lacking the encryption, birb edition

	return canhear_range


/obj/item/device/radio/intercom/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && !src.anyai && !(speech.speaker in src.ai))
		return
	..()

/obj/item/device/radio/intercom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	switch(buildstage)
		if(3)
			if(iswirecutter(W) && b_stat && wires.IsAllCut())
				to_chat(user, "<span class='notice'>You cut out the intercoms wiring and disconnect its electronics.</span>")
				playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
				if(do_after(user, src, 10))
					new /obj/item/stack/cable_coil(get_turf(src),5)
					on = 0
					b_stat = 1
					buildstage = 1
					update_icon()
					processing_objects.Remove(src)
				return 1
			else
				return ..()
		if(2)
			if(W.is_screwdriver(user))
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src, 10))
					update_icon()
					on = 1
					b_stat = 0
					buildstage = 3
					to_chat(user, "<span class='notice'>You secure the electronics!</span>")
					update_icon()
					processing_objects.Add(src)
					for(var/i, i<= 5, i++)
						wires.UpdateCut(i,1, user)
				return 1
		if(1)
			if(iscablecoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					return
				if(do_after(user, src, 10))
					coil.use(5)
					to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
					buildstage = 2
				return 1
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You begin removing the electronics...</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 10))
					new /obj/item/weapon/intercom_electronics(get_turf(src))
					to_chat(user, "<span class='notice'>The circuitboard pops out!</span>")
					buildstage = 0
				return 1
		if(0)
			if(istype(W,/obj/item/weapon/intercom_electronics))
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 10))
					qdel(W)
					to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]!</span>")
					buildstage = 1
				return 1
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT=W
				if(WT.do_weld(user, src, 10, 5))
					to_chat(user, "<span class='notice'>You cut the intercom frame from the wall!</span>")
					new /obj/item/mounted/frame/intercom(get_turf(src))
					qdel(src)
					return 1

/obj/item/device/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday
		var/area/this_area = get_area(src)
		if(!this_area)
			on = 0
			update_icon()
			return
		on = this_area.powered(EQUIP) // set "on" to the power status
		update_icon()

/obj/item/weapon/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON

/obj/item/device/radio/intercom/medbay
	name = "station intercom (Medbay)"

/obj/item/device/radio/intercom/medbay/initialize()
	..()
	set_frequency(MED_FREQ)

/obj/item/device/radio/intercom/medbay/broadcast_nospeaker
	broadcasting = 1
	listening = 0
