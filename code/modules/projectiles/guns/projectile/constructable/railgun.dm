/obj/item/weapon/gun/projectile/railgun
	name = "railgun"
	desc = "A weapon that uses the Lorentz force to propel an armature carrying a projectile to incredible velocities."
	icon = 'icons/obj/gun.dmi'
	icon_state = "railgun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK | SLOT_BELT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1;" + Tc_COMBAT + "=1;" + Tc_POWERSTORAGE + "=1"
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = 'sound/weapons/railgun_lowpower.ogg'
	conventional_firearm = 0
	var/obj/item/weapon/rail_assembly/loadedassembly = null //The internal rail assembly
	var/rails_secure = 0
	var/obj/item/loadedammo = null
	var/obj/item/weapon/stock_parts/capacitor/loadedcapacitor = null
	var/strength = 0

/obj/item/weapon/gun/projectile/railgun/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/railgun/Destroy()
	if(loadedassembly)
		qdel(loadedassembly)
		loadedassembly = null
	if(loadedcapacitor)
		qdel(loadedcapacitor)
		loadedcapacitor = null
	if(loadedammo)
		qdel(loadedammo)
		loadedammo = null
	..()

/obj/item/weapon/gun/projectile/railgun/attack_self(mob/user as mob)
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return
	if(loadedammo)
		remove_ammunition(user)
		return
	if(loadedcapacitor)
		remove_capacitor(user)
		return
	if(loadedassembly && !rails_secure)
		remove_rails(user)
		return
	return

/obj/item/weapon/gun/projectile/railgun/update_icon()
	overlays.len = 0

	if(istype(loadedammo, /obj/item/weapon/coin))
		var/image/coin = image('icons/obj/weaponsmithing.dmi', src, "railgun_coin_overlay")
		overlays += coin
	else if (loadedammo)
		var/image/rod = image('icons/obj/weaponsmithing.dmi', src, "railgun_rod_overlay")
		overlays += rod
	if(loadedcapacitor)
		if(istype(loadedcapacitor, /obj/item/weapon/stock_parts/capacitor/adv/super/ultra))
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_adv_super_ultra_overlay")
			overlays += capacitor
		else if(istype(loadedcapacitor, /obj/item/weapon/stock_parts/capacitor/adv/super))
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_adv_super_overlay")
			overlays += capacitor
		else if(istype(loadedcapacitor, /obj/item/weapon/stock_parts/capacitor/adv))
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_adv_overlay")
			overlays += capacitor
		else
			var/image/capacitor = image('icons/obj/weaponsmithing.dmi', src, "railgun_capacitor_overlay")
			overlays += capacitor

/obj/item/weapon/gun/projectile/railgun/proc/remove_ammunition(var/mob/user)
	if(!loadedammo)
		return
	loadedammo.forceMove(user.loc)
	user.put_in_hands(loadedammo)
	to_chat(user, "You remove \the [loadedammo] from the barrel of \the [src].")
	loadedammo = null

	update_icon()

/obj/item/weapon/gun/projectile/railgun/proc/remove_capacitor(var/mob/user)
	if(!loadedcapacitor)
		return

	loadedcapacitor.forceMove(user.loc)
	user.put_in_hands(loadedcapacitor)
	to_chat(user, "You remove \the [loadedcapacitor] from the capacitor bank of \the [src].")
	loadedcapacitor = null

	update_icon()

/obj/item/weapon/gun/projectile/railgun/proc/remove_rails(var/mob/user)
	if(!loadedassembly)
		return

	loadedassembly.forceMove(user.loc)
	user.put_in_hands(loadedassembly)
	to_chat(user, "You remove \the [loadedassembly] from the barrel of \the [src].")
	loadedassembly = null
	update_icon()


/obj/item/weapon/gun/projectile/railgun/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/rail_assembly))
		if(loadedassembly)
			to_chat(user, "There is already a set of rails in \the [src].")
			return
		to_chat(user, "You insert \the [W] into the barrel of \the [src].")
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		W.forceMove(src)
		loadedassembly = W
		return
	if(istype(W, /obj/item/weapon/stock_parts/capacitor))
		if(loadedcapacitor)
			to_chat(user, "There is already a capacitor in the capacitor bank of \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You insert \the [W] into the capacitor bank of \the [src].")
		W.forceMove(src)
		loadedcapacitor = W
		update_icon()
		return

	if(rails_secure && (istype(W, /obj/item/stack/rods) || istype(W, /obj/item/weapon/coin) ||  istype(W, /obj/item/weapon/nullrod)))
		if(!loadedassembly)
			to_chat(user, "\The [src] needs a set of rails before it can hold \a [W].")
			return
		if(loadedammo)
			to_chat(user, "There is already something in the barrel of \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You load \a [W] into the barrel of \the [src].")
		if(istype(W, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			R.use(1)
			loadedammo = new /obj/item/stack/rods(null)
		else if(istype(W, /obj/item/weapon/nullrod))
			W.forceMove(src)
			loadedammo = W
		else if(istype(W, /obj/item/weapon/coin))
			var/obj/item/weapon/coin/C = W
			if (C.string_attached)
				to_chat(user, "Remove the string from \the [C] first.")
				return
			if (C.siemens_coefficient == 0)
				to_chat(user, "That [C.name] won't work.")
				return
			else
				C.forceMove(src)
				loadedammo = C
		update_icon()

	else if(W.is_screwdriver(user))
		if(rails_secure)
			to_chat(user, "You loosen the rail assembly within \the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		else
			to_chat(user, "You tighten the rail assembly inside \the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		rails_secure = !rails_secure

/obj/item/weapon/gun/projectile/railgun/examine(mob/user)
	..()
	if(loadedcapacitor)
		to_chat(user, "<span class='info'>There is \a [loadedcapacitor] in the capacitor bank.</span>")
		if(loadedcapacitor.stored_charge > 0)
			to_chat(user, "<span class='notice'>\The [loadedcapacitor] is charged to [loadedcapacitor.stored_charge]W.</span>")
		else
			to_chat(user, "<span class='warning'>\The [loadedcapacitor] is not charged.</span>")
	if(loadedammo)
		to_chat(user, "<span class='info'>There is a [loadedammo.name] loaded into the barrel.</span>")
	if(!loadedassembly)
		to_chat(user, "<span class='warning'>\The [src] is missing a set of rails.</span>")
	if(!rails_secure && loadedassembly)
		to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] is unsecured.</span>")

/obj/item/weapon/gun/projectile/railgun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (A.loc == user.loc)
		return

	else if (A.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	if(!loadedcapacitor || !loadedammo)
		click_empty(user)
		return
	else if(loadedcapacitor)
		if(loadedcapacitor.stored_charge <=0)
			click_empty(user)
			return
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return

	calculate_strength(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/projectile/railgun/proc/calculate_strength(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(!loadedcapacitor || !loadedammo)
		return
	
	var/shot_charge = round(loadedcapacitor.stored_charge)
	strength = shot_charge / 5000000
	
	loadedcapacitor.stored_charge -= shot_charge
	if(shot_charge < TEN_MEGAWATTS)
		strength = 0
		throw_ammo(A,user)
	
	if(strength)
		var/obj/item/projectile/bullet/APS/B = new(null)
		if(istype(loadedammo, /obj/item/weapon/coin))
			strength = strength / loadedammo.siemens_coefficient
		B.damage = strength
		B.kill_count += strength
		if(strength >= 50)
			B.stun = 3
			B.weaken = 3
			B.stutter = 3
		if(strength >= 101)
			fire_sound = 'sound/weapons/railgun_highpower.ogg'
			B.penetration = (20 + (strength - 100))
			if(strength == 101)
				B.penetration -= 1
			B.projectile_speed = 0.66
			if(istype(loadedammo, /obj/item/weapon/nullrod))
				B.blessed = TRUE
		else if(strength == 90)
			B.penetration = 10
		in_chamber = B
		
		if(Fire(A,user,params, "struggle" = struggle))
			loadedammo = null
			if(strength >= 200)
				to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] melts!</span>")
				to_chat(user, "<span class='warning'>\The [loadedcapacitor] inside \the [src]'s capacitor bank melts!</span>")
				qdel(loadedassembly)
				loadedassembly = null
				rails_secure = 0
				qdel(loadedcapacitor)
				loadedcapacitor = null
			else
				loadedassembly.durability -= strength
				if(loadedassembly.durability <= 0)
					to_chat(user, "<span class='warning'>\The [loadedassembly] inside \the [src] [strength > 100 ? "shatters under" : "finally fractures from"] the stress!</span>")
					qdel(loadedassembly)
					loadedassembly = null
					rails_secure = 0
			fire_sound = initial(fire_sound)
		else
			qdel(B)
			in_chamber = null

		update_icon()

/obj/item/weapon/gun/projectile/railgun/proc/throw_ammo(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)
	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/speed = 6
	var/distance = 10

	user.visible_message("<span class='danger'>[user] fires \the [src] and launches \the [loadedammo] at [target]!</span>","<span class='danger'>You fire \the [src] and launch \the [loadedammo] at [target]!</span>")
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[loadedammo.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])" )

	loadedammo.forceMove(user.loc)
	loadedammo.throw_at(target,distance,speed)
	loadedammo = null

/obj/item/weapon/gun/projectile/railgun/preloaded
	var/ammotype = /obj/item/weapon/coin/iron
	var/capacitortype = /obj/item/weapon/stock_parts/capacitor/adv/super
	
/obj/item/weapon/gun/projectile/railgun/preloaded/New()
	..()
	loadedassembly = new /obj/item/weapon/rail_assembly(src)
	rails_secure = 1
	loadedammo = new ammotype(src)
	loadedcapacitor = new capacitortype(src)
	loadedcapacitor.stored_charge = loadedcapacitor.maximum_charge 

/obj/item/weapon/gun/projectile/railgun/preloaded/godslayer
	ammotype = /obj/item/weapon/nullrod
	capacitortype = /obj/item/weapon/stock_parts/capacitor/adv/super/ultra

#undef MEGAWATT
#undef TEN_MEGAWATTS
#undef HUNDRED_MEGAWATTS
#undef GIGAWATT
