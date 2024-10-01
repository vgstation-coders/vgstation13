/obj/item/weapon/gun/siren
	name = "siren"
	desc = "Despite being entirely liquid, this gun's projectiles still pack a punch."
	icon = 'icons/obj/gun.dmi'
	icon_state = "siren"
	item_state = "siren"
	origin_tech = Tc_COMBAT + "=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 1
	slot_flags = SLOT_BELT
	flags = FPRINT | NOREACT | OPENCONTAINER
	w_class = W_CLASS_MEDIUM
	fire_delay = 1
	fire_sound = 'sound/weapons/shotgun.ogg'
	empty_sound = 'sound/weapons/magazine_load_click.ogg'
	conventional_firearm = 0
	var/hard = 1 //When toggled on, the gun's shots will deal damage. When off, they deal no damage, but deliver five times the reagents.
	var/max_reagents = 50
	var/obj/item/projectile/projectile_type = /obj/item/projectile/bullet/liquid_blob

	var/mixed_color = null
	var/mixed_alpha = 255
	var/radius = 0

/obj/item/weapon/gun/siren/isHandgun()
	return FALSE

/obj/item/weapon/gun/siren/New()
	..()
	create_reagents(max_reagents)
	reagents.add_reagent(WATER, max_reagents)

/obj/item/weapon/gun/siren/click_empty(mob/user = null)
	if (user)
		if(empty_sound)
			to_chat(user, "<span class='warning'>No liquid left inside \the [src]</span>")
			playsound(user, empty_sound, 100, 1)
	else
		if(empty_sound)
			playsound(src, empty_sound, 100, 1)

/obj/item/weapon/gun/siren/verb/flush_reagents()
	set name = "Flush contents"
	set category = "Object"
	set src in usr

	if(!reagents.total_volume)
		to_chat(usr, "<span class='warning'>\The [src] is already empty.</span>")
		return

	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You flush out the contents of \the [src].</span>")
	if(in_chamber)
		QDEL_NULL(in_chamber)

/obj/item/weapon/gun/siren/on_reagent_change()
	mixed_color = mix_color_from_reagents(reagents.reagent_list)
	mixed_alpha = mix_alpha_from_reagents(reagents.reagent_list)

/obj/item/weapon/gun/siren/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [round(reagents.total_volume/5)] round\s remaining.</span>")
	if(hard >= 0)
		if(hard)
			to_chat(user, "<span class='info'>It is set to \"hard liquid\".</span>")
		else
			to_chat(user, "<span class='info'>It is set to \"soft liquid\".</span>")

/obj/item/weapon/gun/siren/attack_self(mob/user as mob)
	hard = !hard
	if(hard)
		to_chat(user, "<span class='info'>You set \the [src] to fire hard liquid.</span>")
		desc = initial(desc)
		fire_sound = initial(fire_sound)
		recoil = 1
		radius = 0
	else
		to_chat(user, "<span class='info'>You set \the [src] to fire soft liquid.</span>")
		desc = "The most efficient ranged mass reagent delivery system there is."
		fire_sound = 'sound/items/egg_squash.ogg'
		recoil = 0
		radius = 1

/obj/item/weapon/gun/siren/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(reagents.total_volume < 5)
		return click_empty(user)
	if(in_chamber)
		if(in_chamber.reagents && in_chamber.reagents.total_volume)
			if(istype(in_chamber, /obj/item/projectile/bullet/liquid_blob))
				var/obj/item/projectile/bullet/liquid_blob/L = in_chamber
				if(!L.hard)
					for(var/datum/reagent/R in in_chamber.reagents.reagent_list)
						in_chamber.reagents.remove_reagent(R.id, reagents.get_reagent_amount(R.id)*4)
			in_chamber.reagents.trans_to(src, in_chamber.reagents.total_volume)
		QDEL_NULL(in_chamber)
	in_chamber = new projectile_type(src, hard, mixed_color, mixed_alpha, radius)
	reagents.trans_to(in_chamber, 5)
	if(!hard) //When set to no-damage mode, each shot has ten times the reagents.
		for(var/datum/reagent/R in in_chamber.reagents.reagent_list)
			R.volume *= 10
	Fire(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/siren/process_chambered()
	return in_chamber

/obj/item/weapon/gun/siren/can_discharge()
	if(reagents.total_volume < 5)
		return 1

/obj/item/weapon/gun/siren/caduceus
	name = "Caduceus"
	desc = "For smiting and revitalizing. A paladin's friend, with handy refilling barrels and an ultra-sharp blade for butchering zombies instantly."
	icon_state = "caduceus"
	item_state = "caduceus"
	var/spawning_ammo = DOCTORSDELIGHT
	max_reagents = 100
	sharpness = 25
	sharpness_flags = SHARP_BLADE
	attack_verb = list("grinds open", "cleaves apart", "rends", "gelds", "rips and tears", "shreds")
	force = 10
	light_power = 1
	light_range = 6
	light_color = LIGHT_COLOR_SLIME_LAMP

/obj/item/weapon/gun/siren/caduceus/New()
	..()
	processing_objects.Add(src)
	create_reagents(max_reagents)
	reagents.add_reagent(spawning_ammo, max_reagents)

/obj/item/weapon/gun/siren/caduceus/process()
	reagents.add_reagent(spawning_ammo, 10)

/obj/item/weapon/gun/siren/supersoaker
	name = "super soaker"
	desc = "For ages 10 and up. Pump it to shoot further."
	icon_state = "super_soaker"
	item_state = "super_soaker"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	origin_tech = Tc_COMBAT + "=1"
	recoil = 0
	flags = FPRINT | OPENCONTAINER
	fire_sound = 'sound/items/egg_squash.ogg'
	max_reagents = 200
	hard = -1
	projectile_type = /obj/item/projectile/beam/liquid_stream
	clumsy_check = 0
	var/last_pump = 0
	var/pumps = 0

/obj/item/weapon/gun/siren/supersoaker/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return
	if(reagents.total_volume < 5 && !in_chamber)
		return click_empty(user)
	if(!in_chamber)
		in_chamber = new projectile_type(src, min(3+(round(pumps/2)),15), mixed_color, mixed_alpha)
		reagents.trans_to(in_chamber, 5)
		for(var/datum/reagent/R in in_chamber.reagents.reagent_list)
			R.volume *= 4//so here we're just doubling our quantity of reagents from 10 to 20//moved from projectile code
	in_chamber.firer = user
	Fire(A,user,params, struggle = struggle)
	if(pumps > 0)
		pumps--
	QDEL_NULL(in_chamber)

/obj/item/weapon/gun/siren/supersoaker/attack_self(mob/user)
	if(world.time - last_pump >= 1)
		if(pumps >= 24)
			return
		to_chat(user, "You pump \the [src].")
		pumps++
		last_pump = world.time
		if(in_chamber)
			var/obj/item/projectile/beam/liquid_stream/L = in_chamber
			if(istype(L))
				L.adjust_strength(max(3+(round(pumps/2)),15))

/obj/item/weapon/gun/siren/supersoaker/pistol
	name = "squirt gun"
	desc = "Fun for all ages!"
	icon_state = "squirt_gun"
	item_state = "squirt_gun"
	max_reagents = 50

/obj/item/weapon/gun/siren/supersoaker/pistol/isHandgun()
	return TRUE

/obj/item/weapon/gun/siren/supersoaker/pistol/attack_self(mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>\The [src] is already empty.</span>")
		return

	reagents.clear_reagents()
	to_chat(user, "<span class='notice'>You flush out the contents of \the [src].</span>")
	if(in_chamber)
		QDEL_NULL(in_chamber)
