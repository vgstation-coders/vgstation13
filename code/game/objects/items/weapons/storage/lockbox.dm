/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A box that accepts and uses locking mechanisms."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_one_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/startswithelectronics = TRUE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"
	var/tracked_access = "It doesn't look like it's ever been used."
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	health = 50
	starting_materials = list(MAT_PLASMA = 1000, MAT_IRON = 1875)

/obj/item/weapon/storage/lockbox/New()
	. = ..()
	if(startswithelectronics)
		electronics = new(src)
		if(req_access)
			electronics.conf_access = req_access
		else if(req_one_access)
			electronics.conf_access = req_one_access
			electronics.one_access = 1

/obj/item/weapon/storage/lockbox/Destroy()
	QDEL_NULL(electronics)
	. = ..()

/obj/item/weapon/storage/lockbox/nolock
	req_one_access = null
	startswithelectronics = FALSE
	locked = FALSE
	icon_state = "lockbox+b"

/obj/item/weapon/storage/lockbox/can_use()
	return broken || !locked || !electronics

/obj/item/weapon/storage/lockbox/attack_robot(var/mob/user)
	to_chat(user, "<span class='rose'>This box was not designed for use by non-organics.</span>")
	return

/obj/item/weapon/storage/lockbox/proc/toggle(var/mob/user, var/id_name)
	if(allowed(user))
		. = TRUE
		locked = !locked
		user.visible_message("<span class='notice'>The lockbox has been [locked ? null : "un"]locked by [user].</span>", "<span class='rose'>You [locked ? null : "un"]lock the box.</span>")
		tracked_access = "The tracker reads: 'Last locked by [id_name || get_id_name(user)].'"
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied.</span>")
		return FALSE

/proc/get_id_name(var/mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/O = H.get_item_by_slot(slot_wear_id)
		var/obj/item/weapon/card/id/I = null
		if (isPDA(O))
			var/obj/item/device/pda/P = O
			I = P.id
		if (isID(O))
			I = O
		if (!I)
			I = locate() in H.held_items
		if (I)
			return I.registered_name
		else
			return "UNKNOWN" // Shouldn't happen but eh

	else if (issilicon(user)) // Currently, borgos cannot open lockboxes, but if you want to make a module who can, this will work.
		return "[user]"


/obj/item/weapon/storage/lockbox/oneuse/toggle(var/mob/user, var/id_name)
	. = ..()
	if (.)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))
		qdel(src)

/obj/item/weapon/storage/lockbox/attackby(obj/item/weapon/W, mob/user)
	var/obj/item/weapon/card/id/I = W.GetID()
	if (I)
		if(!electronics)
			to_chat(user, "<span class='warning'>There is nothing to unlock. Put an access electronics board in this to make it lockable.</span>")
			return
		if(broken)
			to_chat(user, "<span class='warning'>It appears to be broken.</span>")
			return
		return toggle(user, I.registered_name)
	if(!electronics && istype(W,/obj/item/weapon/circuitboard/airlock))
		if(W.icon_state == "door_electronics_smoked")
			to_chat(user, "<span class='warning'>Repair \the [W] before putting it in!</span>")
		else if(user.drop_item(W,src))
			electronics = W
			to_chat(user, "<span class='notice'>You add \the [electronics] to \the [src].</span>")
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if(electronics.conf_access?.len)
				if(electronics.one_access)
					req_one_access = electronics.conf_access
				else
					req_access = electronics.conf_access
			broken = 0
			locked = 0
			update_icon()
			return
	else if(broken && issolder(W))
		var/obj/item/tool/solder/S = W
		if(S.remove_fuel(4,user))
			S.playtoolsound(loc, 100)
			if(do_after(user, src,4 SECONDS * S.work_speed))
				S.playtoolsound(loc, 100)
				broken = 0
				locked = 0
				to_chat(user, "<span class='notice'>You repair the electronics inside the locking mechanism!</span>")
				update_icon()
		return
	else if(!locked)
		if(W.is_screwdriver() && electronics)
			to_chat(user, "<span class='notice'>You unsecure \the [electronics] from \the [src].</span>")
			W.playtoolsound(loc, 50)
			electronics.forceMove(loc)
			user.put_in_hands(electronics)
			req_access = list()
			req_one_access = list()
			if(broken)
				electronics.icon_state = "door_electronics_smoked"
			electronics = null
			broken = 0
			locked = 0
			update_icon()
			return
		. = ..()
	else
		to_chat(user, "<span class='warning'>It's locked!</span>")

/obj/item/weapon/storage/lockbox/obj_shows_to(atom/A)
	return A != electronics

/obj/item/weapon/storage/lockbox/emag_act(var/mob/user)
	if (!electronics || broken)
		return FALSE
	broken = 1
	locked = 0
	desc = "It appears to be broken."
	update_icon()
	user.visible_message("<span class='danger'>\The [src] has been broken by \the [user] with an electromagnetic card!</span>", "<span class='notice'>You break open \the [src].</span>", "<span class='notice'>You hear a faint click sound.</span>", range = 3)
	return TRUE

/obj/item/weapon/storage/lockbox/oneuse/emag_act(var/mob/user)
	. = ..()
	if (.)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))
		qdel(src)


/obj/item/weapon/storage/lockbox/show_to(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return

/obj/item/weapon/storage/lockbox/bullet_act(var/obj/item/projectile/Proj)
	// WHY MUST WE DO THIS
	// WHY
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) && !Proj.nodamage)
			health -= Proj.damage
	. = ..()
	if(health <= 0)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))

		qdel(src)
	return

/obj/item/weapon/storage/lockbox/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(80))
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))
					A.ex_act(3)
				qdel(src)
		if(3)
			if(prob(50))
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))
				qdel(src)

/obj/item/weapon/storage/lockbox/emp_act(severity)
	..()
	if(!broken)
		var/probab
		switch(severity)
			if(1)
				probab = 80
			if(2)
				probab = 50
		if(prob(probab))
			. = TRUE
			locked = !locked
			src.update_icon()
			if(!locked)
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))


/obj/item/weapon/storage/lockbox/oneuse/emp_act(severity)
	. = ..()
	if (.)
		qdel(src)

/obj/item/weapon/storage/lockbox/update_icon()
	..()
	if (!electronics || broken)
		icon_state = src.icon_broken
	else if(locked)
		icon_state = src.icon_locked
	else
		icon_state = src.icon_closed
	return

/obj/item/weapon/storage/lockbox/loyalty
	name = "lockbox (loyalty implants)"
	req_one_access = list(access_security)
	items_to_spawn = list(
		/obj/item/weapon/implantcase/loyalty = 3,
		/obj/item/weapon/implanter/loyalty,
	)

/obj/item/weapon/storage/lockbox/exile
	name = "lockbox (exile implants)"
	req_one_access = list(access_armory)
	items_to_spawn = list(
		/obj/item/weapon/implantcase/exile = 3,
		/obj/item/weapon/implanter/exile,
	)

/obj/item/weapon/storage/lockbox/tracking
	name = "lockbox (tracking implants)"
	req_one_access = list(access_security)
	can_add_storageslots = TRUE
	items_to_spawn = list(
		/obj/item/weapon/implantcase/tracking = 3,
		/obj/item/weapon/implantpad,
		/obj/item/weapon/implanter,
	)

/obj/item/weapon/storage/lockbox/chem
	name = "lockbox (chemical implants)"
	req_one_access = list(access_security)
	can_add_storageslots = TRUE
	items_to_spawn = list(
		/obj/item/weapon/implantcase/chem = 3,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/implanter,
	)

/obj/item/weapon/storage/lockbox/holy
	name = "lockbox (holy implants)"
	req_one_access = list(access_security)
	items_to_spawn = list(
		/obj/item/weapon/implantcase/holy = 3,
		/obj/item/weapon/implanter/holy,
	)

/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_one_access = list(access_security)
	items_to_spawn = list(/obj/item/weapon/grenade/flashbang/clusterbang)

/obj/item/weapon/storage/lockbox/secway
	name = "lockbox (secway keys)"
	desc = "Nobody knows this mall better than I do."
	req_one_access = list(access_security)
	items_to_spawn = list(/obj/item/key/security = 4)

/obj/item/weapon/storage/lockbox/unlockable
	name = "semi-secure lockbox"
	desc = "A securable locked box. Can't lock anything, but can track whoever used it."
	req_one_access = list()

/obj/item/weapon/storage/lockbox/examine(mob/user)
	..()
	if(!electronics)
		to_chat(user, "<span class='info'>It has no access electronics and cannot be locked.</span>")
	else if(broken)
		to_chat(user, "<span class='info'>The access locking is broken!</span>")
	to_chat(user, "<span class='info'>[tracked_access]</span>")

/obj/item/weapon/storage/lockbox/unlockable/peace
	name = "semi-secure lockbox (pax implants)"
	items_to_spawn = list(/obj/item/weapon/implantcase/peace = 5)

/obj/item/weapon/storage/lockbox/coinbox
	name = "coinbox"
	desc = "A secure container for the profits of a vending machine."
	icon_state = "coinbox+l"
	w_class = W_CLASS_SMALL
	can_only_hold = list("/obj/item/voucher","/obj/item/weapon/coin","/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin","/obj/item/weapon/reagent_containers/food/snacks/chococoin")
	max_combined_w_class = 30
	force = 8
	throwforce = 10
	storage_slots = 20
	req_one_access = list(access_qm)
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)
	w_type = RECYK_ELECTRONIC
	icon_locked = "coinbox+l"
	icon_closed = "coinbox"
	icon_broken = "coinbox+b"

/obj/item/weapon/storage/lockbox/coinbox/nolock
	req_one_access = null
	startswithelectronics = FALSE
	icon_state = "coinbox+b"

/obj/item/weapon/storage/lockbox/lawgiver
	name = "lockbox (lawgiver)"
	req_one_access = list(access_armory)
	items_to_spawn = list(/obj/item/weapon/gun/lawgiver)

/obj/item/weapon/storage/lockbox/lawgiver/with_magazine
	items_to_spawn = list(
		/obj/item/weapon/gun/lawgiver,
		/obj/item/ammo_storage/magazine/lawgiver,
	)

/obj/item/weapon/storage/lockbox/oneuse
	desc = "A locked box. When unlocked, the case will fall apart."

/obj/item/weapon/storage/lockbox/AltClick()
	if(verb_togglelock())
		return
	return ..()

/obj/item/weapon/storage/lockbox/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(!Adjacent(usr) || usr.loc == src)
		return

	if(!src.electronics || src.broken)
		return

	if (ishuman(usr))
		if (locked)
			toggle(usr)
			return 1
	else
		to_chat(usr, "<span class='warning'>You lack the dexterity to do this.</span>")


//-------------------------Disk Box, Large Disk Box-------------------------


/obj/item/weapon/storage/lockbox/diskettebox
	name = "diskette box"
	desc = "A lockable box for storing data disks."
	icon = 'icons/obj/storage/datadisks.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "map_diskbox"
	item_state = "diskbox"
	can_only_hold = list("/obj/item/weapon/disk")
	cant_hold = list("/obj/item/weapon/disk/hdd")
	fits_max_w_class = 3
	w_class = W_CLASS_MEDIUM
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 7
	req_one_access = list()
	starting_materials = list(MAT_GLASS = 50, MAT_IRON = 200)
	var/icon_alt = ""

/obj/item/weapon/storage/lockbox/diskettebox/New()
	..()
	update_icon()

/obj/item/weapon/storage/lockbox/diskettebox/open
	icon_state = "map_diskbox_open"
	locked = FALSE

/obj/item/weapon/storage/lockbox/diskettebox/nolock
	startswithelectronics = FALSE
	locked = FALSE

/obj/item/weapon/storage/lockbox/diskettebox/large
	name = "large diskette box"
	desc = "A bigger lockable box for storing data disks."
	icon_state = "map_diskbox_large"
	icon_alt = "_large"
	storage_slots = 14
	starting_materials = list(MAT_GLASS = 100, MAT_IRON = 400)

/obj/item/weapon/storage/lockbox/diskettebox/large/open
	icon_state = "map_diskbox_large_open"
	locked = FALSE
	
/obj/item/weapon/storage/lockbox/diskettebox/large/nolock
	startswithelectronics = FALSE
	locked = FALSE

//---------------------------------PRESETS---------------------------------

/obj/item/weapon/storage/lockbox/diskettebox/open/botanydisk
	name = "flora diskette box"
	desc = "A lockable box of flora data disks."
	items_to_spawn = list(/obj/item/weapon/disk/botany = 7)

/obj/item/weapon/storage/lockbox/diskettebox/large/open/botanydisk
	name = "large flora diskette box"
	desc = "A large lockable box of flora data disks."
	items_to_spawn = list(/obj/item/weapon/disk/botany = 14)

/obj/item/weapon/storage/lockbox/diskettebox/open/cloning
	name = "cloning diskette box"
	desc = "A lockable box of cloning data disks."
	items_to_spawn = list(/obj/item/weapon/disk/data = 7)

/obj/item/weapon/storage/lockbox/diskettebox/open/research
	name = "research diskette box"
	desc = "A lockable box of tech data disks."
	items_to_spawn = list(
		/obj/item/weapon/disk/tech_disk = 2,
		/obj/item/weapon/disk/design_disk = 2,
	)

/obj/item/weapon/storage/lockbox/diskettebox/open/blanks/New()
	..()
	var/j = rand(1,round(storage_slots/2))//up to half the slots filled with useless disks
	for(var/i = 1 to j)
		new /obj/item/weapon/disk(src)
	update_icon()

/obj/item/weapon/storage/lockbox/diskettebox/large/open/blanks/New()
	..()
	var/j = rand(1,round(storage_slots/2))//up to half the slots filled with useless disks
	for(var/i = 1 to j)
		new /obj/item/weapon/disk(src)
	update_icon()

/obj/item/weapon/storage/lockbox/diskettebox/large/full/New()
	..()
	for(var/i = 1 to storage_slots)
		new /obj/item/weapon/disk(src)
	update_icon()

/obj/item/weapon/storage/lockbox/diskettebox/archive
	name = "archival diskette box"
	desc = "Please copy in library."
	storage_slots = 9
	mech_flags = MECH_SCAN_FAIL


//---------------------------------PRESETS END-----------------------------

/obj/item/weapon/storage/lockbox/diskettebox/update_icon()
	overlays.len = 0
	icon_state = "diskbox[icon_alt]"
	item_state = "diskbox"
	if (!broken && !locked && electronics)
		overlays += image(icon,src,"cover[icon_alt]_open")

	var/i = 0
	for (var/obj/item/weapon/disk/disk in contents)
		var/image/disk_image = image(icon,src,disk.icon_state)
		if (icon_alt)
			disk_image.pixel_x -= 3
			if ((i % 2) != 0)
				disk_image.pixel_x += 7
			disk_image.pixel_x -= round(i/2)
			disk_image.pixel_y -= round(i/2)
			if (i >= 12)
				disk_image.pixel_y -= 1
		else
			disk_image.pixel_x -= i
			disk_image.pixel_y -= i
			if (i >= 6)
				disk_image.pixel_y -= 1
		overlays += disk_image
		i++

	overlays += image(icon,src,"overlay[icon_alt]")

	if (!broken && electronics)
		overlays += image(icon, src, "led[locked]")
		if(locked)
			overlays += image(icon, src, "cover[icon_alt]")
	else
		overlays += image(icon, src, "ledb")

/obj/item/weapon/storage/lockbox/diskettebox/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	if (istype(W,/obj/item/weapon/card))
		playsound(src, get_sfx("card_swipe"), 60, 1, -5)
	update_icon()

/obj/item/weapon/storage/lockbox/diskettebox/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	.=..()
	if (.)
		playsound(loc, 'sound/machines/click.ogg', 30, -5)

/obj/item/weapon/storage/lockbox/security_sponsored
	name = "sponsored Team Security lockbox"
	desc = "A sponsor-sticker-plastered lockbox."
	req_one_access = list(access_brig)
	can_add_storageslots = TRUE
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/food/snacks/donitos/coolranch = 4,
		/obj/item/weapon/implanter/spesstv,
	)

/obj/item/weapon/storage/lockbox/team_security_cameras
	name = "sponsored Team Security cameras lockbox"
	desc = "A sponsor-sticker-plastered lockbox."
	req_one_access = list(access_brig)
	can_add_storageslots = TRUE
	items_to_spawn = list(/obj/item/clothing/accessory/spesstv_tactical_camera = 6)

/obj/item/weapon/storage/lockbox/advanced
	name = "advanced lockbox"
	desc = "A highly advanced lockbox from Alcatraz IV, from series RE-4. It has ablative plating to repel lasers and its flat surfaces avoid the vulnerabilities of an ablative vest. Its shock-dispersing core makes it impossible to bomb or drill, it's reinforced against ballistics, and it can reactively teleport. The solid state controller on its scanner cannot be disrupted by electromagnetic pulse and uses elliptic-curve cryptography to frustrate common sequencer hacking. This lockbox is probably more valuable than whatever is inside it."
	health = 200
	storage_slots = 1
	fits_max_w_class = W_CLASS_LARGE
	req_one_access = null

/obj/item/weapon/storage/lockbox/advanced/ex_act()
	react()

/obj/item/weapon/storage/lockbox/advanced/emp_act()
	react()

/obj/item/weapon/storage/lockbox/advanced/emag_act()
	react()

/obj/item/weapon/storage/lockbox/advanced/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s ablative plating!</span>")
		if(!istype(P, /obj/item/projectile/beam))
			P.reflected = 1
			P.rebound(src)
		return PROJECTILE_COLLISION_BLOCKED
	react()
	return ..()

/obj/item/weapon/storage/lockbox/advanced/proc/react()
	teleport_radius(6)
	visible_message("<span class='danger'>\The [src] displaces itself with its reactive teleport system!</span>")
	playsound(src, 'sound/effects/teleport.ogg', 50, 1)

/obj/item/weapon/storage/lockbox/advanced/energyshotgun
	name = "advanced lockbox (energy shotgun)"
	req_access = list(access_security)
	items_to_spawn = list(/obj/item/weapon/gun/energy/shotgun)

/obj/item/weapon/storage/lockbox/advanced/ricochettaser
	name = "advanced lockbox (ricochet taser)"
	req_access = list(access_security)
	items_to_spawn = list(/obj/item/weapon/gun/energy/taser/ricochet)
