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
	var/obj/item/device/encryptionkey/keyslot
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck
	var/buildstage = 0

/obj/item/device/radio/intercom/supports_holomap()
	return TRUE

/obj/item/device/radio/intercom/universe/New()
	return ..()

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
		return CANT_RECIEVE
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return CANT_RECIEVE
	if (!src.listening)
		return CANT_RECIEVE

	var/freq_txt = num2text(freq)

	if (freq_txt in crypted_radiochannels_reverse) // Do we have the encryption key for it
		var/channel = crypted_radiochannels_reverse[freq_txt]
		if (!handle_crypted_channels(channel))
			return CANT_RECIEVE

	return canhear_range

/obj/item/device/radio/intercom/handle_crypted_channels(var/channel)
	if (istype(keyslot) && channel in keyslot.secured_channels)
		return TRUE
	return FALSE

/obj/item/device/radio/intercom/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && !src.anyai && !(speech.speaker in src.ai))
		return
	..()

/obj/item/device/radio/intercom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// If we're not constructing one...
	if(isscrewdriver(W))
		if(keyslot)
			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
				secure_radio_connections[ch_name] = null

			var/turf/T = get_turf(user)
			if(T)
				keyslot.forceMove(T)
				keyslot = null
			to_chat(user, "You pop out the encryption key in the intercom!")

		else
			to_chat(user, "This intercom doesn't have an encryption key!  How useless...")

	if(istype(W, /obj/item/device/encryptionkey))
		to_chat(user, "You put the encryption key in \the [src].")
		if(keyslot)
			to_chat(user, "This intercom can't hold another key!")
			return

		if(user.drop_item(W, src))
			keyslot = W
		
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
			if(isscrewdriver(W))
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
						wires.UpdateCut(i,1)
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
				playsound(src, 'sound/items/Welder.ogg', 50, 1)
				if(!WT.remove_fuel(3, user))
					to_chat(user, "<span class='warning'>You're out of welding fuel.</span>")
					return 1
				if(do_after(user, src, 10))
					to_chat(user, "<span class='notice'>You cut the intercom frame from the wall!</span>")
					new /obj/item/mounted/frame/intercom(get_turf(src))
					qdel(src)
					return 1

/obj/item/device/radio/intercom/recalculateChannels()
	if(keyslot.translate_binary)
		src.translate_binary = 1

	if(keyslot.translate_hive)
		src.translate_hive = 1


/obj/item/device/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday
		if(!areaMaster)
			on = 0
			update_icon()
			return
		on = areaMaster.powered(EQUIP) // set "on" to the power status
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
	frequency = 1485

/obj/item/device/radio/intercom/medbay/broadcast_nospeaker
	broadcasting = 1
	listening = 0

/obj/item/device/radio/intercom/ai_private
	name = "Private AI Channel"
	broadcasting = TRUE

/obj/item/device/radio/intercom/ai_private/initialize()
	frequency = AIPRIV_FREQ
	..()

// Mapped intercoms

/obj/item/device/radio/intercom/syndicate
	name = "Syndicate intercom"
	desc = "Talk through this. Evily."

/obj/item/device/radio/intercom/syndicate/initialize()
	keyslot = new /obj/item/device/encryptionkey/syndicate
	frequency = SYND_FREQ
	..()

// Can't remove keys from mapped intercoms
/obj/item/device/radio/intercom/mapped/attackby(var/obj/item/weapon/W, var/mob/user)
	if (isscrewdriver(W) && buildstage != 2)
		to_chat(user, "<span class='notice'>You can't seem to pull out the encryption key of this one.</span>")
	return ..()

/obj/item/device/radio/intercom/mapped/ace_reporter
	name = "Ace Reporter intercom"
	desc = "Alert cargo before security raids them!"
	freerange = TRUE

/obj/item/device/radio/intercom/mapped/ace_reporter/initialize()
	frequency = pick(COMM_FREQ, SEC_FREQ, COMMON_FREQ)
	keyslot = new /obj/item/device/encryptionkey/mapped
	..()

/obj/item/device/radio/intercom/mapped/dj_sat
	name = "Pirate Radio Listening Channel"
	desc = "The sickest tunes this side of Tau Ceti."
	freerange = TRUE

/obj/item/device/radio/intercom/mapped/dj_sat/initialize()
	keyslot = new /obj/item/device/encryptionkey/mapped
	..()