#define RICOCHET "ricochet"
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
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=5;" + Tc_ENGINEERING + "=5"
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	recoil = 0
	flags = HEAR | FPRINT
	var/obj/item/ammo_storage/magazine/stored_magazine = null
	var/firing_mode = STUN
	fire_delay = 0
	var/projectile_type = "/obj/item/projectile/energy/electrode"
	fire_sound = 'sound/weapons/Taser.ogg'
	var/magazine = null
	var/dna_profile = null
	var/rapidFirecheck = 0
	var/damage_multiplier = 1
	var/has_played_alert = 0

/obj/item/weapon/gun/lawgiver/isHandgun()
	return TRUE

/obj/item/weapon/gun/lawgiver/New()
	..()
	if(istype(src, /obj/item/weapon/gun/lawgiver/demolition))
		magazine = new /obj/item/ammo_storage/magazine/lawgiver/demolition(src)
	else
		magazine = new /obj/item/ammo_storage/magazine/lawgiver(src)
	verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
	update_icon()

/obj/item/weapon/gun/lawgiver/Destroy()
	if(magazine)
		qdel(magazine)
		magazine = null
	if(in_chamber)
		qdel(in_chamber)
		in_chamber = null
	..()

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
		if(firing_mode == RICOCHET && L.ricochet_ammo_count)
			ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][L.ricochet_ammo_count]")
		overlays += magazine_overlay
		overlays += ammo_overlay
	else
		item_state = "[initial(icon_state)]0"

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		var/image/DNA_overlay = null
		if(H.is_holding_item(src))
			if(dna_profile)
				if(dna_profile == H.dna.unique_enzymes)
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
				else
					DNA_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")
				overlays += DNA_overlay
		H.update_inv_hands()


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
		update_icon()
		return 1

/obj/item/weapon/gun/lawgiver/AltClick()
	if(submit_DNA_sample())
		return
	return ..()

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
			update_icon()
		else
			self_destruct(H)

/obj/item/weapon/gun/lawgiver/proc/self_destruct(mob/user)
	var/req_access = list(access_security)
	if(can_access(user.GetAccess(),req_access))
		say("ERROR: DNA PROFILE DOES NOT MATCH.")
		return
	say("UNAUTHORIZED ACCESS DETECTED.")
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
		L.forceMove(get_turf(src.loc))
		if(user)
			user.put_in_hands(L)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src].</span>")
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
				say("STUN.")
			else if((findtext(speech.message, "laser")) || (findtext(speech.message, "lethal")) || (findtext(speech.message, "beam")))
				firing_mode = LASER
				fire_sound = 'sound/weapons/Laser.ogg'
				projectile_type = "/obj/item/projectile/beam"
				fire_delay = 5
				sleep(3)
				say("LASER.")
			else if((findtext(speech.message, "rapid")) || (findtext(speech.message, "automatic")))
				firing_mode = RAPID
				fire_sound = 'sound/weapons/Gunshot_c20.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/lawgiver"
				fire_delay = 0
				recoil = 1
				sleep(3)
				say("RAPID FIRE.")
			else if((findtext(speech.message, "flare")) || (findtext(speech.message, "incendiary")))
				firing_mode = FLARE
				fire_sound = 'sound/weapons/shotgun.ogg'
				projectile_type = "/obj/item/projectile/flare"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("FLARE.")
			else if((findtext(speech.message, "ricochet")) || (findtext(speech.message, "bounce")))
				firing_mode = RICOCHET
				fire_sound = 'sound/weapons/gatling_fire.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/bouncebullet/lawgiver"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("RICOCHET.")
			update_icon()

/obj/item/weapon/gun/lawgiver/process_chambered()
	return 1

/obj/item/weapon/gun/lawgiver/proc/rapidFire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, struggle = 0) //Burst fires don't work well except by calling Fire() multiple times
	rapidFirecheck = 1
	recoil = 1
	for (var/i = 1; i <= 3; i++)
		if(i>1 && !in_chamber)
			in_chamber = new projectile_type(src)
		Fire(target, user, params, struggle)
		recoil = 0
		silenced = 1
		fire_volume *= 5
	recoil = 1
	silenced = 0
	fire_volume /= 5
	rapidFirecheck = 0

/obj/item/weapon/gun/lawgiver/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Overriding this due to introducing the DNA check, and the fact that the round is to be chambered only just before it is fired
	..()

	if(firing_mode == RAPID)
		var/obj/item/ammo_casing/a12mm/A = new /obj/item/ammo_casing/a12mm(user.loc)
		A.BB = null
		A.update_icon()
	if(firing_mode == RICOCHET)
		var/obj/item/ammo_casing/a12mm/bounce/A = new /obj/item/ammo_casing/a12mm/bounce(user.loc)
		A.BB = null
		A.update_icon()
	if(istype(src, /obj/item/weapon/gun/lawgiver/demolition) && firing_mode == FLARE)
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
			say("PLEASE REGISTER A DNA SAMPLE.")
			return
		if (chamber_round())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			playsound(user, fire_sound, 50, 1)
			in_chamber.on_hit(M)
			if (!in_chamber.nodamage)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, LIMB_HEAD, used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
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
		if(user.a_intent == I_HURT || (target && M in target))
			if(dna_profile)
				if(dna_profile != user.dna.unique_enzymes)
					self_destruct(user)
					return
			else
				click_empty(user)
				say("PLEASE REGISTER A DNA SAMPLE.")
				return
			if(user.a_intent == I_HURT)
				if(chamber_round())
					user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
					damage_multiplier = 1.3
					src.Fire(M,user,0,0,1)
					damage_multiplier = 1
				return
			else
				if(chamber_round())
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
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					in_chamber = new projectile_type(src)
					L.stuncharge -= 20
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					in_chamber = new projectile_type(src)
					L.lasercharge -= 20
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					in_chamber = new projectile_type(src)
					L.rapid_ammo_count -= 1
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					in_chamber = new projectile_type(src)
					L.flare_ammo_count -= 1
					return 1
				else
					return 0
			if(RICOCHET)
				if(L.ricochet_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					in_chamber = new projectile_type(src)
					L.ricochet_ammo_count -= 1
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
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					return 1
				else
					return 0
			if(LASER)
				if(L.lasercharge >= 20)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					return 1
				else
					return 0
			if(RAPID)
				if(L.rapid_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					return 1
				else
					return 0
			if(FLARE)
				if(L.flare_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					return 1
				else
					return 0
			if(RICOCHET)
				if(L.ricochet_ammo_count >= 1)
					if(in_chamber)
						return 1
					if(!projectile_type)
						return 0
					return 1
				else
					return 0
	return 0

/obj/item/weapon/gun/lawgiver/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/ammo_storage/magazine/lawgiver))
		if(!check_mag_type(A, user))
			return
		var/obj/item/ammo_storage/magazine/lawgiver/AM = A
		if(!magazine)
			LoadMag(AM, user)
		else
			to_chat(user, "<span class='warning'>There is already a magazine loaded in \the [src]!</span>")
	else if (istype(A, /obj/item/ammo_storage/magazine))
		to_chat(user, "<span class='warning'>You can't load \the [src] with that kind of magazine!</span>")

/obj/item/weapon/gun/lawgiver/proc/check_mag_type(obj/item/I, mob/user)
	if(istype(I, /obj/item/ammo_storage/magazine/lawgiver/demolition))
		to_chat(user, "<span class='warning'>You can't load a demolition-model magazine into this [src.name]!</span>")
		return 0
	return 1

/obj/item/weapon/gun/lawgiver/attack_self(mob/user as mob)
	if (target)
		return ..()
	if (magazine)
		RemoveMag(user)
	else
		to_chat(user, "<span class='warning'>There's no magazine loaded in \the [src]!</span>")

/obj/item/weapon/gun/lawgiver/special_check()
	if(world.time >= last_fired + fire_delay)
		return 1
	else
		return 0

/obj/item/weapon/gun/lawgiver/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(istype(A, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
		return//Shouldnt flag take care of this?

	if(dna_profile)
		if(dna_profile != user.dna.unique_enzymes)
			self_destruct(user)
			return
	else
		click_empty(user)
		say("PLEASE REGISTER A DNA SAMPLE.")
		return

	if(in_chamber)
		qdel(in_chamber)
		in_chamber = null
	if(!special_check())
		return
	if(!chamber_round())
		return click_empty(user)

	in_chamber.damage *= damage_multiplier

	if(firing_mode == RAPID && !rapidFirecheck)
		rapidFire(A, user, params, struggle)
		return

	else if(firing_mode == RAPID && rapidFirecheck)
		return

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params, "struggle" = struggle) //Otherwise, fire normally.

	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		if(!countAmmo(L) && !has_played_alert)
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			has_played_alert = 1
			return

/obj/item/weapon/gun/lawgiver/examine(mob/user)
	..()
	getAmmo(user)

/obj/item/weapon/gun/lawgiver/proc/getAmmo(mob/user)
	if(magazine)
		var/obj/item/ammo_storage/magazine/lawgiver/L = magazine
		to_chat(user, "<span class='info'>It has enough energy for [L.stuncharge/20] stun shot\s left.</span>")
		to_chat(user, "<span class='info'>It has enough energy for [L.lasercharge/20] laser shot\s left.</span>")
		to_chat(user, "<span class='info'>It has [L.rapid_ammo_count] rapid fire round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.flare_ammo_count] [istype(L, /obj/item/ammo_storage/magazine/lawgiver/demolition) ? "hi-EX" : "flare"] round\s remaining.</span>")
		to_chat(user, "<span class='info'>It has [L.ricochet_ammo_count] ricochet round\s remaining.</span>")

/obj/item/weapon/gun/lawgiver/proc/countAmmo(var/obj/item/A)
	var/obj/item/ammo_storage/magazine/lawgiver/L = A
	if (L.stuncharge == 0 && L.lasercharge == 0 && L.rapid_ammo_count == 0 && L.flare_ammo_count == 0 && L.ricochet_ammo_count == 0)
		return 0
	else
		has_played_alert = 0
		return 1

/obj/item/weapon/gun/lawgiver/demolition
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. This model is equipped to handle firing high-explosive rounds."

/obj/item/weapon/gun/lawgiver/demolition/Hear(var/datum/speech/speech, var/rendered_speech="")
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
				say("STUN.")
			else if((findtext(speech.message, "laser")) || (findtext(speech.message, "lethal")) || (findtext(speech.message, "beam")))
				firing_mode = LASER
				fire_sound = 'sound/weapons/lasercannonfire.ogg'
				projectile_type = "/obj/item/projectile/beam/heavylaser"
				fire_delay = 5
				sleep(3)
				say("LASER.")
			else if((findtext(speech.message, "rapid")) || (findtext(speech.message, "automatic")))
				firing_mode = RAPID
				fire_sound = 'sound/weapons/Gunshot_c20.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/lawgiver"
				fire_delay = 0
				recoil = 1
				sleep(3)
				say("RAPID FIRE.")
			else if((findtext(speech.message, "hi ex")) || (findtext(speech.message, "hi-ex")) || (findtext(speech.message, "explosive")) || (findtext(speech.message, "rocket")))
				firing_mode = FLARE
				fire_sound = 'sound/weapons/elecfire.ogg'
				projectile_type = "/obj/item/projectile/bullet/gyro"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("HIGH EXPLOSIVE.")
			else if((findtext(speech.message, "ricochet")) || (findtext(speech.message, "bounce")))
				firing_mode = RICOCHET
				fire_sound = 'sound/weapons/gatling_fire.ogg'
				projectile_type = "/obj/item/projectile/bullet/midbullet/bouncebullet/lawgiver"
				fire_delay = 5
				recoil = 1
				sleep(3)
				say("RICOCHET.")
			update_icon()

/obj/item/weapon/gun/lawgiver/demolition/check_mag_type(obj/item/I, mob/user)
	if(!istype(I, /obj/item/ammo_storage/magazine/lawgiver/demolition))
		to_chat(user, "<span class='warning'>This demolition-model [src.name] can't take a standard lawgiver magazine!</span>")
		return 0
	return 1

#undef RICOCHET
#undef RAPID
#undef FLARE
#undef STUN
#undef LASER
