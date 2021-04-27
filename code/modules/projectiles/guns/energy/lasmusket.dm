/obj/item/weapon/gun/energy/lasmusket
	name = "laser musket"
	desc = "An improvised, crank-charged laser weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "lasmusket-glass"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK | SLOT_BELT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1;" + Tc_COMBAT + "=1;" + Tc_POWERSTORAGE + "=1"
	fire_sound = 'sound/weapons/Laser.ogg'
	projectile_type = /obj/item/projectile/beam/veryweaklaser
	conventional_firearm = 0
	charge_cost = 0
	siemens_coefficient = 1
	var/obj/item/weapon/lens_assembly/loadedassembly = null //The lens assembly
	var/lens_secure = 0
	var/cell_secure = 0
	var/crankstate = 0 //for crank overlay; 0 for up, 1 for down
	var/wood = 0
	var/obj/item/weapon/cell/loadedcell = null //The power cell
	var/strength = 0
	var/flawless = 0
/obj/item/weapon/gun/energy/lasmusket/isHandgun()
	return FALSE

/obj/item/weapon/gun/energy/lasmusket/Destroy()
	if(loadedassembly)
		qdel(loadedassembly)
		loadedassembly = null
	if(loadedcell)
		qdel(loadedcell)
		loadedcell = null
	..()

/obj/item/weapon/gun/energy/lasmusket/attack_self(mob/user as mob)
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return
	if(loadedassembly && !lens_secure)
		remove_lens(user)
		return
	if(loadedcell && !cell_secure)
		remove_cell(user)
		return
	if(!lens_secure || !cell_secure)
		to_chat(user, "The laser musket isn't fully assembled!")
		return
	if(loadedcell && cell_secure)
		crank(user)
		return
	return

/obj/item/weapon/gun/energy/lasmusket/update_icon()
	overlays.len = 0
	if(crankstate) //crank overlay
		var/image/crank = image('icons/obj/gun.dmi', src, "lasmusket-crank1")
		overlays += crank
	else
		var/image/crank = image('icons/obj/gun.dmi', src, "lasmusket-crank0")
		overlays += crank
	if (wood)
		if(!loadedassembly) //wood bodies
			icon_state = "lasmusket-wood-lens"
			return
		if(!loadedassembly.plasma)
			icon_state = "lasmusket-wood-glass"
		if(loadedassembly.plasma)
			icon_state = "lasmusket-wood-plasma"
	else
		if(!loadedassembly) //body state
			icon_state = "lasmusket-lens"
			return
		if(!loadedassembly.plasma)
			icon_state = "lasmusket-glass"
		if(loadedassembly.plasma)
			icon_state = "lasmusket-plasma"
	if(!cell_secure) //cell state
		var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-cell")
		overlays += charge
	else
		switch(round(loadedcell.charge)) //charge state
			if(0 to 4999)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-e")
				overlays += charge
			if(5000 to 9999)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-crap")
				overlays += charge
			if(10000 to 19999)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-hc")
				overlays += charge
			if(20000 to 29999)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-super")
				overlays += charge
			if(30000 to 49999)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-hyper")
				overlays += charge
			if(50000 to INFINITY)
				var/image/charge = image('icons/obj/gun.dmi', src, "lasmusket-ultra")
				overlays += charge

/obj/item/weapon/gun/energy/lasmusket/proc/zap(var/mob/user)
	if (loadedcell.charge > 0)
		electrocute_mob(user, loadedcell, src, siemens_coefficient)
		spark(src, 5)
		loadedcell.charge = 0

/obj/item/weapon/gun/energy/lasmusket/proc/crank(var/mob/user)
	var/mob/living/L = user
	if(loadedcell)
		if(loadedcell.charge<loadedcell.maxcharge)
			L.delayNextAttack(1)
			if(flawless)
				loadedcell.charge += 1000 * L.get_strength()
			else
				loadedcell.charge += 500 * L.get_strength()
			crankstate = !crankstate
			playsound(src, 'sound/items/crank.ogg',50,1)
			if(loadedcell.charge>loadedcell.maxcharge)
				loadedcell.charge = loadedcell.maxcharge
			update_icon()
			loadedcell.updateicon()

/obj/item/weapon/gun/energy/lasmusket/proc/remove_cell(var/mob/user)
	if(!loadedcell)
		return
	loadedcell.forceMove(user.loc)
	user.put_in_hands(loadedcell)
	to_chat(user, "You remove \the [loadedcell] from \the [src].")
	loadedcell = null
	update_icon()

/obj/item/weapon/gun/energy/lasmusket/proc/remove_lens(var/mob/user)
	if(!loadedassembly)
		return
	loadedassembly.forceMove(user.loc)
	user.put_in_hands(loadedassembly)
	to_chat(user, "You remove \the [loadedassembly] from the barrel of \the [src].")
	loadedassembly = null
	update_icon()

/obj/item/weapon/gun/energy/lasmusket/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/wood))
		if(wood)
			to_chat(user, "You can't make the stock any more wooden than it already is!")
			return
		var/obj/item/stack/sheet/wood/C = W
		wood = 1
		if(C.use(1))
			to_chat(user, "You replace the stock on \the [src] with a wooden set.")
		update_icon()

	if(istype(W, /obj/item/weapon/lens_assembly))
		if(loadedassembly)
			to_chat(user, "There is already a set of lenses in \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You insert \the [W] into \the [src].")
		W.forceMove(src)
		loadedassembly = W
		update_icon()
		return
	if(istype(W, /obj/item/weapon/cell))
		if(loadedcell)
			to_chat(user, "There is already a power cell in \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You insert \the [W] into \the [src].")
		W.forceMove(src)
		loadedcell = W
		update_icon()
		return
	else if(W.is_screwdriver(user))
		if(flawless)
			to_chat(user, "\The [src] is too flawless to dismantle!")
			return
		if(!loadedassembly)
			to_chat(user, "There is no lens assembly to attach.")
			return
		if(lens_secure)
			to_chat(user, "You loosen the lens assembly within \the [src].")
			W.playtoolsound(src, 50)
		else
			to_chat(user, "You tighten the lens assembly inside \the [src].")
			W.playtoolsound(src, 50)
		lens_secure = !lens_secure
	else if(iswirecutter(W))
		if(flawless)
			to_chat(user, "\The [src] is too flawless to dismantle!")
			return
		if(!loadedcell)
			to_chat(user, "You can't connect the wiring without a power cell.")
			return
		if(cell_secure)
			to_chat(user, "You remove the wires from the power bank of \the [src].")
			W.playtoolsound(src, 50)
			zap(user) //Exploit prevention, zap the user and drain the cell
		else
			to_chat(user, "You connect the wiring around the power bank of \the [src].")
			W.playtoolsound(src, 50)
			zap(user)
		cell_secure = !cell_secure
		update_icon()
	else
		to_chat(user, "<span class='warning'>\The [W] won't fit inside \the [src].</span>")

/obj/item/weapon/gun/energy/lasmusket/examine(mob/user)
	..()
	if(loadedcell)
		to_chat(user, "<span class='info'>There is \a [loadedcell] in the power bank.</span>")
		if(loadedcell.charge > 0)
			to_chat(user, "<span class='notice'>\The [loadedcell] is charged to [loadedcell.charge]W.</span>")
		else
			to_chat(user, "<span class='warning'>\The [loadedcell] is not charged.</span>")
	if(cell_secure)
		to_chat(user, "<span class='info'>The wiring around the power bank is secure.")
	if(!cell_secure)
		to_chat(user, "<span class='warning'>The wiring around the power bank is unsecured.")

	if(!loadedassembly)
		to_chat(user, "<span class='warning'>\The [src] is missing a set of lenses.</span>")
	if(!lens_secure && loadedassembly)
		to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] is unsecured.</span>")

/obj/item/weapon/gun/energy/lasmusket/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return
	else if (A.loc == user.loc)
		return
	else if (A.loc == user)
		return
	else if (locate (/obj/structure/table, src.loc))
		return
	if(!cell_secure || !lens_secure)
		click_empty(user)
		return
	else if(cell_secure)
		if(loadedcell.charge <=0)
			click_empty(user)
			return
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return
	if(round(loadedcell.charge < 5000))
		to_chat(user, "<span class = 'warning'>\The [src] doesn't have enough energy to fire!</span>")
		return
	calculate_strength(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/energy/lasmusket/proc/calculate_strength(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(!loadedcell || !loadedassembly || loadedcell.charge <= 0) //Probably shouldn't happen
		return
	var/strength = round(loadedcell.charge)
	if(strength)
		switch(strength)
			if(5000 to 9999)
				projectile_type = /obj/item/projectile/beam/weaklaser
			if(10000 to 19999)
				projectile_type = /obj/item/projectile/beam/lightlaser
			if(20000 to 29999)
				projectile_type = /obj/item/projectile/beam/
			if(30000 to 49999)
				projectile_type = /obj/item/projectile/beam/captain
			if(50000 to INFINITY)
				projectile_type = /obj/item/projectile/beam/heavylaser

		if(Fire(A,user,params, "struggle" = struggle))
			if(strength > 50000 && !flawless)
				to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] melts!</span>")
				to_chat(user, "<span class='warning'>\The [loadedcell] inside \the [src]'s power bank ruptures!</span>")
				qdel(loadedassembly)
				loadedassembly = null
				lens_secure = 0
				qdel(loadedcell)
				loadedcell = null
				cell_secure = 0
			else if (!flawless)
				loadedassembly.durability -= (strength/2000) //Lens assembly degrades with each shot. Ultra cell gives 4 shots.
				if(loadedassembly.durability <= 0)
					to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] [strength > 100 ? "shatters under" : "finally fractures from"] the stress!</span>")
					qdel(loadedassembly)
					loadedassembly = null
					lens_secure = 0
			fire_sound = initial(fire_sound)
		update_icon()

/obj/item/weapon/gun/energy/lasmusket/process_chambered()
	if(!lens_secure || !cell_secure || loadedcell.charge < 5000)
		return 0
	. = ..()
	loadedcell.charge = 0
	update_icon()

/obj/item/weapon/gun/energy/lasmusket/New()
	..()
	update_icon()

/obj/item/weapon/gun/energy/lasmusket/preloaded/New()
	..()
	loadedassembly = new /obj/item/weapon/lens_assembly(src)
	loadedcell = new /obj/item/weapon/cell/ultra(src)
	loadedcell.charge = loadedcell.maxcharge
	lens_secure = 1
	cell_secure = 1
	update_icon()

/obj/item/weapon/gun/energy/lasmusket/flawless
	name = "flawless laser musket"
	desc = "An improvised, crank-charged laser weapon. This one is of exceptionally high quality, and will never fail. The crank is astonishingly efficient."

/obj/item/weapon/gun/energy/lasmusket/flawless/New()
	..()
	loadedassembly = new /obj/item/weapon/lens_assembly/plasma(src)
	loadedcell = new /obj/item/weapon/cell/ultra(src)
	loadedcell.charge = loadedcell.maxcharge
	lens_secure = 1
	cell_secure = 1
	wood = 1
	flawless = 1
	update_icon()
