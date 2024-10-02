

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"
	req_access = null
	opened = 0
	flags = FPRINT
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0
	var/sound_effect_open = 'sound/machines/click.ogg'
	var/sound_effect_close = 'sound/machines/click.ogg'

/obj/structure/closet/crate/proc/jiggle(var/obj/item/I)
	var/jx = I.w_class == W_CLASS_TINY ? 7 : 3
	var/jy = I.w_class == W_CLASS_TINY ? 3 : 1
	I.pixel_x = rand(-jx,jx)
	I.pixel_y = rand(-jy,jy)

/obj/structure/closet/crate/basic
	has_lock_type = /obj/structure/closet/crate/secure/basic

/obj/structure/closet/pcrate
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "plasticcrate"
	density = 1
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"
	req_access = null
	opened = 0
	flags = FPRINT
	w_type = RECYK_PLASTIC //This one's plastic, not metal!

//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0
	var/sound_effect_open = 'sound/machines/click.ogg'
	var/sound_effect_close = 'sound/machines/click.ogg'

	starting_materials = list(MAT_PLASTIC = 10*CC_PER_SHEET_MISC) // Recipe calls for 10 sheets.

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "o2crate"
	density = 1
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "Trash Cart"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "trashcart"
	density = 1
	icon_opened = "trashcartopen"
	icon_closed = "trashcart"

/obj/structure/closet/crate/chest
	desc = "A heavy wooden chest. Probably filled with gold and treasure!"
	name = "chest"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "chest"
	density = 1
	icon_opened = "chestopen"
	icon_closed = "chest"

/obj/structure/closet/crate/chest/potential_mimic/New()
	..()

	if(prob(33))
		var/mob/living/simple_animal/hostile/mimic/crate/chest/C = new(src.loc)
		forceMove(C)

/*these aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "medicalcrate"
	density = 1
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"
	has_lock_type = /obj/structure/closet/crate/secure/medsec

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"
	has_lock_type = /obj/structure/closet/crate/secure/basic

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "freezer"
	density = 1
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/get_heat_conductivity()
	return HEAT_CONDUCTIVITY_REFRIGERATOR

/obj/structure/closet/crate/freezer/return_air()
	var/datum/gas_mixture/gas = (..())
	if(!gas)
		return null
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.copy_from(gas)
	if(newgas.temperature <= target_temp)
		return

	if((newgas.temperature - cooling_power) > target_temp)
		newgas.temperature -= cooling_power
	else
		newgas.temperature = target_temp
	newgas.update_values()
	return newgas

/obj/structure/closet/crate/freezer/surgery
	desc = "A freezer specifically designed to store organic material."
	name = "surgery freezer"
	icon_state = "surgeryfreezer"
	icon_opened = "surgeryfreezeropen"
	icon_closed = "surgeryfreezer"

/obj/structure/closet/crate/freezer/surgery/close(mob/user)
	..()
	update_icon()

	var/list/inside = recursive_type_check(src, /mob/living/carbon/brain)
	for(var/mob/living/carbon/brain/braine in inside)
		if(braine.mind && !braine.client) //!braine.client = mob has ghosted out of their body
			var/mob/dead/observer/ghost = mind_can_reenter(braine.mind)
			if(ghost)
				var/mob/ghostmob = ghost.get_top_transmogrification()
				if(ghostmob)
					to_chat(ghostmob, "<span class='interface'><span class='big bold'>Your brain has been placed into a surgery freezer.</span> \
						Re-entering your corpse will cause the freezer's heart to pulse, which will let people know you're still there, and just maybe improve your chances of being revived. No promises.</span>")

/obj/structure/closet/crate/freezer/surgery/update_icon()
	..()

	var/list/inside = recursive_type_check(src, /mob/living/carbon/brain)
	for(var/mob/living/carbon/brain/brained in inside)
		if(brained.mind && brained.mind.suiciding)
			continue
		if(brained && brained.client)
			icon_state = "surgeryfreezerbrained"
			return

/obj/structure/closet/crate/freezer/surgery/on_login(var/mob/M)
	..()
	update_icon()

/obj/structure/closet/crate/freezer/surgery/on_logout(var/mob/M)
	..()
	update_icon()

/obj/structure/closet/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "largebin"
	density = 1
	icon_opened = "largebinopen"
	icon_closed = "largebin"

/obj/structure/closet/crate/bin/attackby(var/obj/item/weapon/W, var/mob/user)
    if(W.is_wrench(user) && wrenchable())
        return wrenchAnchor(user, W)
    ..()

/obj/structure/closet/crate/bin/wrenchable()
    return TRUE

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "Radioactive gear crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "radiation"
	density = 1
	icon_opened = "radiationopen"
	icon_closed = "radiation"

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "weaponcrate"
	density = 1
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "plasmacrate"
	density = 1
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "secgearcrate"
	density = 1
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "hydrosecurecrate"
	density = 1
	icon_opened = "hydrosecurecrateopen"
	icon_closed = "hydrosecurecrate"
	has_lockless_type = /obj/structure/closet/crate/hydroponics

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

/obj/structure/closet/crate/secure/bin/attackby(var/obj/item/weapon/W, var/mob/user)
    if(W.is_wrench(user) && wrenchable())
        return wrenchAnchor(user, W)
    ..()

/obj/structure/closet/crate/secure/bin/wrenchable()
    return TRUE

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"
	has_lockless_type = /obj/structure/closet/crate/large

/obj/structure/closet/crate/secure/large/close()
	//we can hold up to one large item
	var/found = 0
	for(var/obj/structure/S in src.loc)
		if(S == src)
			continue
		if(!S.anchored)
			found = 1
			S.forceMove(src)
			break
	if(!found)
		for(var/obj/machinery/M in src.loc)
			if(!M.anchored)
				M.forceMove(src)
				break
	..()

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	broken = 0
	locked = 1
	has_electronics = 1
	health = 1000

/obj/structure/closet/crate/secure/basic
	has_lockless_type = /obj/structure/closet/crate/basic

/obj/structure/closet/crate/secure/anti_tamper
	name = "Extra-secure crate"

/obj/structure/closet/crate/secure/anti_tamper/Destroy()
	if(locked)
		visible_message("<span class = 'warning'>Something bursts open from within \the [src]!</span>")
		var/datum/effect/system/smoke_spread/chem/S = new //Surprise!
		S.attach(get_turf(src))
		S.chemholder.reagents.add_reagent(CAPSAICIN, 40)
		S.chemholder.reagents.add_reagent(CONDENSEDCAPSAICIN, 16)
		S.chemholder.reagents.add_reagent(SACID, 12)
		S.set_up(src, 10, 0, loc)
		spawn(0)
			S.start()
	..()

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	has_lock_type = /obj/structure/closet/crate/secure/large

/obj/structure/closet/crate/large/close()
	//we can hold up to one large item
	var/found = 0
	for(var/obj/structure/S in src.loc)
		if(S == src)
			continue
		if(!S.anchored)
			found = 1
			S.forceMove(src)
			break
	if(!found)
		for(var/obj/machinery/M in src.loc)
			if(!M.anchored)
				M.forceMove(src)
				break
	..()

/obj/structure/closet/crate/hydroponics
	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"
	density = 1
	has_lock_type = /obj/structure/closet/crate/secure/hydrosec

/obj/structure/closet/crate/sci
	desc = "A science crate."
	name = "science crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "scicrate"
	density = 1
	icon_opened = "scicrateopen"
	icon_closed = "scicrate"
	has_lock_type = /obj/structure/closet/crate/secure/scisec

/obj/structure/closet/crate/secure/scisec
	desc = "A secure science crate."
	name = "secure science crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "scisecurecrate"
	density = 1
	icon_opened = "scisecurecrateopen"
	icon_closed = "scisecurecrate"
	has_lockless_type = /obj/structure/closet/crate/sci

/obj/structure/closet/crate/engi
	desc = "An engineering crate."
	name = "engineering crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "engicrate"
	density = 1
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"
	has_lock_type = /obj/structure/closet/crate/secure/engisec

/obj/structure/closet/crate/secure/engisec
	desc = "A secure engineering crate."
	name = "secure engineering crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "engisecurecrate"
	density = 1
	icon_opened = "engisecurecrateopen"
	icon_closed = "engisecurecrate"
	has_lockless_type = /obj/structure/closet/crate/engi

/obj/structure/closet/crate/secure/medsec
	desc = "A secure medical crate."
	name = "secure medical crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "medicalsecurecrate"
	density = 1
	icon_opened = "medicalsecurecrateopen"
	icon_closed = "medicalsecurecrate"
	has_lockless_type = /obj/structure/closet/crate/medical

/obj/structure/closet/crate/secure/plasma/prefilled
	var/count=10
/obj/structure/closet/crate/secure/plasma/prefilled/New()
	for(var/i=0;i<count;i++)
		new /obj/item/weapon/tank/plasma(src)

//This exists so the prespawned hydro crates spawn with their contents.
/obj/structure/closet/crate/hydroponics/prespawned/New()
	..()
	new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
	new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
	new /obj/item/weapon/minihoe(src)


/obj/structure/closet/crate/secure/New()
	..()
	update_icon()

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/stack/rcd_ammo(src)
	new /obj/item/stack/rcd_ammo(src)
	new /obj/item/stack/rcd_ammo(src)
	new /obj/item/device/rcd/matter/engineering(src)

/obj/structure/closet/crate/radiation/New()
	..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/device/geiger_counter(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/device/geiger_counter(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/device/geiger_counter(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/device/geiger_counter(src)

/obj/structure/closet/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0 || wall_mounted))
		return 1
	if(istype(mover, /obj/structure/closet/crate))
		return 0
	return (!density)

/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0
	playsound(src, sound_effect_open, 15, 1, -3)

	for(var/obj/item/I in contents)
		if(I.w_class <= W_CLASS_SMALL)
			jiggle(I)

	dump_contents()

	icon_state = icon_opened
	src.opened = 1
	setDensity(FALSE)
	return 1

/obj/structure/closet/crate/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0
	playsound(src, sound_effect_close, 15, 1, -3)

	take_contents()

	icon_state = icon_closed
	src.opened = 0
	src.setDensity(TRUE)
	return 1

/obj/structure/closet/crate/insert(var/atom/movable/AM)

	if(contents.len >= storage_capacity)
		return -1

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!istype(H) || H.locked_to)
			return 0
		if(!(H.resting || H.stat)) /* We only want mobs that are human and are resting/dying to be able to get inside. */
			return 0

	else if(isobj(AM))
		if(AM.density || AM.anchored || istype(AM,/obj/structure/closet))
			return 0

	if(istype(AM, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
		var/obj/structure/bed/B = AM
		if(B.is_locking(/datum/locking_category/buckle, subtypes=TRUE))
			return 0

	AM.forceMove(src)
	return 1

/obj/structure/closet/crate/attack_hand(var/mob/user)
	if(!Adjacent(user))
		return
	if(istype(src.loc, /obj/structure/rack/crate_shelf))
		return // No opening crates in shelves!!
	add_fingerprint(user)
	if(opened)
		close()
	else
		if(rigged && locate(/obj/item/device/radio/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, src))
					//spark(src, 5)
					return
		open()
	return

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	if(!Adjacent(user))
		return
	if(locked && !broken)
		if (allowed(user))
			to_chat(user, "<span class='notice'>You unlock [src].</span>")
			src.locked = 0
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>Access Denied.</span>")
			return
	else
		..()

/obj/structure/closet/crate/MouseDrop(atom/drop_atom, src_location, over_location)
	. = ..()
	var/mob/living/user = usr
	if(!isliving(user))
		return // Ghosts busted.
	if(!isturf(user.loc) || user.incapacitated() || user.resting)
		return // If the user is in a weird state, don't bother trying.
	if(get_dist(drop_atom, src) != 1 || get_dist(drop_atom, user) != 1)
		return // Check whether the crate is exactly 1 tile from the shelf and the user.
	if(isturf(drop_atom) && istype(loc, /obj/structure/rack/crate_shelf) && user.Adjacent(drop_atom))
		var/obj/structure/rack/crate_shelf/shelf = loc
		return shelf.unload(src, user, drop_atom) // If we're being dropped onto a turf, and we're inside of a crate shelf, unload.
	if(istype(drop_atom, /obj/structure/rack/crate_shelf) && isturf(loc) && user.Adjacent(src))
		var/obj/structure/rack/crate_shelf/shelf = drop_atom
		return shelf.load(src, user) // If we're being dropped onto a crate shelf, and we're in a turf, load.

/obj/structure/closet/crate/secure/proc/togglelock(atom/A)
	if(istype(A,/mob))
		var/mob/user = A
		if(src.allowed(user))
			src.locked = !src.locked
			if (src.locked)
				to_chat(user, "<span class='notice'>You lock \the [src].</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>You unlock [src].</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>Access Denied.</span>")
	else if(istype(A,/obj/machinery/logistics_machine/crate_opener))
		var/obj/machinery/logistics_machine/crate_opener/N = A
		if(can_access(N.access,req_access,req_access))
			src.locked = !src.locked
			update_icon()
			return 1
		else
			return 0

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card) && !opened && !broken)
		togglelock(user)
		return
	else if(W.is_screwdriver(user) && !opened && !locked && src.has_lockless_type)
		remove_lock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(locked && !broken)
		overlays.len = 0
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(!Adjacent(usr) || usr.loc == src)
		return

	if(src.broken)
		return

	if (ishuman(usr))
		if (!opened)
			togglelock(usr)
			return 1
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/crate/secure/AltClick()
	if(verb_togglelock())
		return
	return ..()

/obj/structure/closet/crate/secure/update_icon()
	if(opened)
		icon_state = icon_opened
	else
		icon_state = icon_closed
		if (!broken)
			overlays.len = 0
			if(locked)
				overlays += redlight
			else
				overlays += greenlight

/obj/structure/closet/crate/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened)
		return ..()
	else if(istype(W, /obj/item/weapon/circuitboard/airlock) && src.has_lock_type)
		add_lock(W, user)
		return
	else if(istype(W, /obj/item/stack/package_wrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return

		if(user.drop_item(W))
			to_chat(user, "<span class='notice'>You rig [src].</span>")
			QDEL_NULL(W)
			rigged = 1
		return
	else if(istype(W, /obj/item/device/radio/electropack))
		if(rigged)
			if(user.drop_item(W, src.loc))
				to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			return
	else if(W.is_wirecutter(user))
		if(rigged)
			to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
			W.playtoolsound(loc, 100)
			rigged = 0
			return
	else if(!place(user, W))
		return attack_hand(user)

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			update_icon()
		else
			overlays.len = 0
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src, 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()


/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			broken = TRUE
			if(has_electronics)
				if (prob(50))
					dump_electronics()
				else
					qdel(electronics)
			for(var/atom/movable/thing in contents)
				if(prob(50))
					qdel(thing)
			dump_contents()
			qdel(src)
		if(3)
			if(prob(50))
				broken = TRUE
				if(has_electronics)
					dump_electronics()
				dump_contents()
				qdel(src)

/obj/structure/closet/crate/secure/weapon/experimental
	name = "Experimental Weapons Crate"
	var/chosen_set = null

/obj/structure/closet/crate/secure/weapon/experimental/New()
	..()
	if(!chosen_set)
		chosen_set = pick("ricochet","bison","spur","gatling","stickybomb","nikita","osipr","hecate","gravitywell", "clown")

	switch(chosen_set)
		if("ricochet")
			new/obj/item/clothing/suit/armor/laserproof(src)
			new/obj/item/weapon/gun/energy/ricochet(src)
			new/obj/item/weapon/gun/energy/ricochet(src)
		if("bison")
			new/obj/item/clothing/shoes/jackboots(src)
			new/obj/item/clothing/suit/hgpirate(src)
			new/obj/item/clothing/head/hgpiratecap(src)
			new/obj/item/clothing/glasses/eyepatch(src)
			new/obj/item/weapon/gun/energy/bison(src)
		if("spur")
			new/obj/item/clothing/suit/cardborg(src)
			new/obj/item/clothing/head/cardborg(src)
			new/obj/item/device/modkit/spur_parts(src)
			new/obj/item/weapon/gun/energy/polarstar(src)
		if("gatling")
			new/obj/item/clothing/suit/armor/riot(src)
			new/obj/item/clothing/head/helmet/tactical/riot(src)
			new/obj/item/clothing/shoes/swat(src)
			new/obj/item/clothing/gloves/swat(src)
			new/obj/item/weapon/gun/gatling(src)
		if("stickybomb")
			new/obj/item/clothing/suit/bomb_suit/security(src)
			new/obj/item/clothing/head/bomb_hood/security(src)
			new/obj/item/weapon/gun/stickybomb(src)
			new/obj/item/weapon/storage/box/stickybombs(src)
		if("nikita")
			for(var/i=1;i<=5;i++)
				new/obj/item/ammo_casing/rocket_rpg/nikita(src)
			new/obj/item/weapon/gun/projectile/rocketlauncher/nikita(src)
		if("osipr")
			new/obj/item/clothing/suit/space/syndicate/black(src)
			new/obj/item/clothing/head/helmet/space/syndicate/black(src)
			new/obj/item/weapon/gun/osipr(src)
		if("hecate")
			new/obj/item/weapon/gun/projectile/hecate(src)
			new/obj/item/ammo_storage/box/BMG50(src)
			new/obj/item/device/radio/headset/headset_earmuffs(src)
			new/obj/item/clothing/glasses/hud/thermal(src)
		if("gravitywell")
			new/obj/item/clothing/suit/radiation(src)
			new/obj/item/clothing/head/radiation(src)
			new/obj/item/clothing/shoes/magboots(src)
			new/obj/item/weapon/gun/gravitywell(src)
		if("clown")
			new/obj/item/clothing/under/clownpsyche(src)
			new/obj/item/clothing/mask/gas/clownmaskpsyche(src)
			new/obj/item/clothing/shoes/clownshoespsyche(src)
			new/obj/item/weapon/storage/backpack/clownpackpsyche(src)
			new/obj/item/weapon/gun/energy/laser/rainbow(src)
			new/obj/item/weapon/gun/energy/laser/rainbow(src)

/obj/structure/closet/crate/secure/weapon/experimental/ricochet
	chosen_set = "ricochet"

/obj/structure/closet/crate/secure/weapon/experimental/bison
	chosen_set = "bison"

/obj/structure/closet/crate/secure/weapon/experimental/spur
	chosen_set = "spur"

/obj/structure/closet/crate/secure/weapon/experimental/gatling
	chosen_set = "gatling"

/obj/structure/closet/crate/secure/weapon/experimental/stickybomb
	chosen_set = "stickybomb"

/obj/structure/closet/crate/secure/weapon/experimental/nikita
	chosen_set = "nikita"

/obj/structure/closet/crate/secure/weapon/experimental/osipr
	chosen_set = "osipr"

/obj/structure/closet/crate/secure/weapon/experimental/hecate
	chosen_set = "hecate"

/obj/structure/closet/crate/secure/weapon/experimental/gravitywell
	chosen_set = "gravitywell"

/obj/structure/closet/crate/medical/surgeonloot //Loot crate from killing the surgeon boss
	name = "old medical crate"
	desc = "I wonder what could be inside it?"
	var/possible_loot = null //major loot from killing the boss
	var/possible_potion = null //random potion from killing the boss

/obj/structure/closet/crate/medical/surgeonloot/New()
	..()
	if(!possible_loot) //at the moment there is only one major reward, but more will be created eventually.
		possible_loot = pick(/obj/item/clothing/mask/morphing/skelegiant)

	if(!possible_potion)
		possible_potion = pick(/obj/item/potion/transform, /obj/item/potion/stoneskin, /obj/item/potion/invisibility, /obj/item/potion/speed/major, /obj/item/potion/zombie)

	new possible_loot(src)
	new possible_potion(src)
	new /obj/item/potion/healing(src) //you always get a guarnteed healing potion

