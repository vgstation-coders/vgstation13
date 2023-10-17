/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = W_CLASS_TINY
	var/caliber = ""							//Which kind of guns it can be loaded into
	var/projectile_type = ""//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	shrapnel_amount = 1
	shrapnel_type = /obj/item/projectile/bullet/shrapnel/small
	shrapnel_size = 1


/obj/item/ammo_casing/New(var/loc,var/empty = 0)
	..()
	if(projectile_type && !empty)
		BB = new projectile_type(src)
	update_icon()

/obj/item/ammo_casing/update_icon()
	pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
	dir = pick(cardinal)
	name = "[BB ? "" : "spent "][initial(name)]"
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

/obj/item/ammo_casing/get_shrapnel_projectile()
	if(BB)

		var/obj/item/projectile/bullet_bill = BB
		BB = null
		return bullet_bill
	else
		return new shrapnel_type(src)


/obj/item/ammo_casing/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"BB")

	reset_vars_after_duration(resettable_vars, duration)

//Boxes of ammo
/obj/item/ammo_storage
	name = "ammo box (.357)"
	desc = "A box of ammo."
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	starting_materials = list(MAT_IRON = 50000)
	w_type = RECYK_METAL
	throwforce = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	on_armory_manifest = TRUE
	var/list/stored_ammo = list()
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/reloading = FALSE // Flag to stop multi-box loading
	var/reload_delay = 5 // Delay for do_after() call of reloading
	var/reload_sound = 'sound/weapons/magazine_load_click.ogg'
	var/fumble_sound = 'sound/weapons/casing_drop.ogg'
	var/exact = 1 //whether or not the item only takes ammo_type, or also subtypes. Set to 1 to only take the specified ammo
	var/caliber = POINT357 //lets us define what magazines can go into guns
	var/max_ammo = 7
	var/starting_ammo = -1 //-1 makes it spawn the max ammo, 0 and above makes it spawn that number
	var/multiple_sprites = 0 //if it has multiple sprites. Please sprite more than 2 sprites if you set this to true, you fricks
	var/sprite_modulo = 1 //the spacing of the ammo sprites. Setting this to 1 means there's a sprite for every state, 10 for every 10 states, etc.


/obj/item/ammo_storage/New()
	..()
	var/ammo_to_load = 0
	if(starting_ammo > -1 && starting_ammo < max_ammo)
		ammo_to_load = starting_ammo
		update_icon()
	else
		ammo_to_load = max_ammo
	for(var/i = 1, i <= ammo_to_load, i++)
		stored_ammo += new ammo_type(src)

/obj/item/ammo_storage/attackby(var/atom/A, var/mob/user) //now with loading
	..()
	if(istype(A, /obj/item/ammo_casing)) //loading a bullet into the magazine or box
		var/obj/item/ammo_casing/AC = A
		var/accepted = 0
		if((exact && (AC.type == text2path(ammo_type))) || (!exact && (AC.caliber == caliber)))
			accepted = 1
		else
			to_chat(user, "<span class='warning'>\the [AC] does not fit into [src]. </span>")
			return
		if(AC.BB && accepted && stored_ammo.len < max_ammo)
			if(user.drop_item(A, src))
				to_chat(user, "<span class='notice'>You successfully load the [src] with \the [AC]. </span>")
				playsound(usr, reload_sound, 100, 1)
			else
				to_chat(user, "<span class='warning'>You can't let go of \the [A]!</span>")
				return


			stored_ammo += AC

			update_icon()
		else if(!AC.BB)
			to_chat(user, "<span class='notice'>You can't load a spent bullet.</span>")
		else if (stored_ammo.len == max_ammo)
			to_chat(user, "<span class='notice'>\The [src] can't hold any more shells.</span>")
		return
	if(istype(A, /obj/item/ammo_storage)) //loads all the bullets from one magazine to the other
		var/obj/item/ammo_storage/AS = A
		if(stored_ammo.len < max_ammo && AS.stored_ammo)
			var/loaded_bullets = LoadInto(AS, src)
			if(loaded_bullets)
				to_chat(user, "<span class='notice'>You successfully fill the [src] with [loaded_bullets] shell\s from the [AS].</span>")
				update_icon()
		else if (stored_ammo.len >= max_ammo)
			to_chat(user, "<span class='notice'>\The [src] can't hold any more shells.</span>")

/obj/item/ammo_storage/update_icon()
	if(multiple_sprites)
		if(!sprite_modulo)
			sprite_modulo = max_ammo
		var/visible_ammo = stored_ammo.len - (stored_ammo.len % sprite_modulo) //the smallest round number in the interval
		if(visible_ammo == 0 && stored_ammo.len) //if there IS ammo, but we can't see it because the thing is at 0 (most sprites are like this)
			visible_ammo += sprite_modulo //we go to the next lowest sprite state so it doesn't look empty
		icon_state = "[initial(icon_state)]-[visible_ammo]"

/obj/item/ammo_storage/examine(mob/user) //never change descriptions, always use examine
	..()
	if(max_ammo > 0)
		to_chat(user, "<span class='info'>There are [stored_ammo.len] shell\s left!</span>")

/obj/item/ammo_storage/attack_self(mob/user) //allows you to remove individual bullets
	if(stored_ammo.len)
		var/obj/item/ammo_casing/dropped = stored_ammo[1]
		dropped.forceMove(get_turf(user))
		stored_ammo -= dropped
		update_icon()
		to_chat(user, "<span class='notice'>You remove \a [dropped] from \the [src].</span>")

/obj/item/ammo_storage/proc/loadGun(var/obj/item/ammo_storage/bullets_from, var/obj/item/target)
	var/obj/item/weapon/gun/projectile/PW = target
	var/trying_to_load = min(PW.max_shells - PW.loaded.len - PW.refuse.len, bullets_from.stored_ammo.len) // Either we fill to max, or we fill as much as possible

	if (!trying_to_load || !usr || bullets_from.reloading)
		return 0

	bullets_from.reloading = TRUE
	var/bullets_loaded = 0

	for (var/i = 1; i <= trying_to_load; i++)
		var/obj/item/ammo_casing/loading = bullets_from.stored_ammo[1] // Grab bullet from top of stack

		if (PW.loaded.len + PW.refuse.len >= PW.max_shells)
			break
		if (!(PW.caliber && PW.caliber[loading.caliber]))
			break
		if (!do_after(usr, target, reload_delay, 5))
			return fumbleLoad(bullets_from, target)

		bullets_from.stored_ammo -= loading
		PW.loaded += loading
		loading.forceMove(PW)
		bullets_loaded++
		bullets_from.update_icon()
		target.update_icon()

		if (reload_delay == 0 && i > 1)	// When reload delay is 0 (speedloaders by default), play the reload sound on first iteration only
			continue
		playsound(usr, reload_sound, 100, 1)

	bullets_from.reloading = FALSE
	return bullets_loaded

/obj/item/ammo_storage/proc/loadAmmoStorage(var/obj/item/ammo_storage/bullets_from, var/obj/item/target)
	var/obj/item/ammo_storage/AS = target
	var/trying_to_load = min(AS.max_ammo - AS.stored_ammo.len, bullets_from.stored_ammo.len) // Either we fill to max, or we fill as much as possible

	if (!trying_to_load || !usr || bullets_from.reloading)
		return 0

	bullets_from.reloading = TRUE
	var/bullets_loaded = 0

	for (var/i = 1; i <= trying_to_load; i++)
		var/obj/item/ammo_casing/loading = bullets_from.stored_ammo[1] // Grab bullet from top of stack

		if (AS.stored_ammo.len >= AS.max_ammo)
			break
		if (!((AS.exact && (loading.type == text2path(AS.ammo_type))) || (!AS.exact && (bullets_from.caliber == caliber)))) // If not exact, check if same caliber
			break
		if (!do_after(usr, target, 5, 5))
			return fumbleLoad(bullets_from, target)

		bullets_from.stored_ammo -= loading
		AS.stored_ammo += loading
		loading.forceMove(AS)
		bullets_loaded++
		playsound(usr, reload_sound, 100, 1)
		bullets_from.update_icon()
		target.update_icon()

	bullets_from.reloading = FALSE
	return bullets_loaded

// Aborting a reload (Bullet by bullet from a box or similar) causes you to fumble and drop a shell
/obj/item/ammo_storage/proc/fumbleLoad(var/obj/item/ammo_storage/bullets_from, var/obj/item/target)
	var/obj/item/ammo_casing/AC = bullets_from.stored_ammo[1]
	bullets_from.stored_ammo -= AC
	AC.forceMove(get_turf(target))
	bullets_from.update_icon()

	if (usr)
		to_chat(usr, "<span class='rose'>You fumble around and drop a shell!</span>")
		playsound(usr, fumble_sound, 100, 1)

	bullets_from.reloading = FALSE
	return 0

//used to load bullets from ammo storage into other ammo storage or guns
//bullets_from is the origin, target is the gun or targetted box
/obj/item/ammo_storage/proc/LoadInto(var/obj/item/ammo_storage/bullets_from, var/obj/item/target)
	if (!bullets_from || !istype(bullets_from))
		return 0
	if (!target || !istype(target))
		return 0

	if (istype(target, /obj/item/weapon/gun/projectile))
		return loadGun(bullets_from, target)
	else if (istype(target, /obj/item/ammo_storage))
		return loadAmmoStorage(bullets_from, target)
	return 0


/obj/item/ammo_storage/proc/get_round(var/keep = 0)
	if(!ammo_count())
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1,b)
		else
			update_icon()
		return b

/obj/item/ammo_storage/proc/ammo_count()
	return stored_ammo.len

/obj/item/ammo_storage/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"stored_ammo")

	reset_vars_after_duration(resettable_vars, duration)
