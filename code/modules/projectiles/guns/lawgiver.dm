#define LAWGIVER_RICOCHET "ricochet"
#define LAWGIVER_RAPID "rapid"
#define LAWGIVER_FLARE "flare"
#define LAWGIVER_STUN "stun"
#define LAWGIVER_LASER "laser"
#define LAWGIVER_DOUBLE_WHAMMY "double whammy"

/datum/lawgiver_mode
	var/name
	var/kind = LAWGIVER_MODE_KIND_ENERGY
	var/list/voice_triggers // lower-case text strings that activate the mode when spoken by the owner
	var/firing_mode // text string ID
	var/fire_sound
	var/projectile_type
	var/fire_delay = 0 // Deciseconds
	var/recoil = FALSE // if TRUE projectiles fired in this mode have recoil
	var/activation_message // spoken by the gun when the mode is activated
	var/ammo_casing_type // if specified, it will be spawned at the user's location
	var/ammo_per_shot = 1

/datum/lawgiver_mode/stun
	name = "stun"
	voice_triggers = list("stun", "taser")
	firing_mode = LAWGIVER_STUN
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = /obj/item/projectile/energy/electrode
	activation_message = "STUN."
	ammo_per_shot = 20

/datum/lawgiver_mode/laser
	name = "laser"
	voice_triggers = list("laser", "lethal", "beam")
	firing_mode = LAWGIVER_LASER
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	projectile_type = /obj/item/projectile/beam/heavylaser/lawgiver
	fire_delay = 5
	activation_message = "LASER."
	ammo_per_shot = 20

/datum/lawgiver_mode/rapid_fire
	name = "rapid fire"
	kind = LAWGIVER_MODE_KIND_BULLET
	voice_triggers = list("rapid", "automatic")
	firing_mode = LAWGIVER_RAPID
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	projectile_type = /obj/item/projectile/bullet/midbullet/lawgiver
	fire_delay = 0
	recoil = TRUE
	activation_message = "RAPID FIRE."
	ammo_casing_type = /obj/item/ammo_casing/a12mm

/datum/lawgiver_mode/flare
	name = "flare"
	kind = LAWGIVER_MODE_KIND_BULLET
	voice_triggers = list("flare", "incendiary")
	firing_mode = LAWGIVER_FLARE
	fire_sound = 'sound/weapons/shotgun.ogg'
	projectile_type = /obj/item/projectile/flare
	fire_delay = 5
	recoil = TRUE
	activation_message = "FLARE."
	ammo_casing_type = /obj/item/ammo_casing/shotgun/flare

/datum/lawgiver_mode/hi_ex
	name = "hi-EX"
	kind = LAWGIVER_MODE_KIND_BULLET
	voice_triggers = list("hi ex", "hi-ex", "explosive", "rocket")
	firing_mode = LAWGIVER_FLARE
	fire_sound = 'sound/weapons/elecfire.ogg'
	projectile_type = /obj/item/projectile/bullet/gyro
	fire_delay = 5
	recoil = TRUE
	activation_message = "HIGH EXPLOSIVE."
	ammo_casing_type = /obj/item/ammo_casing/a75

/datum/lawgiver_mode/ricochet
	name = "ricochet"
	kind = LAWGIVER_MODE_KIND_BULLET
	voice_triggers = list("ricochet", "bounce")
	firing_mode = LAWGIVER_RICOCHET
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	projectile_type = /obj/item/projectile/bullet/midbullet/bouncebullet/lawgiver
	fire_delay = 5
	recoil = TRUE
	activation_message = "RICOCHET."
	ammo_casing_type = /obj/item/ammo_casing/a12mm/bounce

/datum/lawgiver_mode/double_whammy
	name = "double whammy"
	voice_triggers = list("double whammy")
	firing_mode = LAWGIVER_DOUBLE_WHAMMY
	fire_sound = 'sound/weapons/alien_laser1.ogg'
	projectile_type = /obj/item/projectile/energy/whammy
	fire_delay = 0
	activation_message = "DOUBLE WHAMMY."

var/list/lawgiver_modes = list(
	/obj/item/weapon/gun/lawgiver = newlist(
		/datum/lawgiver_mode/stun,
		/datum/lawgiver_mode/laser,
		/datum/lawgiver_mode/rapid_fire,
		/datum/lawgiver_mode/flare,
		/datum/lawgiver_mode/ricochet,
	),
	/obj/item/weapon/gun/lawgiver/demolition = newlist(
		/datum/lawgiver_mode/stun,
		/datum/lawgiver_mode/laser,
		/datum/lawgiver_mode/rapid_fire,
		/datum/lawgiver_mode/hi_ex,
		/datum/lawgiver_mode/ricochet,
		/datum/lawgiver_mode/double_whammy,
	),
)

/obj/item/weapon/gun/lawgiver
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. You can see the words STUN, LASER, RAPID, FLARE and RICOCHET written in small print on its barreling."
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
	var/magazine_type = /obj/item/ammo_storage/magazine/lawgiver
	var/datum/lawgiver_mode/firing_mode_datum
	var/firing_mode = LAWGIVER_STUN
	fire_delay = 0
	var/projectile_type = "/obj/item/projectile/energy/electrode"
	fire_sound = 'sound/weapons/Taser.ogg'
	var/obj/item/ammo_storage/magazine/lawgiver/magazine = null
	var/dna_profile = null
	var/rapidFirecheck = 0
	var/damage_multiplier = 1
	var/has_played_alert = 0

/obj/item/weapon/gun/lawgiver/proc/available_modes()
	return lawgiver_modes[type]

/obj/item/weapon/gun/lawgiver/isHandgun()
	return TRUE

/obj/item/weapon/gun/lawgiver/New()
	..()
	magazine = new magazine_type(src)
	verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
	firing_mode_datum = available_modes()[1]
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
		var/image/magazine_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)]Mag")
		var/image/ammo_overlay = null
		var/icon_state_suffix = magazine.ammo_counters[firing_mode_datum] / firing_mode_datum.ammo_per_shot
		ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][icon_state_suffix]")
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
	var/datum/organ/external/active_hand = user.get_active_hand_organ()
	if(active_hand)
		active_hand.explode()
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
		magazine.forceMove(get_turf(src.loc))
		if(user)
			user.put_in_hands(magazine)
			to_chat(user, "<span class='notice'>You pull the magazine out of \the [src].</span>")
		magazine.update_icon()
		magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/proc/activate_mode(var/datum/lawgiver_mode/mode)
	set waitfor = FALSE

	firing_mode_datum = mode
	firing_mode = mode.firing_mode
	fire_sound = mode.fire_sound
	projectile_type = mode.projectile_type
	fire_delay = mode.fire_delay
	recoil = mode.recoil

	update_icon()
	sleep(0.3 SECONDS)
	say(mode.activation_message)

/obj/item/weapon/gun/lawgiver/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker != loc || speech.frequency || !dna_profile)
		return
	var/mob/living/carbon/human/H = loc
	if(dna_profile != H.dna.unique_enzymes)
		return
	var/speech_message = speech.message
	for(var/datum/lawgiver_mode/mode in available_modes())
		for(var/trigger in mode.voice_triggers)
			if(findtext(speech_message, trigger))
				activate_mode(mode)
				return


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

/obj/item/weapon/gun/lawgiver/proc/fire_double_whammy(var/atom/target, var/mob/living/user, var/list/params, var/struggle)
	var/turf/origin_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	var/orientation = get_dir(origin_turf, target_turf)
	// Turfs to the "left" and to the "right" of the clicked target
	var/projectile1_target = get_step(target_turf, counter_clockwise_perpendicular_direction(orientation))
	var/projectile2_target = get_step(target_turf, reverse_direction(counter_clockwise_perpendicular_direction(orientation)))
	Fire(projectile1_target, user, params, struggle)
	if(!in_chamber)
		in_chamber = new projectile_type(src)
	Fire(projectile2_target, user, params, struggle)

/obj/item/weapon/gun/lawgiver/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0) //Overriding this due to introducing the DNA check, and the fact that the round is to be chambered only just before it is fired
	..()
	if(!firing_mode_datum.ammo_casing_type)
		return
	var/obj/item/ammo_casing/new_casing = new firing_mode_datum.ammo_casing_type(user.loc)
	new_casing.BB = null
	new_casing.update_icon()

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
	if(magazine.ammo_counters[firing_mode_datum] < firing_mode_datum.ammo_per_shot)
		return 0
	if(!projectile_type)
		return 0
	in_chamber = new projectile_type(src)
	magazine.ammo_counters[firing_mode_datum] -= firing_mode_datum.ammo_per_shot
	return 1

/obj/item/weapon/gun/lawgiver/proc/can_shoot() //Only made so that firing point-blank can run its checks without chambering a round, since rounds are chambered in Fire()
	if(!magazine)
		return FALSE
	if(magazine.ammo_counters[firing_mode_datum] < firing_mode_datum.ammo_per_shot)
		return FALSE
	if(in_chamber)
		return TRUE
	if(!projectile_type)
		return FALSE
	return TRUE

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

	if(firing_mode == LAWGIVER_RAPID && !rapidFirecheck)
		rapidFire(A, user, params, struggle)
		return

	else if(firing_mode == LAWGIVER_RAPID && rapidFirecheck)
		return

	if(firing_mode == LAWGIVER_DOUBLE_WHAMMY)
		fire_double_whammy(A, user, params, struggle)
		return

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params, "struggle" = struggle) //Otherwise, fire normally.

	if(magazine)
		if(magazine.isEmpty() && !has_played_alert)
			has_played_alert = TRUE
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		else
			has_played_alert = FALSE

/obj/item/weapon/gun/lawgiver/examine(mob/user)
	..()
	if(!magazine)
		return
	to_chat(user, magazine.generate_description())

/obj/item/weapon/gun/lawgiver/say(var/message)
	..(message, class = "siliconsay")

/obj/item/weapon/gun/lawgiver/say_quote(var/message)
	return "reports, [message]"

/obj/item/weapon/gun/lawgiver/demolition
	desc = "The Lawgiver II. A twenty-five round sidearm with mission-variable voice-programmed ammunition. You can see the words STUN, LASER, RAPID, FLARE and RICOCHET written in small print on the barreling, alongside HI EX and DOUBLE WHAMMY."
	magazine_type = /obj/item/ammo_storage/magazine/lawgiver/demolition

/obj/item/weapon/gun/lawgiver/demolition/check_mag_type(obj/item/I, mob/user)
	if(!istype(I, /obj/item/ammo_storage/magazine/lawgiver/demolition))
		to_chat(user, "<span class='warning'>This demolition-model [src.name] can't take a standard lawgiver magazine!</span>")
		return 0
	return 1

#undef LAWGIVER_DOUBLE_WHAMMY
#undef LAWGIVER_RICOCHET
#undef LAWGIVER_RAPID
#undef LAWGIVER_FLARE
#undef LAWGIVER_STUN
#undef LAWGIVER_LASER
