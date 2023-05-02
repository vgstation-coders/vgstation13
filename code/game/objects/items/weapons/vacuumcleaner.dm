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
	attack_verb = list("bashes", "vacuums", "smashes", "whacks", "staves") //TODO suggestions pls

	var/power_usage = 75

	var/obj/item/weapon/storage/bag/trash/bag = null //only trash bag for now
	var/obj/item/weapon/storage/bag/trash/internal = new/obj/item/weapon/storage/bag/trash()

	var/obj/item/weapon/cell/cell = null
	var/active = 0
	var/cover_open = 0
	var/emagged = 0
	var/held = 0

/obj/item/weapon/vacuumcleaner/New()
	. = ..()
	vacuumcleaner_list.Add(src)

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
		to_chat(user, "\A [bag] is tied to it's outlet port.")
	else
		to_chat(user, "It doesn't appear to have a bag attached.")
	if (cell)
		to_chat(user, "<span class='info'>The battery meter reads [round(cell.percent())]%.</span>")

/obj/item/weapon/vacuumcleaner/attack_hand(var/mob/user)
	..()
	if (user)
		user.register_event(/event/moved, src, src::mob_moved())

/obj/item/weapon/vacuumcleaner/attack_self(mob/user)
	if (active)
		switchOff()
	else
		if (!cell || !cell.charge)
			to_chat(user, "<span class='warning'>It won't turn on without a charged cell installed!</span>")
			return
		if (!bag && !emagged)
			to_chat(user, "<span class='warning'>It won't turn on without a bag attached!</span>")
			return
		switchOn(user)
	src.add_fingerprint(user)

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
		//play screwdriver sound
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
		remove_trashbag()
	else if (cover_open)
		if (cell)
			remove_cell()
	else
		..()

/obj/item/weapon/vacuumcleaner/dropped(mob/user as mob)
	if (user)
		user.unregister_event(/event/moved, src, src::mob_moved())
	..()
	if (active)
		switchOff()
		// should it? i find the idea of a mid-ZAS vacuum cleaner pulling in
		//  important things pretty funny

/obj/item/weapon/vacuumcleaner/proc/switchOff(mob/user)
	if (!active)
		return
	active = 0
	playsound(src, 'sound/effects/vacuumcleaner_off.ogg', 50, wait = 0, channel = 0)

/obj/item/weapon/vacuumcleaner/proc/switchOn(mob/user)
	if (active)
		return
	if (cell.charge)
		active = 1
		// Arbitrarily picking channel 764 so the "running"
		//  sound can loop after this sound finishes and
		//  be interrupted by the switchOff sound later
		// Will cause issues with multiple vacuum cleaners?
		// Is there a way to reserve an arbitrary available sound channel?
		//  then "free" the channel after switchOff sound
		//  or is this C-brain
		playsound(src, 'sound/effects/vacuumcleaner_on.ogg', 50, wait = 0, channel = 764)
		update_sound(a_wait = 1) //queue looping running sound
		vacuum() //clean the tile we're standing on

/obj/item/weapon/vacuumcleaner/proc/update_sound(var/a_wait = 0)
	if (!active) //thanks byond
		playsound(src, null, 100, wait = 1, channel = 764) //dead cleaners tell no .oggs
		return
	if (active)
		if (bag)
			if (bag.is_full())
				//play at higher pitch if bag is full
				playsound(src, 'sound/effects/vacuumcleaner_running.ogg', 50, wait = a_wait, channel = 764, repeat = 2, frequency = 45500, vary = 1)
		else
			//regular idling sound
			playsound(src, 'sound/effects/vacuumcleaner_running.ogg', 50, wait = a_wait, channel = 764, repeat = 2)

/obj/item/weapon/vacuumcleaner/proc/mob_moved(atom/movable/mover)
	if (usr) //only play wheels sound if someones using it
		playsound(src, 'sound/effects/vacuumcleaner_wheels.ogg', 70, vary = 1, frequency = rand(42000, 46000)) //too much frequency variation sounds really bad
	if (active)
		vacuum()
	update_sound(a_wait = 0) //directional sound/volume needs recalculation when moving


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
			if (istype(A, /obj/item))
				var/obj/item/i = A
				if (internal.can_quick_store(i)) //if any garbage bag can even store it
					if (bag)
						if (bag.can_quick_store(i))
							if (usr)
								playsound(src, "rustle", 50, wait = 0)
								bag.handle_item_insertion(i, 1)
					if (!bag && emagged)
						to_chat(usr, "calling shoot_backwards")
						playsound(src, "rustle", 50, wait = 0)
						shoot_backwards(i)
					else
						switchOff() //technically we should never reach here

/obj/item/weapon/vacuumcleaner/proc/shoot_backwards(obj/item/projectile)
	if (!usr)
		return
	var/back_dir = usr/dir
	var/shoot_velocity = 2 //arbitrary for now
	var/distance = 3 //its meant to be weak as shit
	to_chat(usr, "calculating back_dir")
	back_dir = turn(back_dir, 180)
	to_chat(usr, "calculating target")
	var/target = get_step(usr.loc, back_dir)
	to_chat(usr, "forcemove call")
	projectile.forceMove(usr.loc)
	to_chat(usr, "throw_at call")
	projectile.throw_at(target, distance, shoot_velocity)

/obj/item/weapon/vacuumcleaner/proc/use_power()
	if (cell.charge > 0)
		//drain power_usage from cell but floor at 0
		cell.charge = max(cell.charge - power_usage, 0)
		return 1
	return 0
