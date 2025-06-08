#define CHANNEL_VACUUMCLEANER 764 //temporary - do not merge this
								  // see below comments in switchOn proc
/obj/item/weapon/vacuumcleaner
	desc = "There is a slot for a power cell and a place to tie a trash bag."
	name = "vacuum cleaner"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "vacuum_cleaner"
	hitsound = "sound/weapons/whip.ogg"
	force = 4.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 2
	w_class = W_CLASS_LARGE
	autoignition_temperature = AUTOIGNITION_PLASTIC
	flags = FPRINT
	attack_verb = list("bashes", "vacuums", "smashes", "whacks", "staves")

	var/power_usage = 75

	var/obj/item/weapon/storage/bag/trash/bag = null //only trash bag for now
	var/obj/item/weapon/storage/bag/trash/internal = new/obj/item/weapon/storage/bag/trash()

	var/obj/item/weapon/cell/cell = null
	var/active = 0 //means the cleaner is powered in any capacity
	var/cover_open = 0
	var/held = 0
	var/turning_on = 0 //means the cleaner is turning on (this is for sound control)

	var/sound/runningsound = sound()
	var/sound/turningoffsound = sound()
	var/sound/turningonsound = sound()
	var/sound/wheelssound = sound()
	var/sound/nullsound = sound(file = null)

/obj/item/weapon/vacuumcleaner/New()
	. = ..()
	vacuumcleaner_list.Add(src)

	runningsound.file = 'sound/effects/vacuumcleaner_running.ogg'
	runningsound.repeat = 1
	runningsound.volume = 50
	runningsound.environment = 0
	runningsound.atom = src
	runningsound.transform = matrix(1, 0, 0, 0, 1, 0)

	turningoffsound.file = 'sound/effects/vacuumcleaner_off.ogg'
	turningoffsound.repeat = 0
	turningoffsound.volume = 50
	runningsound.environment = 0
	turningoffsound.atom = src
	turningoffsound.transform = matrix(1, 0, 0, 0, 1, 0)

	turningonsound.file = 'sound/effects/vacuumcleaner_on.ogg'
	turningonsound.repeat = 0
	turningonsound.volume = 50
	runningsound.environment = 0
	turningonsound.atom = src
	turningonsound.transform = matrix(1, 0, 0, 0, 1, 0)

	wheelssound.file = 'sound/effects/vacuumcleaner_wheels.ogg'
	wheelssound.repeat = 0
	wheelssound.volume = 70
	runningsound.environment = 0
	wheelssound.atom = src
	wheelssound.transform = matrix(1, 0, 0, 0, 1, 0)


/obj/item/weapon/vacuumcleaner/Destroy()
	vacuumcleaner_list.Remove(src)
	..()

/obj/item/weapon/vacuumcleaner/emag_act(mob/user)
	if (emagged)
		return
	emagged = 1
	playsound(src, "sparks", 100, 1)
	to_chat(user, "<span class='warning'>The emag fries \the [src]'s safety circuits!</span>")

/obj/item/weapon/vacuumcleaner/update_icon()
	..()
	overlays.len = 0

/obj/item/weapon/vacuumcleaner/examine(mob/user)
	..()
	if (bag)
		to_chat(user, "\A [bag] is tied to its outlet port.")
	else
		to_chat(user, "It doesn't appear to have a bag attached.")
	if (cell)
		to_chat(user, "<span class='info'>The battery meter reads [round(cell.percent())]%.</span>")
	else
		to_chat(user, "<span class='info'>The battery meter is dark.</span>")
	if (cover_open)
		to_chat(user, "Its cover is open.")

/obj/item/weapon/vacuumcleaner/attack_hand(var/mob/user)
	..()
	if (user)
		user.register_event(/event/moved, src, nameof(src::mob_moved()))
		set_sound_atom(user) // sound emits from the mob's atom as the vacuum cleaner is no longer "visible" on a turf

/obj/item/weapon/vacuumcleaner/attack_self(mob/user)
	src.add_fingerprint(user)
	if (active)
		switchOff()
		return
	if (!cell || cover_open || !cell.charge || (!bag && !emagged))
		to_chat(user, "<span class='warning'>It won't turn on!")
		return
	switchOn(user)

/obj/item/weapon/vacuumcleaner/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/storage/bag/trash))
		//play a rustle sound?
		if (bag)
			to_chat(user, "<span class='warning'>There is already a bag attached!</span>")
			return
		if (user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You tie \the [W] to the outlet port.</span>")
			bag = W
	else if (istype(W, /obj/item/tool/screwdriver))
		playsound(src, 'sound/items/Screwdriver.ogg', 75)
		if (!cover_open)
			to_chat(user, "<span class='notice'>You open the vacuum cleaner's battery cover.</span>")
			cover_open = 1
			if (active)
				switchOff()
		else
			to_chat(user, "<span class='notice'>You close the battery cover.</span>")
			cover_open = 0
	else if (istype(W, /obj/item/weapon/cell))
		//play sound??
		if (cover_open)
			if (user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You install \the [W] into the battery compartment.</span>")
				cell = W

/obj/item/weapon/vacuumcleaner/verb/remove_trashbag()
	set name = "Remove Trash Bag"
	set category = "Object"
	set src in oview(1)

	if(bag && !usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		bag.forceMove(get_turf(usr))
		usr.put_in_hands(bag)
		bag = null

/obj/item/weapon/vacuumcleaner/proc/remove_cell()
	if (cover_open && cell && !usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		cell.forceMove(get_turf(usr))
		usr.put_in_hands(cell)
		cell = null

/obj/item/weapon/vacuumcleaner/AltClick()
	if (bag)
		if (active && !emagged)
			switchOff()
		remove_trashbag()
	else if (cover_open)
		if (cell)
			remove_cell()
	else
		..()

/obj/item/weapon/vacuumcleaner/dropped(mob/user as mob)
	if (user)
		user.unregister_event(/event/moved, src, nameof(src::mob_moved()))
	..()
	set_sound_atom(src) // sound emits from vacuum cleaner's atom as it is now "visible" on a turf
	if (active)
		switchOff()
		// should it? i find the idea of a mid-ZAS vacuum cleaner pulling in
		//  important things pretty funny

/obj/item/weapon/vacuumcleaner/proc/switchOff(mob/user)
	turning_on = 0 //definitely shouldnt be doing this right now
	active = 0
	emitsound(nullsound)
	emitsound(turningoffsound)

/obj/item/weapon/vacuumcleaner/proc/switchOn(mob/user)
	if (!active && cell.charge)
		active = 1
		// Arbitrarily picking channel 764 so the "running"
		//  sound can loop after this sound finishes and
		//  be interrupted by the switchOff sound later
		// Will cause issues with multiple vacuum cleaners?
		// Is there a way to reserve an arbitrary available sound channel?
		//  then "free" the channel after switchOff sound
		//  or is this C-brain
		turning_on = 1
		emitsound(nullsound)
		emitsound(turningonsound)
		sleep(10) //length of uninterruptible section of above sound (1 sec)
		turning_on = 0 //you may now interrupt and work and stuff
		if (active && cell.charge) //this is necessary because we slept
			update_sound()
			vacuum() //clean the tile we're standing on

/obj/item/weapon/vacuumcleaner/proc/emitsound(sound/S)
	for (var/mob/living/M in viewers())
		world << M
		if (M.client)
			M << S

/obj/item/weapon/vacuumcleaner/proc/set_sound_atom(atom/A)
	if (A)
		runningsound.atom = A
		turningoffsound.atom = A
		turningonsound.atom = A
		wheelssound.atom = A
	else
		runningsound.atom = null
		turningoffsound.atom = null
		turningonsound.atom = null
		wheelssound.atom = null

/obj/item/weapon/vacuumcleaner/proc/update_sound()
	if (active)
		if (bag && bag.is_full())
			//play at higher pitch if bag is full
			var/sound/fullsound = runningsound
			fullsound.frequency = 45500
			emitsound(fullsound)
		else
			emitsound(runningsound)

/obj/item/weapon/vacuumcleaner/proc/mob_moved(atom/movable/mover)
	if (usr) //only play wheels sound if someones using it
		emitsound(wheelssound)
	if (active)
		vacuum()
		update_sound()

/obj/item/weapon/vacuumcleaner/proc/vacuum()
	if (!active)
		return
	//todo more sanity checks
	if (!use_power() || (!bag && !emagged)) //you need a bag if you arent emagged
		switchOff()
		return
	var/turf/tile = get_turf(src)
	if (isturf(tile))
		for (var/atom/A in tile)
			//handle crumbs, ash?
			if (istype(A, /obj/item))
				var/obj/item/i = A
				if (internal.can_quick_store(i)) //if any garbage bag can even store it
					if (bag)
						if (bag.can_quick_store(i))
							if (usr)
								playsound(src, "rustle", 50, wait = 0)
								bag.handle_item_insertion(i, 1)
								continue
					if (!bag && emagged)
						playsound(src, "rustle", 50, wait = 0)
						shoot_backwards(i)

/obj/item/weapon/vacuumcleaner/proc/shoot_backwards(obj/item/W as obj)
	if (!usr)
		return
	var/back_dir = usr.dir
	var/distance = 4
	var/shoot_velocity = 1
	back_dir = turn(back_dir, 180)
	var/target = get_step(get_step(get_step(usr.loc, back_dir), back_dir), back_dir) //ye
	W.forceMove(usr.loc)
	spawn(0)
		W.throw_at(target, distance, shoot_velocity)

/obj/item/weapon/vacuumcleaner/proc/use_power()
	if (cell.charge > 0)
		//drain power_usage from cell but floor at 0
		cell.charge = max(cell.charge - power_usage, 0)
		return 1
	return 0
