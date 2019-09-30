/obj/item/weapon/gun/projectile/rocketlauncher
	name = "rocket launcher"
	desc = "Ranged explosions, science marches on."
	fire_sound = 'sound/weapons/rocket.ogg'
	icon_state = "rpg"
	item_state = "rpg"
	max_shells = 1
	w_class = W_CLASS_LARGE
	starting_materials = list(MAT_IRON = 5000)
	w_type = RECYK_METAL
	force = 10
	recoil = 5
	throw_speed = 4
	throw_range = 3
	fire_delay = 5
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(ROCKETGRENADE = 1)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=2"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg"
	attack_verb = list("strikes", "hits", "bashes")
	gun_flags = 0

/obj/item/weapon/gun/projectile/rocketlauncher/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/rocketlauncher/update_icon()
	if(!getAmmo())
		icon_state = "rpg_e"
		item_state = "rpg_e"
	else
		icon_state = "rpg"
		item_state = "rpg"

/obj/item/weapon/gun/projectile/rocketlauncher/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user && user.zone_sel.selecting == "mouth") //Are we trying to suicide by shooting our head off ?
		user.visible_message("<span class='warning'>[user] tries to fit \the [src] into \his mouth but quickly reconsiders it</span>", \
		"<span class='warning'>You try to fit \the [src] into your mouth. You feel silly and pull it out</span>")
		return // Nope
	..()

/obj/item/weapon/gun/projectile/rocketlauncher/suicide_act(var/mob/user)
	if(!src.process_chambered()) //No rocket in the rocket launcher
		user.visible_message("<span class='danger'>[user] jams down \the [src]'s trigger before noticing it isn't loaded and starts bashing \his head in with it! It looks like \he's trying to commit suicide.</span>")
		return(SUICIDE_ACT_BRUTELOSS)
	else //Needed to get that shitty default suicide_act out of the way
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, -1, 1, 4, 8)
			if(src) //Is the rocket launcher somehow still here ?
				qdel(src) //This never happened
			return(SUICIDE_ACT_BRUTELOSS)
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen
	name = "rocket launcher"
	desc = "Watch the backblast, you idiot."
	fire_sound = 'sound/weapons/rocket.ogg'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	icon_state = "rpg_nt"
	item_state = "rpg_nt"
	max_shells = 1
	w_class = W_CLASS_LARGE
	starting_materials = list(MAT_IRON = 50000, MAT_GLASS = 50000, MAT_GOLD = 6000)
	w_type = RECYK_METAL
	force = 10
	recoil = 5
	throw_speed = 4
	throw_range = 3
	fire_delay = 5
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(ROCKETGRENADE = 1)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2;"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg/blank"
	attack_verb = list("strikes", "hits", "bashes")
	gun_flags = 0

/obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen/update_icon()
	if(!getAmmo())
		icon_state = "rpg_nt_e"
		item_state = "rpg_nt_e"
	else
		icon_state = "rpg_nt"
		item_state = "rpg_nt"

/obj/item/weapon/gun/projectile/rocketlauncher/nanotrasen/lockbox
	spawn_mag = TRUE

/obj/item/weapon/gun/projectile/rocketlauncher/nikita
	name = "\improper Nikita"
	desc = "A miniature cruise missile launcher. Using a pulsed rocket engine and sophisticated TV guidance system."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "nikita"
	item_state = null
	origin_tech = Tc_MATERIALS + "=5;" + Tc_COMBAT + "=6;" + Tc_PROGRAMMING + "=4"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	slot_flags = SLOT_BACK
	w_class = W_CLASS_LARGE
	fire_delay = 2
	caliber = list(GUIDEDROCKET = 1)
	origin_tech = null
	fire_sound = 'sound/weapons/rocket.ogg'
	ammo_type = "/obj/item/ammo_casing/rocket_rpg/nikita"
	var/obj/item/projectile/rocket/nikita/fired = null
	var/emagged = 0

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/update_icon()
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/attack_self(mob/user)
	if(fired)
		playsound(src, 'sound/weapons/stickybomb_det.ogg', 30, 1)
		fired.detonate()

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/suicide_act(var/mob/user)
	if(!loaded)
		user.visible_message("<span class='danger'>[user] jams down \the [src]'s trigger before noticing it isn't loaded and starts bashing \his head in with it! It looks like \he's trying to commit suicide.</span>")
		return(SUICIDE_ACT_BRUTELOSS)
	else
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, 1, 3, 5, 8) //Using the actual rocket damage, instead of the very old, super nerfed value
			return(SUICIDE_ACT_BRUTELOSS)
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/card/emag) && !emagged)
		emagged = 1
		to_chat(user, "<span class='warning'>You disable \the [src]'s idiot security!</span>")
	else
		..()

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/process_chambered()
	if(..())
		if(!emagged)
			fired = in_chamber
		return 1
	return 0

/obj/item/ammo_casing/rocket_rpg/nikita
	name = "\improper Nikita missile"
	desc = "A miniature cruise missile"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "nikita"
	caliber = GUIDEDROCKET
	projectile_type = "/obj/item/projectile/rocket/nikita"

/obj/item/ammo_casing/rocket_rpg/nikita/New()
	..()
	pixel_x = rand(-10, 10) * PIXEL_MULTIPLIER
	pixel_y = rand(-10, 10) * PIXEL_MULTIPLIER
