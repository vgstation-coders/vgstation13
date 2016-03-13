/obj/item/weapon/gun/gatling
	name = "gatling gun"
	desc = "Ya-ta-ta-ta-ta-ta-ta-ta ya-ta-ta-ta-ta-ta-ta-ta do-de-da-va-da-da-dada! Kaboom-Kaboom!"
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "minigun"
	item_state = "minigun0"
	origin_tech = "materials=4;combat=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	slot_flags = null
	flags = FPRINT | TWOHANDABLE
	w_class = 5.0//we be fuckin huge maaan
	fire_delay = 0
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	var/max_shells = 200
	var/current_shells = 200

/obj/item/weapon/gun/gatling/isHandgun()
	return 0

/obj/item/weapon/gun/gatling/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [current_shells] round\s remaining.</span>")

/obj/item/weapon/gun/gatling/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/gatling/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	..()
	var/list/turf/possible_turfs = list()
	for(var/turf/T in orange(target,1))
		possible_turfs += T
	spawn()
		for(var/i = 1; i <= 3; i++)
			sleep(1)
			var/newturf = pick(possible_turfs)
			..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/gatling/update_wield(mob/user)
	item_state = "minigun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = 10
	else
		slowdown = 0

/obj/item/weapon/gun/gatling/process_chambered()
	if(in_chamber) return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new/obj/item/projectile/bullet/gatling()//We create bullets as we are about to fire them. No other way to remove them from the gatling.
		new/obj/item/ammo_casing_gatling(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/gatling/update_icon()
	switch(current_shells)
		if(150 to INFINITY)
			icon_state = "minigun100"
		if(100 to 149)
			icon_state = "minigun75"
		if(50 to 99)
			icon_state = "minigun50"
		if(1 to 49)
			icon_state = "minigun25"
		else
			icon_state = "minigun0"

/obj/item/weapon/gun/gatling/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/ammo_casing_gatling
	name = "large bullet casing"
	desc = "An oversized bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "gatling-casing"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 1
	w_class = 1.0
	w_type = RECYK_METAL

/obj/item/ammo_casing_gatling/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(cardinal)

/obj/item/weapon/gun/gatling/beegun
	name = "bee gun"
	desc = "The apocalypse hasn't even begun!"//I'm not even sorry
	icon_state = "beegun"
	item_state = "beegun0"
	origin_tech = "materials=4;combat=6;biotech=5"
	recoil = 0

/obj/item/weapon/gun/gatling/beegun/update_wield(mob/user)
	item_state = "beegun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = 10
	else
		slowdown = 0

/obj/item/weapon/gun/gatling/beegun/process_chambered()
	if(in_chamber) return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new/obj/item/projectile/bullet/beegun()
		return 1
	return 0

/obj/item/weapon/gun/gatling/beegun/update_icon()
	switch(current_shells)
		if(150 to INFINITY)
			icon_state = "beegun100"
		if(100 to 149)
			icon_state = "beegun75"
		if(50 to 99)
			icon_state = "beegun50"
		if(1 to 49)
			icon_state = "beegun25"
		else
			icon_state = "beegun0"

#define OSIPR_MAX_CORES 3
#define OSIPR_PRIMARY_FIRE 1
#define OSIPR_SECONDARY_FIRE 2

/obj/item/weapon/gun/osipr
	name = "\improper Overwatch Standard Issue Pulse Rifle"
	desc = "Centuries ago those weapons striked fear in all of humanity when the Combine attacked the Earth. Nowadays these are just the best guns that the Syndicate can provide to its Elite Troops with its tight budget."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "osipr"
	item_state = "osipr"
	slot_flags = SLOT_BELT
	origin_tech = "materials=5;combat=5;magnets=4;powerstorage=3"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	fire_delay = 0
	w_class = 3.0
	fire_sound = 'sound/weapons/osipr_fire.ogg'
	var/obj/item/energy_magazine/osipr/magazine = null
	var/energy_balls = 2
	var/mode = OSIPR_PRIMARY_FIRE

/obj/item/weapon/gun/osipr/New()
	..()
	magazine = new(src)

/obj/item/weapon/gun/osipr/Destroy()
	if(magazine)
		qdel(magazine)
	..()

/obj/item/weapon/gun/osipr/examine(mob/user)
	..()
	if(magazine)
		to_chat(user, "<span class='info'>Has [magazine.bullets] pulse bullet\s remaining.</span>")
	else
		to_chat(user, "<span class='info'>It has no pulse magazine inserted!</span>")
	to_chat(user, "<span class='info'>Has [energy_balls] dark energy core\s remaining.</span>")

/obj/item/weapon/gun/osipr/process_chambered()
	if(in_chamber) return 1
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			if(!magazine || !magazine.bullets) return 0
			magazine.bullets--
			update_icon()
			in_chamber = new magazine.bullet_type()
			return 1
		if(OSIPR_SECONDARY_FIRE)
			if(!energy_balls) return 0
			energy_balls--
			in_chamber = new/obj/item/projectile/energy/osipr()
			return 1
	return 0

/obj/item/weapon/gun/osipr/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/energy_magazine/osipr))
		if(magazine)
			to_chat(user, "There is another magazine already inserted. Remove it first.")
		else
			user.u_equip(A,1)
			A.loc = src
			magazine = A
			update_icon()
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			to_chat(user, "<span class='info'>You insert a new magazine.</span>")
			user.regenerate_icons()

	else if(istype(A, /obj/item/osipr_core))
		if(energy_balls >= OSIPR_MAX_CORES)
			to_chat(user, "The OSIPR cannot receive any additional dark energy core.")
		else
			user.u_equip(A,1)
			qdel(A)
			energy_balls++
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			to_chat(user, "<span class='info'>You insert \the [A].</span>")
	else
		..()

/obj/item/weapon/gun/osipr/attack_hand(mob/user)
	if(((src == user.r_hand) || (src == user.l_hand)) && magazine)
		magazine.update_icon()
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		playsound(get_turf(src), 'sound/machines/click.ogg', 25, 1)
		to_chat(user, "<span class='info'>You remove the magazine.</span>")
		user.regenerate_icons()
	else
		..()

/obj/item/weapon/gun/osipr/attack_self(mob/user)
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			mode = OSIPR_SECONDARY_FIRE
			fire_sound = 'sound/weapons/osipr_altfire.ogg'
			fire_delay = 20
			to_chat(user, "<span class='warning'>Now set to fire dark energy orbs.</span>")
		if(OSIPR_SECONDARY_FIRE)
			mode = OSIPR_PRIMARY_FIRE
			fire_sound = 'sound/weapons/osipr_fire.ogg'
			fire_delay = 0
			to_chat(user, "<span class='warning'>Now set to fire pulse bullets.</span>")

/obj/item/weapon/gun/osipr/update_icon()
	if(!magazine)
		icon_state = "osipr-empty"
		item_state = "osipr-empty"
	else
		item_state = "osipr"
		var/bullets = round(magazine.bullets/(magazine.max_bullets/10))
		icon_state = "osipr[bullets]0"

/obj/item/energy_magazine
	name = "energy magazine"
	desc = "Can be replenished by a recharger"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-magfull"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0
	var/bullets = 10
	var/max_bullets = 10
	var/caliber = "osipr"	//base icon name
	var/bullet_type = /obj/item/projectile/bullet/osipr

/obj/item/energy_magazine/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	update_icon()

/obj/item/energy_magazine/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [bullets] bullet\s remaining.</span>")

/obj/item/energy_magazine/update_icon()
	if(bullets == max_bullets)
		icon_state = "[caliber]-magfull"
	else
		icon_state = "[caliber]-mag"

/obj/item/energy_magazine/osipr
	name = "pulse magazine"
	desc = "Primary ammo for OSIPR. Can be replenished by a recharger."
	icon_state = "osipr-magfull"
	w_class = 3.0
	bullets = 30
	max_bullets = 30
	caliber = "osipr"
	bullet_type = /obj/item/projectile/bullet/osipr

#undef OSIPR_PRIMARY_FIRE
#undef OSIPR_SECONDARY_FIRE

/obj/item/osipr_core
	name = "dark energy core"
	desc = "Secondary ammo for OSIPR."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-core"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0

/obj/item/osipr_core/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/gun/projectile/rocketlauncher
	name = "rocket launcher"
	desc = "Ranged explosions, science marches on."
	fire_sound = 'sound/weapons/rocket.ogg'
	icon_state = "rpg"
	item_state = "rpg"
	max_shells = 1
	w_class = 4.0
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
	caliber = list("rpg" = 1)
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg"
	attack_verb = list("struck", "hit", "bashed")
	gun_flags = 0

/obj/item/weapon/gun/projectile/rocketlauncher/isHandgun()
	return 0

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
		return(BRUTELOSS)
	else //Needed to get that shitty default suicide_act out of the way
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, -1, 1, 4, 8)
			if(src) //Is the rocket launcher somehow still here ?
				qdel(src) //This never happened
			return(BRUTELOSS)
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita
	name = "\improper Nikita"
	desc = "A miniature cruise missile launcher. Using a pulsed rocket engine and sophisticated TV guidance system."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "nikita"
	item_state = null
	origin_tech = "materials=5;combat=6;programming=4"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	slot_flags = SLOT_BACK
	w_class = 4.0
	fire_delay = 2
	caliber = list("nikita" = 1)
	origin_tech = null
	fire_sound = 'sound/weapons/rocket.ogg'
	ammo_type = "/obj/item/ammo_casing/rocket_rpg/nikita"
	var/obj/item/projectile/nikita/fired = null
	var/emagged = 0

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/update_icon()
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/attack_self(mob/user)
	if(fired)
		playsound(get_turf(src), 'sound/weapons/stickybomb_det.ogg', 30, 1)
		fired.detonate()

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/suicide_act(var/mob/user)
	if(!loaded)
		user.visible_message("<span class='danger'>[user] jams down \the [src]'s trigger before noticing it isn't loaded and starts bashing \his head in with it! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)
	else
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, -1, 1, 4, 8)
			return(BRUTELOSS)
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
	caliber = "nikita"
	projectile_type = "/obj/item/projectile/nikita"

/obj/item/ammo_casing/rocket_rpg/nikita/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/gun/projectile/hecate
	name = "\improper PGM Hécate II"
	desc = "An Anti-Materiel Rifle. You can read \"Fabriqué en Haute-Savoie\" on the receiver. Whatever that means..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hecate"
	item_state = null
	origin_tech = "materials=5;combat=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 2
	slot_flags = SLOT_BACK
	fire_delay = 30
	w_class = 4.0
	fire_sound = 'sound/weapons/hecate_fire.ogg'
	caliber = list(".50BMG" = 1)
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_shells = 1
	load_method = 0
	slowdown = 10
	var/backup_view = 7

/obj/item/weapon/gun/projectile/hecate/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/hecate/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/projectile/hecate/update_wield(mob/user)
	if(wielded)
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_64x64.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_64x64.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			backup_view = C.view
			C.view = C.view * 2
	else
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.view = backup_view

/obj/item/weapon/gun/projectile/hecate/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

#define HI_EX "hi-EX"
#define RAPID "rapid"
#define FLARE "flare"
#define STUN "stun"
#define LASER "laser"

/obj/item/weapon/gun/lawgiver
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition."
	name = "lawgiver"
	icon_state = "lawgiver"
	item_state = "lawgiver"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = "combat=5;materials=5;engineering=5"
	w_class = 3.0
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	recoil = 0
	flags = HEAR | FPRINT
	var/obj/item/ammo_storage/magazine/stored_magazine = null
	var/obj/item/ammo_casing/chambered = null
	var/firing_mode = STUN
	fire_delay = 0
	var/projectile_type = "/obj/item/projectile/energy/electrode"
	fire_sound = 'sound/weapons/Taser.ogg'
	var/magazine = null
	var/dna_profile = null
	var/rapidFirecheck = 0
	var/rapidFirechamber = 0
	var/rapidFirestop = 0
	var/rapid_message = 0
	var/damage_multiplier = 1
	var/has_played_alert = 0

/obj/item/weapon/gun/lawgiver/New()
	..()
	magazine = new /obj/item/ammo_storage/magazine/lawgiver
	verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
	update_icon()

/obj/item/weapon/gun/lawgiver/GetVoice()
	var/the_name = "The [name]"
	return the_name

/obj/item/weapon/gun/lawgiver/equipped(M as mob, hand)
	update_icon()

/obj/item/weapon/gun/lawgiver/update_icon()
	overlays.len = 0
	if(magazine)
		item_state = "[initial(icon_state)]1"
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		var/image/magazine_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]Mag")
		var/image/ammo_overlay = null
		if(firing_mode == STUN && L.stuncharge)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.stuncharge/20]")
		if(firing_mode == LASER && L.lasercharge)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.lasercharge/20]")
		if(firing_mode == RAPID && L.rapid_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.rapid_ammo_count]")
		if(firing_mode == FLARE && L.flare_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.flare_ammo_count]")
		if(firing_mode == HI_EX && L.hi_ex_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.hi_ex_ammo_count]")
		overlays += magazine_overlay
		overlays += ammo_overlay
	else
		item_state = "[initial(icon_state)]0"

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		var/image/DNA_overlay = null
		if(H.l_hand == src || H.r_hand == src)
			if(dna_profile)
				if(dna_profile == H.dna.unique_enzymes)
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
				else
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")
				overlays += DNA_overlay
		H.update_inv_r_hand()
		H.update_inv_l_hand()


/obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample()
	set name = "Submit DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(!dna_profile)
		dna_profile = H.dna.unique_enzymes
		to_chat(usr, "<span class='notice'>You submit a DNA sample to \the [src].</span>")
		verbs += /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
		verbs -= /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample

/obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample()
	set name = "Erase DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			dna_profile = null
			to_chat(usr, "<span class='notice'>You erase the DNA profile from \the [src].</span>")
			verbs += /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample
			verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
		else
			self_destruct(H)

/obj/item/weapon/gun/lawgiver/proc/self_destruct(mob/user)
	var/req_access = list(access_security)
	if(can_access(user.GetAccess(),req_access))
		say("ERROR: DNA PROFILE DOES NOT MATCH")
		return
	say("UNAUTHORIZED ACCESS DETECTED")
	explosion(user, -1, 0, 2)
	qdel(src)

/obj/item/weapon/gun/lawgiver/proc/LoadMag(var/obj/item/ammo_storage/magazine/AM, var/mob/user)
	if(istype(AM, /obj/item/ammo_storage/magazine/lawgiver) && !magazine)
		if(user)
			if(user.drop_item(AM, src))
				to_chat(user, "<span class='notice'>You load the magazine into \the [src].</span>")
			else
				return

		magazine = AM
		AM.update_icon()
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/proc/RemoveMag(var/mob/user)
	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		L.loc = get_turf(src.loc)
		if(user)
			user.put_in_hands(L)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
		L.update_icon()
		magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker == loc && !speech.frequency && dna_profile)
		var/mob/living/carbon/human/H = loc
		if(dna_profile == H.dna.unique_enzymes)
			recoil = 0
			if((findtext(speech.message, "stun")) || (findtext(speech.message, "taser")))
				firing_mode = STUN
				fire_sound = 'sound/weapons/Taser.ogg'
				projectile_type = "/obj/item/projectile/energy/electrode"
				fire_delay = 0
				sleep(3)
				say("STUN")
			else if((findtext(speech.message, "laser")) || (findtext(speech.message, "lethal")) || (findtext(speech.message, "beam")))
				firing_mode = LASER
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				projectile_type = "/obj/item/projectile/beam/heavylaser"
				fire_delay = 5
				sleep(3)
				say("LASER")
			else if((findtext(speech.message, "rapid")) || (findtext(speech.message, "automatic")))
				firing_mode = RAPID
				fire_sound = 'sound/weapons/Gunshot_c20.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/lawgiver"
				fire_delay = 0
				rapid_message = 0
				recoil = 1
				sleep(3)
				say("RAPID FIRE")
			else if((findtext(speech.message, "flare")) || (findtext(speech.message, "incendiary")))
				firing_mode = FLARE
				fire_sound = 'sound/weapons/shotgun.ogg'
				projectile_type = "/obj/item/projectile/flare"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("FLARE")
			else if((findtext(speech.message, "hi ex")) || (findtext(speech.message, "hi-ex")) || (findtext(speech.message, "explosive")) || (findtext(speech.message, "rocket")))
				firing_mode = HI_EX
				fire_sound = 'sound/weapons/elecfire.ogg'
				projectile_type = "/obj/item/projectile/bullet/gyro"
				fire_delay = 4
				recoil = 1
				sleep(3)
				say("HI-EX")
			update_icon()

/obj/item/weapon/gun/lawgiver/proc/rapidFire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Burst fires don't work well except by calling Fire() multiple times
	rapidFirecheck = 1
	for (var/i = 1; i <= 3; i++)
		if(!rapidFirestop)
			Fire(target, user, params, reflex, struggle)
	rapidFirecheck = 0
	rapidFirechamber = 0
	rapidFirestop = 0
	rapid_message = 0

/obj/item/weapon/gun/lawgiver/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Overriding this due to introducing the DNA check, and the fact that the round is to be chambered only just before it is fired
	if(dna_profile)
		if(dna_profile != user.dna.unique_enzymes)
			self_destruct(user)
			return
	else
		click_empty(user)
		say("PLEASE REGISTER A DNA SAMPLE")
		return

	if(firing_mode == RAPID && !rapidFirecheck)
		rapidFire(target, user, params, reflex, struggle)
		return

	//Christ Almighty is there no OOP way to do this?
	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!")
		return

	if(firing_mode == RAPID && !rapidFirechamber)
		in_chamber = null
		if(!chamber_round())
			rapidFirestop = 1
			return click_empty(user)
		rapidFirechamber = 1

	else if(firing_mode == RAPID && rapidFirechamber)
		in_chamber = new projectile_type(src)

	else if(firing_mode != RAPID)
		in_chamber = null
		if(!chamber_round())
			return click_empty(user)

	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M_CLUMSY in M.mutations) && prob(50))
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return

	if (!user.IsAdvancedToolUser() || isMoMMI(user) || istype(user, /mob/living/carbon/monkey/diona))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (M_HULK in M.mutations)
			to_chat(M, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		if(user.dna && (user.dna.mutantrace == "adamantine" || user.dna.mutantrace=="coalgolem"))
			to_chat(user, "<span class='warning'>Your fat fingers don't fit in the trigger guard!</span>")
			return
		var/datum/organ/external/a_hand = H.get_active_hand_organ()
		if(!a_hand.can_use_advanced_tools())
			to_chat(user, "<span class='warning'>Your [a_hand] doesn't have the dexterity to do this!</span>")
			return

	in_chamber.damage *= damage_multiplier

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user))
		return

	if(!in_chamber)
		return
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user
	in_chamber.def_zone = user.zone_sel.selecting
	if(targloc == curloc)
		user.bullet_act(in_chamber)
		qdel(in_chamber)
		in_chamber = null
		update_icon()
		return

	if((firing_mode == RAPID && !rapid_message) || (firing_mode != RAPID)) //On rapid mode, only shake once per burst.
		if(recoil)
			spawn()
				shake_camera(user, recoil + 1, recoil)
			if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored )
				var/direction = get_dir(user,target)
				spawn()
					var/obj/B = user.locked_to
					var/movementdirection = turn(direction,180)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(1)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(1)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(1)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(2)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(2)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(3)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(3)
					B.Move(get_step(user,movementdirection), movementdirection)
					sleep(3)
					B.Move(get_step(user,movementdirection), movementdirection)
			if((istype(user.loc, /turf/space)) || (user.areaMaster.has_gravity == 0))
				user.inertia_dir = get_dir(target, user)
				step(user, user.inertia_dir)

	playsound(user, fire_sound, 50, 1)
	if(!rapid_message)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
		if(firing_mode == RAPID)
			rapid_message = 1

	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.delayNextAttack(fire_delay)
	in_chamber.silenced = silenced
	in_chamber.current = curloc
	in_chamber.OnFired()
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	in_chamber.inaccurate = (istype(user.locked_to, /obj/structure/bed/chair/vehicle))

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])

	spawn()
		if(in_chamber)
			in_chamber.process()
	sleep(1)
	in_chamber = null

	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

	if(firing_mode == RAPID)
		var/obj/item/ammo_casing/a12mm/A = new /obj/item/ammo_casing/a12mm(user.loc)
		A.BB = null
		A.update_icon()
	if(firing_mode == HI_EX)
		var/obj/item/ammo_casing/a75/A = new /obj/item/ammo_casing/a75(user.loc)
		A.BB = null
		A.update_icon()

/obj/item/weapon/gun/lawgiver/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		if(istype(M.wear_mask, /obj/item/clothing/mask/happy))
			to_chat(M, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
			return
		mouthshoot = 1
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!do_after(user,src, 40))
			M.visible_message("<span class='notice'>[user] decided life was worth living</span>")
			mouthshoot = 0
			return
		if(dna_profile)
			if(dna_profile != user.dna.unique_enzymes)
				self_destruct(user)
				return
		else
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			click_empty(user)
			say("PLEASE REGISTER A DNA SAMPLE")
			return
		if (chamber_round())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			playsound(user, fire_sound, 50, 1)
			in_chamber.on_hit(M)
			if (!in_chamber.nodamage)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
				user.stat=2 // Just to be sure
				user.death()
			else
				to_chat(user, "<span class = 'notice'>Ow...</span>")
				user.apply_effect(110,AGONY,0)
			qdel(in_chamber)
			in_chamber = null
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (can_shoot())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
			damage_multiplier = 1.3
			src.Fire(M,user,0,0,1)
			damage_multiplier = 1
			return
		else if(target && M in target)
			src.Fire(M,user,0,0,1)
			return
		else
			return ..()
	else
		return ..()

/obj/item/weapon/gun/lawgiver/proc/chamber_round()
	if(in_chamber || !magazine)
		return 0
	else
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		switch(firing_mode)
			if(STUN)
				if(L.stuncharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.stuncharge -= 20
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.lasercharge -= 20
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.rapid_ammo_count -= 1
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.flare_ammo_count -= 1
					return 1
				else
					return 0
			if(HI_EX)
				if(L.hi_ex_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					in_chamber = new projectile_type(src)
					L.hi_ex_ammo_count -= 1
					return 1
				else
					return 0
	return 0

/obj/item/weapon/gun/lawgiver/proc/can_shoot() //Only made so that firing point-blank can run its checks without chambering a round, since rounds are chambered in Fire()
	if(!magazine)
		return 0
	else
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		switch(firing_mode)
			if(STUN)
				if(L.stuncharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
			if(HI_EX)
				if(L.hi_ex_ammo_count >= 1)
					if(in_chamber)	return 1
					if(!projectile_type)	return 0
					return 1
				else
					return 0
	return 0

/obj/item/weapon/gun/lawgiver/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_storage/magazine/lawgiver))
		var/obj/item/ammo_storage/magazine/lawgiver/AM = A
		if(!magazine)
			LoadMag(AM, user)
		else
			to_chat(user, "<span class='rose'>There is already a magazine loaded in \the [src]!</span>")
	else if (istype(A, /obj/item/ammo_storage/magazine))
		to_chat(user, "<span class='rose'>You can't load \the [src] with that kind of magazine!</span>")

/obj/item/weapon/gun/lawgiver/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (magazine)
		RemoveMag(user)
	else
		to_chat(user, "<span class='warning'>There's no magazine loaded in \the [src]!</span>")

/obj/item/weapon/gun/lawgiver/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, struggle = 0)
	..()
	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		if(magazine && !countAmmo(L) && !has_played_alert)
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			has_played_alert = 1
	return

/obj/item/weapon/gun/lawgiver/examine(mob/user)
	..()
	getAmmo(user)

/obj/item/weapon/gun/lawgiver/proc/getAmmo(mob/user)
	if (magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		to_chat(user, "<span class='info'>It has enough energy for [L.stuncharge/20] stun shot\s left.</span>")
		to_chat(user, "<span class='info'>It has enough energy for [L.lasercharge/20] laser shot\s left.</span>")
		to_chat(user, "<span class='info'>It has [L.rapid_ammo_count] rapid fire round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.flare_ammo_count] flare round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.hi_ex_ammo_count] hi-EX round\s remaining.</span>")

/obj/item/weapon/gun/lawgiver/proc/countAmmo(var/obj/item/A)
	var/obj/item/ammo_storage/magazine/lawgiver/L = A
	if (L.stuncharge == 0 && L.lasercharge == 0 && L.rapid_ammo_count == 0 && L.flare_ammo_count == 0 && L.hi_ex_ammo_count == 0)
		return 0
	else
		has_played_alert = 0
		return 1

#undef HI_EX
#undef RAPID
#undef FLARE
#undef STUN
#undef LASER

#define MAX_STICKYBOMBS 4

/obj/item/weapon/gun/stickybomb
	name = "stickybomb launcher"
	desc = "Fired stickybombs take 5 seconds to become live. After which they'll progressively merge with their surroundings."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "stickybomb"
	item_state = null
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;combat=4;programming=3"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	w_class = 3.0
	fire_delay = 2
	fire_sound = 'sound/weapons/grenadelauncher.ogg'
	var/list/loaded = list()
	var/list/fired = list()

	var/current_shells = 200

/obj/item/weapon/gun/stickybomb/isHandgun()
	return 0

/obj/item/weapon/gun/stickybomb/New()
	..()
	loaded = list(
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		)

/obj/item/weapon/gun/stickybomb/Destroy()
	for(var/obj/item/stickybomb/S in loaded)
		qdel(S)
	loaded = null
	for(var/obj/item/stickybomb/B in fired)
		B.deactivate()
		B.unstick()
	..()

/obj/item/weapon/gun/stickybomb/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [loaded.len] stickybomb\s loaded, and [fired.len] stickybomb\s placed.</span>")

/obj/item/weapon/gun/stickybomb/update_icon()
	return

/obj/item/weapon/gun/stickybomb/attack_self(mob/user)
	if(fired.len)
		playsound(get_turf(src), 'sound/weapons/stickybomb_det.ogg', 30, 1)
		for(var/obj/item/stickybomb/B in fired)
			spawn()
				if(B.live)
					B.detonate()

/obj/item/weapon/gun/stickybomb/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/stickybomb))
		var/obj/item/stickybomb/B = A
		if(B.live)
			to_chat(user, "<span class='warning'>You cannot load a live stickybomb!</span>")
		else
			if(loaded.len >= 6)
				to_chat(user, "<span class='warning'>You cannot fit any more stickybombs in there!</span>")
			else
				if(user.drop_item(A, src))
					to_chat(user, "<span class='notice'>You load \the [A] into \the [src].</span>")
					loaded += A
	else
		..()

/obj/item/weapon/gun/stickybomb/process_chambered()
	if(in_chamber) return 1
	if(loaded.len)
		var/obj/item/stickybomb/B = pick(loaded)
		loaded -= B
		if(fired.len >= MAX_STICKYBOMBS)
			var/obj/item/stickybomb/SB = pick(fired)
			spawn()
				SB.detonate()
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>One of the stickybombs detonates to leave room for the next one.</span>")
		fired += B
		var/obj/item/projectile/stickybomb/SB = new()
		SB.sticky = B
		B.fired_from = src
		B.loc = SB
		in_chamber = SB
		return 1
	return 0


/obj/item/stickybomb
	name = "anti-personnel stickybomb"
	desc = "Ammo for a stickybomb launcher. Only affects living beings, produces a decent amount of knockback."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "stickybomb"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 1.0
	var/obj/item/weapon/gun/stickybomb/fired_from = null
	var/live = 0
	var/atom/stuck_to = null
	var/image/self_overlay = null
	var/signal = 0

/obj/item/stickybomb/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/stickybomb/Destroy()
	if(fired_from)
		fired_from.fired -= src
		fired_from = null
	stuck_to = null
	self_overlay = null
	..()

/obj/item/stickybomb/update_icon()
	icon_state = "[initial(icon_state)][live ? "-live" : ""]"
	if(live)
		desc = "It appears to be live."
	else
		desc = "Ammo for a stickybomb launcher."

/obj/item/stickybomb/pickup(mob/user)
	if(stuck_to)
		to_chat(user, "<span class='warning'>You reach for \the [src] stuck on \the [stuck_to] and start pulling.</span>")
		if(do_after(user, src, 30))
			to_chat(user, "<span class='warning'>It came off!</span>")
			unstick()
			..()
	else
		..()

/obj/item/stickybomb/proc/stick_to(var/atom/A as mob|obj|turf, var/side = null)
	stuck_to = A
	loc = A
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	playsound(A, 'sound/items/metal_impact.ogg', 30, 1)

	if(isturf(A))
		anchored = 1
		switch(side)
			if(NORTH)
				pixel_y = 16
			if(SOUTH)
				pixel_y = -16
			if(EAST)
				pixel_x = 16
			if(WEST)
				pixel_x = -16
		sleep(50)
		if(stuck_to == A)
			flick("stickybomb_flick",src)
			live = 1
			update_icon()
			animate(src, alpha=50, time=300)

	else if(isliving(A))
		visible_message("<span class='warning'>\the [src] sticks itself on \the [A].</span>")
		src.loc = A
		self_overlay = new(icon,src,icon_state,10,dir)
		self_overlay.pixel_x = pixel_x
		self_overlay.pixel_y = pixel_y
		A.overlays += self_overlay
		sleep(50)
		if(stuck_to == A)
			live = 1
			A.overlays -= self_overlay
			self_overlay.icon_state = "stickybomb-live"
			A.overlays += self_overlay

/obj/item/stickybomb/proc/unstick(var/fall_to_floor = 1)
	if(ismob(stuck_to))
		stuck_to.overlays -= self_overlay
		icon_state = self_overlay.icon_state
		if(fall_to_floor)
			src.loc = get_turf(src)
	stuck_to = null
	anchored = 0
	alpha = 255
	pixel_x = 0
	pixel_y = 0

/obj/item/stickybomb/proc/detonate()
	icon_state = "stickybomb_flick"
	if(!self_overlay)
		self_overlay = new(icon,src,icon_state,13,dir)
		overlays += self_overlay//a bit awkward but the sprite wouldn't properly animate otherwise
	if(signal)
		return
	signal = 1
	mouse_opacity = 0
	var/turf/T = get_turf(src)
	playsound(T, 'sound/machines/twobeep.ogg', 30, 1)
	if(ismob(stuck_to))
		stuck_to.overlays -= self_overlay
		self_overlay.icon_state = "stickybomb_flick"
		self_overlay.layer = 13
		stuck_to.overlays += self_overlay
	alpha = 255
	spawn(3)
		if(ismob(stuck_to))
			stuck_to.overlays -= self_overlay

		T.turf_animation('icons/effects/96x96.dmi',"explosion_sticky",pixel_x-32, pixel_y-32, 13)
		playsound(T, "explosion_small", 75, 1)

		for(var/mob/living/L in range(T,3))
			var/turf/TL = get_turf(L)
			var/dist = get_dist(T,L)
			var/atom/throw_target = T
			if(T!=TL)
				throw_target = get_edge_target_turf(T, get_dir(T,TL))
			switch(dist)
				if(0 to 1)
					L.ex_act(3)//ex_act(2) would deal too much damage
					L.ex_act(3)
					spawn(1)//to give time for the other bombs to calculate their damage.
						L.throw_at(throw_target, 2, 3)
				if(1 to 2)
					L.ex_act(3,TRUE)
					spawn(1)
						L.throw_at(throw_target, 1, 1)
				if(2 to 3)
					L.ex_act(3,TRUE)
		qdel(src)

/obj/item/stickybomb/proc/deactivate()
	live = 0
	if(fired_from)
		fired_from.fired -= src
		fired_from = null
	update_icon()
	alpha = 255
	unstick()

/obj/item/stickybomb/emp_act(severity)
	deactivate()
	unstick()

/obj/item/stickybomb/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			detonate()

#undef MAX_STICKYBOMBS

/obj/item/weapon/gun/hookshot	//-by Deity Link
	name = "hookshot"
	desc = "Used to create tethers! It's a very experimental device, recently developped by Nanotrasen."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hookshot"
	item_state = "hookshot"
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;engineering=3;magnets=2"
	mech_flags = null // So it can be scanned by the Device Analyser
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = 3.0
	fire_delay = 0
	fire_sound = 'sound/weapons/hookshot_fire.ogg'
	var/maxlength = 14
	var/obj/item/projectile/hookshot/hook = null
	var/list/links = list()
	var/datum/chain/chain_datum = null
	var/rewinding = 0	//rewinding just means dragging the chain back into the gun.
	var/clockwerk = 0	//clockwerk means "pulling yourself to the target".
	var/mob/living/carbon/firer = null
	var/atom/movable/extremity = null
	var/panic = 0	//set to 1 by a part of the hookchain that got destroyed.

/obj/item/weapon/gun/hookshot/update_icon()
	if(hook || chain_datum)
		icon_state = "hookshot0"
		item_state = "hookshot0"
	else
		icon_state = "hookshot"
		item_state = "hookshot"
	if(istype(loc,/mob))
		var/mob/M = loc
		M.regenerate_icons()

/obj/item/weapon/gun/hookshot/New()
	..()
	for(var/i = 0;i <= maxlength; i++)
		var/obj/effect/overlay/hookchain/HC = new(src)
		HC.shot_from = src
		links["[i]"] = HC

/obj/item/weapon/gun/hookshot/Destroy()//if a single link of the chain is destroyed, the rest of the chain is instantly destroyed as well.
	if(chain_datum)
		chain_datum.Delete_Chain()

	for(var/i = 0;i <= maxlength; i++)
		var/obj/effect/overlay/hookchain/HC = links["[i]"]
		qdel(HC)
		links["[i]"] = null
	..()

/obj/item/weapon/gun/hookshot/attack_self(mob/user)//clicking on the hookshot while tethered rewinds the chain without pulling the target.
	if(check_tether())
		var/atom/movable/AM = chain_datum.extremity_B
		if(AM)
			AM.tether = null
		chain_datum.extremity_B = null
		chain_datum.rewind_chain()

/obj/item/weapon/gun/hookshot/process_chambered()
	if(in_chamber)
		return 1

	if(panic)//if a part of the chain got deleted, we recreate it.
		for(var/i = 0;i <= maxlength; i++)
			var/obj/effect/overlay/hookchain/HC = links["[i]"]
			if(!HC)
				HC = new(src)
				HC.shot_from = src
				links["[i]"] = HC
			else
				HC.loc = src
		panic = 0

	if(!hook && !rewinding && !clockwerk && !check_tether())//if there is no projectile already, and we aren't currently rewinding the chain, or reeling in toward a target,
		hook = new/obj/item/projectile/hookshot(src)		//and that the hookshot isn't currently sustaining a tether, then we can fire.
		in_chamber = hook
		firer = loc
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/hookshot/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)//clicking anywhere reels the target to the player.
	if(flag)	return //we're placing gun on a table or in backpack
	if(check_tether())
		if(istype(chain_datum.extremity_B,/mob/living/carbon))
			var/mob/living/carbon/C = chain_datum.extremity_B
			to_chat(C, "<span class='warning'>\The [src] reels you in!</span>")
		chain_datum.rewind_chain()
		return
	..()

/obj/item/weapon/gun/hookshot/dropped(mob/user as mob)
	if(!clockwerk && !rewinding)
		rewind_chain()

	if(user.tether)
		var/datum/chain/tether_datum = user.tether.chain_datum
		if(tether_datum == chain_datum)
			spawn(1)	//so we give time for the gun to be moved on the table or inside a container
				if(isturf(loc))					//if we place the gun on the floor or a table, it becomes the new extremity of the chain
					user.tether = null
					chain_datum.extremity_A = src
					var/obj/effect/overlay/chain/C = chain_datum.links["1"]
					C.extremity_A = src
					C.follow(src,get_step(loc,get_dir(loc,C)))
					src.tether = C
				else							//else we simply rewind the chain
					var/atom/movable/AM = chain_datum.extremity_B
					if(AM)
						AM.tether = null
					chain_datum.extremity_B = null
					chain_datum.rewind_chain()
	..()

/obj/item/weapon/gun/hookshot/attack_hand(mob/user)
	if(chain_datum && (chain_datum.extremity_A == src))
		if(user.tether)
			return//we cannot pick up a hookshot that is part of a tether if we are part of a different tether ourselves (for now)
		else
			var/obj/effect/overlay/chain/C = src.tether
			C.extremity_A = user
			user.tether = C
			chain_datum.extremity_A = user
			C.follow(user,get_step(user,get_dir(user,C)))
			src.tether = null
	..()

/obj/item/weapon/gun/hookshot/proc/check_tether()//checking whether the hookshot is currently sustaining a tether with its user as the base
	if(chain_datum && istype(loc,/mob/living))
		var/mob/living/L = loc
		if(L.tether)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum == chain_datum)
				return 1
	return 0

/obj/item/weapon/gun/hookshot/proc/rewind_chain()//brings the links back toward the player
	if(rewinding)
		return
	rewinding = 1
	for(var/j = 1; j <= maxlength; j++)
		var/pause = 0
		for(var/i = maxlength; i > 0; i--)
			var/obj/effect/overlay/hookchain/HC = links["[i]"]
			if(!HC)
				cancel_chain()
				return
			if(HC.loc == src)
				continue
			pause = 1
			var/obj/effect/overlay/hookchain/HC0 = links["[i-1]"]
			if(!HC0)
				cancel_chain()
				return
			HC.loc = HC0.loc
			HC.pixel_x = HC0.pixel_x
			HC.pixel_y = HC0.pixel_y
		sleep(pause)
	rewinding = 0
	update_icon()

/obj/item/weapon/gun/hookshot/proc/cancel_chain()//instantly sends all the links back into the hookshot. replaces those that got destroyed.
	for(var/j = 1; j <= maxlength; j++)
		var/obj/effect/overlay/hookchain/HC = links["[j]"]
		if(HC)
			HC.loc = src
		else
			HC = new(src)
			HC.shot_from = src
			links["[j]"] = HC
	rewinding = 0
	clockwerk = 0
	update_icon()

/obj/item/weapon/gun/hookshot/proc/clockwerk_chain(var/length)//reel the player toward his target
	if(clockwerk)
		return
	clockwerk = 1
	for(var/i = 1;i <= length;i++)
		var/obj/effect/overlay/hookchain/HC = links["[i]"]
		if(!isturf(HC.loc) || (loc != firer))
			cancel_chain()
			break
		var/turf/oldLoc = firer.loc
		var/bckp = firer.pass_flags
		firer.pass_flags = PASSTABLE
		firer.Move(HC.loc,get_dir(firer,HC.loc))
		firer.pass_flags = bckp
		if(firer.loc == oldLoc)//we're bumping into something, abort!
			clockwerk = 0
			rewind_chain()
			return
		HC.loc = src
		sleep(1)
	clockwerk = 0
	update_icon()

//this datum contains all the data about a tether. It's extremities, which hookshot spawned it, and the list of all of its links.
/datum/chain
	var/list/links = list()
	var/atom/movable/extremity_A = null
	var/atom/movable/extremity_B = null
	var/obj/item/weapon/gun/hookshot/hookshot = null
	var/undergoing_deletion = 0
	var/snap = 0
	var/rewinding = 0

/datum/chain/New()
	spawn(20)
		process()

/datum/chain/proc/process()//checking every 2 seconds if the links are still adjacent to each others, if not, break the tether.
	while(!undergoing_deletion)
		if(!Check_Integrity())
			snap = 1
			Delete_Chain()
		sleep(20)

/datum/chain/proc/Check_Integrity()
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C = links["[i]"]
		if(!C.rewinding && ((get_dist(C,C.extremity_A) > 1) || (get_dist(C,C.extremity_B) > 1)))
			return 0
	return 1

/datum/chain/proc/Delete_Chain()
	if(undergoing_deletion)
		return
	undergoing_deletion = 1
	if(extremity_A)
		if(snap)
			extremity_A.visible_message("The chain snaps and let go of \the [extremity_A]")
		extremity_A.tether = null
	if(extremity_B)
		if(snap)
			extremity_B.visible_message("The chain snaps and let go of \the [extremity_B]")
		extremity_B.tether = null
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C = links["[i]"]
		qdel(C)
	if(hookshot)
		hookshot.chain_datum = null
		hookshot.update_icon()

/datum/chain/proc/rewind_chain()
	rewinding = 1
	if(!extremity_A.tether)
		Delete_Chain()
		return
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C1 = extremity_A.tether
		if(!C1)
			break
		var/obj/effect/overlay/chain/C2 = C1.extremity_B
		if(!C2)
			break

		if(istype(C2))
			var/turf/T = C1.loc
			C1.loc = extremity_A.loc
			C2.follow(C1,T)
			C2.extremity_A = extremity_A
			C2.update_overlays(C1)
			extremity_A.tether = C2
		else if(extremity_B)
			if(extremity_B.anchored)
				extremity_B.tether = null
				C1.extremity_B = null
				extremity_B = null
			else
				var/turf/U = C1.loc
				if(U && U.Enter(C2,C2.loc))//if we cannot pull the target through the turf, we just let him go.
					C2.loc = C1.loc
				else
					extremity_B.tether = null
					extremity_B = null
					C1.extremity_B = null

				if(istype(extremity_A,/mob/living))
					var/mob/living/L = extremity_A
					C2.CtrlClick(L)
		C1.rewinding = 1
		qdel(C1)
		sleep(1)

	Delete_Chain()

//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain
	name = "hookshot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hookshot_chain"
	animate_movement = 0
	var/obj/item/weapon/gun/hookshot/shot_from = null

/obj/effect/overlay/hookchain/Destroy()
	if(shot_from)
		shot_from.panic = 1
		shot_from = null
	..()

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain
	name = "chain"
	icon = 'icons/obj/chain.dmi'
	icon_state = ""
	animate_movement = 0
	var/atom/movable/extremity_A = null
	var/atom/movable/extremity_B = null
	var/datum/chain/chain_datum = null
	var/rewinding = 0

/obj/effect/overlay/chain/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1

/obj/effect/overlay/chain/update_icon()
	overlays.len = 0
	if(extremity_A && (loc != extremity_A.loc))
		overlays += image(icon,src,"chain",MOB_LAYER-0.1,get_dir(src,extremity_A))
	if(extremity_B && (loc != extremity_B.loc))
		overlays += image(icon,src,"chain",MOB_LAYER-0.1,get_dir(src,extremity_B))

/obj/effect/overlay/chain/proc/update_overlays(var/obj/effect/overlay/chain/C)
	var/obj/effect/overlay/chain/C1 = extremity_A
	var/obj/effect/overlay/chain/C2 = extremity_B
	update_icon()
	if(istype(C2) && ((!C && !istype(C1)) || ((C == C1) && istype(C1))))
		C2.update_overlays(src)
	else if(istype(C1) && ((!C && !istype(C2)) || ((C == C2) && istype(C2))))
		C1.update_overlays(src)

/obj/effect/overlay/chain/attempt_to_follow(var/atom/movable/A,var/turf/T)
	if(get_dist(T,loc) <= 1)
		return 1
	else
		if(A == extremity_A)
			return extremity_B.attempt_to_follow(src, A.loc)
		else if(A == extremity_B)
			return extremity_A.attempt_to_follow(src, A.loc)

/obj/effect/overlay/chain/Move(newLoc,Dir=0,step_x=0,step_y=0)//for when someone pulls a part the chain.
	var/turf/T = loc
	if(..())
		var/obj/effect/overlay/chain/CA = extremity_A
		var/obj/effect/overlay/chain/CB = extremity_B
		if(istype(CA))
			CA.follow(src,T)
			CA.update_overlays(src)
		else if(get_dist(loc,CA.loc) > 1)
			CA.tether_pull = 1
			CA.Move(T, get_dir(CA, T))
			CA.tether_pull = 0
		if(istype(CB))
			CB.follow(src,T)
			CB.update_overlays(src)
		else if(get_dist(loc,CB.loc) > 1)
			CB.tether_pull = 1
			CB.Move(T, get_dir(CB, T))
			CB.tether_pull = 0

	if(!chain_datum.Check_Integrity())
		chain_datum.snap = 1
		chain_datum.Delete_Chain()

/obj/effect/overlay/chain/proc/follow(var/atom/movable/A,var/turf/T)//this proc is called by links of the chain each time they get pulled, so they pull the rest of the chain.
	var/turf/U = get_turf(A)
	if(!T || !loc || (T.z != loc.z))
		chain_datum.Delete_Chain()
		return

	var/turf/R = loc

	if(get_dist(U,loc) <= 1)
		if(A == extremity_A)
			var/obj/effect/overlay/chain/C = extremity_A
			if(istype(C))
				C.update_overlays(src)
		else if(A == extremity_B)
			var/obj/effect/overlay/chain/C = extremity_B
			if(istype(C))
				C.update_overlays(src)
		update_icon()
		return

	forceMove(T, get_dir(src, T))

	if(A == extremity_A)//depending on which side is pulling the link, we'll pull the other side.
		var/obj/effect/overlay/chain/CH = extremity_B
		if(istype(CH))
			CH.follow(src,R)
		else
			if(!chain_datum.extremity_B)//for when we pull back the chain into the hookshot without pulling the other extremity
				CH = null
				extremity_B = null
			var/obj/effect/overlay/chain/C = extremity_A
			if(istype(C))
				C.update_overlays(src)
			if(CH && (get_dist(loc,CH.loc) > 1))
				var/turf/oldLoc = CH.loc
				CH.tether_pull = 1
				var/pass_backup = CH.pass_flags
				if(chain_datum.rewinding && (istype(CH,/mob/living) || istype(CH,/obj/item)))
					CH.pass_flags = PASSTABLE//mobs can be pulled above tables
				CH.Move(R, get_dir(CH, R))
				CH.pass_flags = pass_backup
				CH.tether_pull = 0
				if(CH.loc == oldLoc)
					CH.tether = null
					extremity_B = null
					chain_datum.extremity_B = null
		update_icon()

	else if(A == extremity_B)
		var/obj/effect/overlay/chain/CH = extremity_A
		if(istype(CH))
			CH.follow(src,R)
		else
			var/obj/effect/overlay/chain/C = extremity_B
			if(istype(C))
				C.update_overlays(src)
			if(CH && (get_dist(loc,CH.loc) > 1))
				CH.tether_pull = 1
				CH.Move(R, get_dir(CH, R))
				CH.tether_pull = 0
		update_icon()

/obj/effect/overlay/chain/Destroy()
	if(chain_datum)
		chain_datum.links -= src
	if(!rewinding)
		chain_datum.snap = 1
		chain_datum.Delete_Chain()
	..()

/obj/item/weapon/gun/gravitywell	//-by Deity Link
	name = "\improper Gravity Well Gun"
	desc = "Whoever created that gun had a taste for organized chaos..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "gravitywell"
	item_state = "gravitywell"
	slot_flags = SLOT_BELT
	origin_tech = "materials=7;bluespace=5;magnets=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = 3.0
	fire_delay = 0
	fire_sound = 'sound/weapons/wave.ogg'
	var/charge = 100
	var/maxcharge = 100//admins can varedit this var to 0 to allow the gun to fire non-stop. I decline all responsibilities for lag-induced server crashes caused by gravity wells spam.

/obj/item/weapon/gun/gravitywell/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Charge = [charge]%</span>")

/obj/item/weapon/gun/gravitywell/Destroy()
	if(charge < maxcharge)
		processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/gravitywell/process_chambered()
	if(in_chamber) return 1
	if(charge >= maxcharge)
		charge = 0
		update_icon()
		in_chamber = new/obj/item/projectile/gravitywell()
		processing_objects.Add(src)
		return 1
	return 0

/obj/item/weapon/gun/gravitywell/process()//it takes 100 seconds to recharge and be able to fire again
	charge = min(maxcharge,charge+1)
	if(charge >= maxcharge)
		update_icon()
		if(istype(loc,/mob))
			var/mob/M = loc
			M.regenerate_icons()
		processing_objects.Remove(src)
	return 1

/obj/item/weapon/gun/gravitywell/update_icon()
	if(charge == maxcharge)
		icon_state = "gravitywell"
		item_state = "gravitywell"
	else
		icon_state = "gravitywell0"
		item_state = "gravitywell0"


