/obj/item/device/takyiklocator
	name = "takyik-akva locator"
	desc = "A Shoalish engineer's attempt to recreate Nanotrasen technology and the backbone of raiding parties everywhere. \
			Much like a Nanotrasen's own pinpointer, it tracks identifiable spatial distortions created by certain objects. \
			Unlike Nanotrasen's pinpointer, this device is capable of tracking a lot more than a nuclear disk, but it seems like the Vox haven't invented a display screen yet."
	icon_state = "radio_jammer0"	//temp
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_SYNDICATE + "=4;" + Tc_MAGNETS + "=4"
	flammable = TRUE

	var/active = FALSE
	var/obj/target = null
	var/beepnum = 0

	var/list/trackable = list(
		/obj/item/weapon/disk/nuclear,
		/obj/item/weapon/hand_tele
	)

/obj/item/device/takyiklocator/New()
	..()
	setup_sound()

/obj/item/device/takyiklocator/attack_self()
	if(!active)
		active = TRUE
		to_chat(usr,"<span class='notice'>You activate \the [src]</span>")
		playsound(src, 'sound/items/healthanalyzer.ogg', 30, 1)
		fast_objects += src
		process()
	else
		active = FALSE
		to_chat(usr,"<span class='notice'>You deactivate \the [src]</span>")
		fast_objects -= src
		set_sound(0)

/obj/item/device/takyiklocator/AltClick(var/mob/user)
	if((usr.incapacitated() || !Adjacent(usr)))
		return
	select_target()

/obj/item/device/takyiklocator/proc/select_target()

	target = null
	set_sound(0)

	var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in trackable
	if(!targetitem)
		return

	to_chat(usr, "<span class='info'>[src] starts humming quietly as it scans the air...</span>")
	var/list/found = list()

	for(var/obj/O in world)
		if(istype(O, targetitem) && get_z_level(O) == get_z_level(src))
			found += O
			CHECK_TICK

	if(found.len)
		target = found[1]

	if(!target)
		visible_message("<span class='warning'>[src] suddenly falls silent.</span>")
		set_sound(0)
		return
	to_chat(usr,"<span class='notice'>[src] boots up with a gentle beep. It's now tracking [targetitem].</span>")

/obj/item/device/takyiklocator/process()
	. = ..()
	track(target)


/obj/item/device/takyiklocator/proc/track(var/obj/target)
	if(!active || !target)
		set_sound(0)
		return

	var/new_beep = 0
	switch(get_dist(get_turf(src), get_turf(target)))
		if(-1 to 7)
			new_beep = 5
		if(9 to 23)
			new_beep = 4
		if(24 to 40)
			new_beep = 3
		if(41 to 70)
			new_beep = 2
		if(71 to INFINITY)
			new_beep = 1

	set_sound(new_beep)

/obj/item/device/takyiklocator/proc/set_sound(var/new_beep)
	if(new_beep == beepnum)		// Nothing to change.
		return
	beepnum = new_beep
	sound_emitter.stop()
	if(beepnum)
		sound_emitter.play("beep[beepnum]")



/obj/item/device/takyiklocator/setup_sound()
	sound_emitter = new(src, is_static = FALSE)
	if (sound_emitter)

		var/sound/beep1 = sound()
		beep1.file = 'sound/items/voxscanner_1.ogg'
		beep1.repeat = 1
		beep1.volume = 3

		var/sound/beep2 = sound()
		beep2.file = 'sound/items/voxscanner_2.ogg'
		beep2.repeat = 1
		beep2.volume = 3

		var/sound/beep3 = sound()
		beep3.file = 'sound/items/voxscanner_3.ogg'
		beep3.repeat = 1
		beep3.volume = 3

		var/sound/beep4 = sound()
		beep4.file = 'sound/items/voxscanner_4.ogg'
		beep4.repeat = 1
		beep4.volume = 3

		var/sound/beep5 = sound()
		beep5.file = 'sound/items/voxscanner_5.ogg'
		beep5.repeat = 1
		beep5.volume = 3

		sound_emitter.add(beep1, "beep1")
		sound_emitter.add(beep2, "beep2")
		sound_emitter.add(beep3, "beep3")
		sound_emitter.add(beep4, "beep4")
		sound_emitter.add(beep5, "beep5")
