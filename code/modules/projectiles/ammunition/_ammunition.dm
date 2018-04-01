/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags_1 = CONDUCT_1
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/randomspread = 0						//Randomspread for automatics
	var/delay = 0								//Delay for energy weapons
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect	//the visual effect appearing when the ammo is fired.
	var/heavy_metal = TRUE


/obj/item/ammo_casing/Initialize()
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	setDir(pick(GLOB.alldirs))
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"

//proc to magically refill a casing with a new projectile
/obj/item/ammo_casing/proc/newshot() //For energy weapons, syringe gun, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, src)

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if (box.stored_ammo.len >= box.max_ammo)
					break
				if (bullet.BB)
					if (box.give_round(bullet, 0))
						boolets++
				else
					continue
			if (boolets > 0)
				box.update_icon()
				to_chat(user, "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>")
			else
				to_chat(user, "<span class='warning'>You fail to collect anything!</span>")
	else
		return ..()

/obj/item/ammo_casing/throw_impact(atom/A)
	if(heavy_metal)
		bounce_away(FALSE, NONE)
	. = ..()

/obj/item/ammo_casing/proc/bounce_away(still_warm = FALSE, delay = 3)
	SpinAnimation(10, 1)
	update_icon()
	var/turf/T = get_turf(src)
	if(still_warm && T && (is_type_in_typecache(T, GLOB.bullet_bounce_away_sizzle)))
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, src, 'sound/items/welder.ogg', 20, 1), delay)
	else if(T && (!is_type_in_typecache(T, GLOB.bullet_bounce_away_blacklist)))
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, src, 'sound/weapons/bulletremove.ogg', 60, 1), delay)

GLOBAL_LIST_INIT(bullet_bounce_away_sizzle, typecacheof(list(
	/turf/closed/indestructible/rock/snow,
	/turf/closed/wall/ice,
	/turf/closed/wall/mineral/snow,
	/turf/open/floor/grass/snow,
	/turf/open/floor/holofloor/snow,
	/turf/open/floor/plating/asteroid/snow,
	/turf/open/floor/plating/ice,
	/turf/open/water)))

GLOBAL_LIST_INIT(bullet_bounce_away_blacklist, typecacheof(list(
	/turf/closed/indestructible/rock/snow,
	/turf/closed/indestructible/splashscreen,
	/turf/closed/wall/mineral/snow,
	/turf/open/chasm,
	/turf/open/floor/carpet,
	/turf/open/floor/grass,
	/turf/open/floor/holofloor/beach,
	/turf/open/floor/holofloor/carpet,
	/turf/open/floor/holofloor/grass,
	/turf/open/floor/holofloor/hyperspace,
	/turf/open/floor/holofloor/snow,
	/turf/open/floor/plating/asteroid/snow,
	/turf/open/floor/plating/beach,
	/turf/open/indestructible/reebe_void,
	/turf/open/lava,
	/turf/open/space,
	/turf/open/water,
	/turf/template_noop)))
