/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = 1.0
	var/caliber = "" //The caliber defines what kind of gun it can be loaded into
	var/projectile_type = "" //The bullet type to create when New() is called
	var/obj/item/projectile/BB = null //The actual bullet, what you fire at people
	var/eject_casing = 1 //This type of ammunition leaves casings when fired from a gun
	var/casing_insert_sound = 'sound/weapons/shotgun_casing.ogg' //Sound when inserting a casing

/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	update_icon()

/obj/item/ammo_casing/update_icon()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(cardinal)
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"

/obj/item/ammo_casing/examine(mob/user)
	..()
	if(!BB)
		user << "<span class='info'>This casing is empty. Nothing but a few grams of metal.</span>"

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
	w_class = 1.0
	throw_speed = 4
	throw_range = 5
	var/list/stored_ammo = list()
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/exact = 1 //Whether or not the item only takes ammo_type, or also subtypes. Set to 1 to only take the specified ammo
	var/max_ammo = 7
	var/starting_ammo = -1 //-1 makes it spawn the max ammo, 0 and above makes it spawn that number
	var/multiple_sprites = 0 //If it has multiple sprites. Please sprite more than 2 sprites if you set this to true, you fricks
	var/sprite_modulo = 1 //The spacing of the ammo sprites. Setting this to 1 means there's a sprite for every state, 10 for every 10 states, etc.
	var/loading_delay = 5 //How long it takes to auto-load from this. Defaults to half a second for manual loading

/obj/item/ammo_storage/New()
	..()
	var/ammo_to_load = 0
	if(starting_ammo > -1 && starting_ammo < max_ammo)
		ammo_to_load = starting_ammo
	else
		ammo_to_load = max_ammo
	for(var/i = 1, i <= ammo_to_load, i++)
		stored_ammo += new ammo_type(src)

//Now with automatic loading included
/obj/item/ammo_storage/attackby(var/atom/A, var/mob/user)
	..()
	if(istype(A, /obj/item/ammo_casing)) //Loading a bullet into the magazine or box
		var/obj/item/ammo_casing/AC = A
		var/accepted = 0
		if((exact && (AC.type == text2path(ammo_type))) || (!exact && istype(AC, text2path(ammo_type)))) //If it's the exact type we want, or the general class
			accepted = 1
		if(AC.BB && accepted && stored_ammo.len < max_ammo)
			stored_ammo += AC
			user.drop_item(A, src)
			user.visible_message("<span class='notice'>[user] loads \a [AC.name] into \the [src].</span>", \
			"<span class='notice'>You load \a [AC.name] into \the [src].</span>")
			playsound(get_turf(src), AC.casing_insert_sound, 100, 1)
			update_icon()
		else if(!AC.BB) //We are trying to insert a spent casing. We can't, we're too good for dirty tactics like this
			user << "<span class='warning'>You can't load spent casings.</span>"
			return
		else if(stored_ammo.len >= max_ammo)
			user << "<span class='notice'>\The [src] cannot hold any more shells.</span>"
			return
	if(istype(A, /obj/item/ammo_storage)) //Transfer from any type of ammo storage
		var/obj/item/ammo_storage/AS = A
		if(stored_ammo.len < max_ammo && AS.stored_ammo)
			load_from(AS, src, user)
		else if(stored_ammo.len >= max_ammo)
			user << "<span class='notice'>\The [src] cannot hold any more shells.</span>"

/obj/item/ammo_storage/update_icon()
	if(multiple_sprites)
		if(!sprite_modulo)
			sprite_modulo = max_ammo
		var/visible_ammo = stored_ammo.len - (stored_ammo.len % sprite_modulo) //The smallest round number in the interval
		if(!visible_ammo && stored_ammo.len) //If there IS ammo but we can't see it
			visible_ammo += sprite_modulo //We go to the next lowest sprite state so it doesn't look empty
		icon_state = "[initial(icon_state)]-[visible_ammo]"

/obj/item/ammo_storage/examine(mob/user)
	..()
	if(max_ammo > 0)
		user << "<span class='info'>It can hold [max_ammo] round\s</span>"
		user << "<span class='info'>There are [stored_ammo.len] round\s left.</span>"
	else
		user << "<span class='info'>It is completely empty.</span>"

/obj/item/ammo_storage/attack_self(mob/user) //Allows you to remove individual bullets
	if(stored_ammo.len)
		var/obj/item/ammo_casing/dropped = stored_ammo[1]
		dropped.loc = get_turf(user)
		stored_ammo -= dropped
		update_icon()
		user << "<span class='notice'>You remove \a [dropped.name] from \the [src].</span>"

//We load a target item full from our ammo storage item
//This loads the bullets one by one, but it's automated so you don't get carpal tunnel
//Includes a delay and strings
/obj/item/ammo_storage/proc/load_from(var/obj/item/ammo_storage/bullets_from, var/obj/item/target, var/mob/living/user)

	var/trying_to_load = 0 //We need to figure out how many bullets we want to load, first of all
	if(istype(target, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/PW = target
		trying_to_load = min(PW.max_shells - PW.loaded.len, bullets_from.stored_ammo.len) //Either we fill to max, or we fill as much as possible
	else
		var/obj/item/ammo_storage/AS = target
		trying_to_load = min(AS.max_ammo - AS.stored_ammo.len, bullets_from.stored_ammo.len) //Either we fill to max, or we fill as much as possible
	if(trying_to_load) //Non-zero amount
		user.visible_message("<span class='notice'>[user] begins loading \his [target] from \a [bullets_from.name].", \
		"<span class='notice'>You begin loading your [target] from \a [bullets_from.name].")

	var/loaded_tally = 0
	for(var/i = 1 to trying_to_load) //For every single round we are going to load
		if(bullets_from == user.get_active_hand() && get_dist(user, target) <= 1 && get_dist(bullets_from, target) <= 1) //Well, we can't use do_after, so plan B
			sleep(bullets_from.loading_delay)
			if(load_into(bullets_from, target, user))
				loaded_tally++
		else //We have been interrupted
			var/to_drop = rand(1, min(loaded_tally, 10)) //Drop some on the floor
			var/dropped = 0
			for(var/f = 1 to min(to_drop, bullets_from.stored_ammo.len))
				var/obj/item/ammo_casing/AC = bullets_from.stored_ammo[1]
				bullets_from.stored_ammo -= AC
				AC.forceMove(get_turf(bullets_from))
				bullets_from.update_icon()
				dropped++
			user.visible_message("<span class='warning'[user] fumbles around and drops [dropped] round\s from \the [bullets_from]!</span>", \
			"<span class='warning'>You fumble around and drop [dropped] round\s from \the [bullets_from]!</span>")
			return //Stop

	if(loaded_tally)
		user.visible_message("<span class='notice'>[user] finishes loading \his [target.name].", \
		"<span class='notice'>You finish loading your [target.name] with [loaded_tally] round\s from \the [bullets_from]</span>.")
	else
		user.visible_message("<span class='notice'>[user] fails to load \his [target.name].", \
		"<span class='notice'>You fail to load anything in your [target.name]</span>.")

//General method. Loads one bullet at a time. Can be overriden for things like speed reloaders or ammo belts
/obj/item/ammo_storage/proc/load_into(var/obj/item/ammo_storage/bullets_from, var/obj/item/target, var/mob/living/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/ammo_storage/proc/LoadInto() called tick#: [world.time]")
	if(istype(target, /obj/item/ammo_storage))
		var/obj/item/ammo_storage/AS = target
		var/obj/item/ammo_casing/loading = pick(bullets_from.stored_ammo)
		if(AS.stored_ammo.len >= AS.max_ammo) //Ammo box is already full at this moment
			return 0
		if((AS.exact && (loading.type == text2path(AS.ammo_type))) || (!AS.exact && istype(loading, text2path(AS.ammo_type)))) //If it's the exact type we want, or the general class
			bullets_from.stored_ammo -= loading
			AS.stored_ammo += loading
			loading.forceMove(AS)
			playsound(get_turf(src), loading.casing_insert_sound, 100, 1)
		else
			return 0
	if(istype(target, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/PW = target
		var/obj/item/ammo_casing/loading = pick(bullets_from.stored_ammo)
		if(PW.loaded.len >= PW.max_shells) //Gun is already full at this moment
			return 0
		if(PW.caliber && PW.caliber[loading.caliber]) //Gun variables. Just 'cause.
			bullets_from.stored_ammo -= loading
			PW.loaded += loading
			loading.forceMove(PW)
			playsound(get_turf(src), loading.casing_insert_sound, 100, 1)
		else
			return 0
	bullets_from.update_icon()
	target.update_icon()
	return 1

//We take a round out
/obj/item/ammo_storage/proc/get_round(var/keep = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/ammo_storage/proc/get_round() called tick#: [world.time]")
	if(!ammo_count())
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1, b)
		else
			update_icon()
		return b

//We return the amount of ammunition
/obj/item/ammo_storage/proc/ammo_count()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/ammo_storage/proc/ammo_count() called tick#: [world.time]")
	return stored_ammo.len
