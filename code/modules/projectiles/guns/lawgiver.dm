#define LAWGIVER_RICOCHET "ricochet"
#define LAWGIVER_RAPID "rapid"
#define LAWGIVER_FLARE "flare"
#define LAWGIVER_STUN "stun"
#define LAWGIVER_LASER "laser"
#define LAWGIVER_DOUBLE_WHAMMY "double whammy"
//HONKGIVER
#define HONKGIVER_SCREAM "scream"
#define HONKGIVER_DOOMLAZOR "DOOMLAZOR"
#define HONKGIVER_PIE "pie"
#define HONKGIVER_BALL "ball"
#define HONKGIVER_PEEL "peel"
#define HONKGIVER_WATERSQUIRT "water squirt"

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
	var/ammo_per_shot = 5 //number of shots per mode.
	var/rapid_fire_spread = FALSE //if TRUE, rapid fire projectiles will spread during a burst

/datum/lawgiver_mode/stun
	name = "stun"
	voice_triggers = list("stun", "taser", "detain")
	firing_mode = LAWGIVER_STUN
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = /obj/item/projectile/energy/electrode
	activation_message = "STUN."

/datum/lawgiver_mode/laser
	name = "laser"
	voice_triggers = list("laser", "lethal", "beam")
	firing_mode = LAWGIVER_LASER
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	projectile_type = /obj/item/projectile/beam/heavylaser/lawgiver
	fire_delay = 5
	activation_message = "LASER."

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

//HONKGIVER===========================================================
/datum/lawgiver_mode/scream
	name = "scream"
	voice_triggers = list("scream","zcream")
	firing_mode = HONKGIVER_SCREAM
	fire_sound = 'sound/weapons/Taser.ogg'
	projectile_type = /obj/item/projectile/energy/electrode/scream_shot
	fire_sound =  'sound/weapons/Taser.ogg'
	fire_delay = 0
	activation_message = "SCREAM SHOT."
	ammo_per_shot = 20

/datum/lawgiver_mode/doomlazor
	name = "DOOMLAZOR"
	voice_triggers = list("death", "doom","lazor","doomlazor","doomlazors","lazors","lazorz","doomlazorz")
	firing_mode = HONKGIVER_DOOMLAZOR
	fire_sound = 'sound/effects/doomlazor.ogg'
	projectile_type = /obj/item/projectile/beam/doomlazorz
	fire_delay = 10
	activation_message = "ULTRA-LETHAL-DEATH-LAZOR OF DOOM!"
	ammo_per_shot = 1 //single shot! but it recharges!

/datum/lawgiver_mode/ball
	name = "ball"
	kind = LAWGIVER_MODE_KIND_BULLET
	voice_triggers = list("beach","ball","bounce", "bouncy")
	firing_mode = HONKGIVER_BALL
	fire_sound = 'sound/effects/awooga.ogg'
	projectile_type = /obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball
	activation_message = "BOUNCY BALL!"
	ammo_per_shot = 20

/datum/lawgiver_mode/watergun
	name = "watergun"
	voice_triggers = list("water", "squirt", "watergun", "splash","soak","soaker","stream","liquid")
	firing_mode = HONKGIVER_WATERSQUIRT
	kind = LAWGIVER_MODE_KIND_BULLET
	fire_sound = 'sound/items/egg_squash.ogg'//this is what the supersoaker uses.
	projectile_type = /obj/item/projectile/beam/liquid_stream/honkgiver_stream
	activation_message = "WATER GUN!"
	ammo_per_shot = 20

/datum/lawgiver_mode/pie
	name = "pie"
	voice_triggers = list("pie","creampie")
	firing_mode = HONKGIVER_PIE
	kind = LAWGIVER_MODE_KIND_BULLET
	projectile_type = /obj/item/projectile/bullet/pie_shot
	fire_sound = 'sound/effects/pop_toony.ogg'
	activation_message = "RAPID PIE-ER!"
	fire_delay = 0
	ammo_per_shot = 20
	rapid_fire_spread = TRUE

/datum/lawgiver_mode/peel
	name = "peel"
	voice_triggers = list("peel","banana","bananapeel")
	firing_mode = HONKGIVER_PEEL
	kind = LAWGIVER_MODE_KIND_BULLET
	projectile_type = /obj/item/projectile/bullet/peel_shot
	fire_sound = 'sound/items/bikehorn.ogg'
	activation_message = "BANANA PEEL!"
	ammo_per_shot = 20

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
	/obj/item/weapon/gun/lawgiver/honkgiver = newlist(
		/datum/lawgiver_mode/scream,
		/datum/lawgiver_mode/watergun,
		/datum/lawgiver_mode/pie,
		/datum/lawgiver_mode/peel,
		/datum/lawgiver_mode/ball,
		/datum/lawgiver_mode/doomlazor,
	)
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
	var/voiceclass = "siliconsay"
	clowned = CLOWNABLE

/obj/item/weapon/gun/lawgiver/proc/available_modes()
	return lawgiver_modes[type]

/obj/item/weapon/gun/lawgiver/isHandgun()
	return TRUE

/obj/item/weapon/gun/lawgiver/New()
	..()
	magazine = new magazine_type(src)
	verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
	firing_mode_datum = available_modes()[1]
	activate_mode(firing_mode_datum,TRUE)
	update_icon()

/obj/item/weapon/gun/lawgiver/Destroy()
	if(magazine)
		QDEL_NULL(magazine)
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
		var/icon_state_suffix = ceil(5-((firing_mode_datum.ammo_per_shot-magazine.ammo_counters[firing_mode_datum])/(firing_mode_datum.ammo_per_shot/5)))

		ammo_overlay = image('icons/obj/gun.dmi', src, "[initial(icon_state)][icon_state_suffix]")
		overlays += magazine_overlay
		overlays += ammo_overlay
	else
		item_state = "[initial(icon_state)]0"

	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		if(H.is_holding_item(src))
			overlays += dna_overlay_check(H)
		H.update_inv_hands()

/obj/item/weapon/gun/lawgiver/proc/dna_overlay_check(var/mob/living/carbon/human/H)
	if(istype(src, /obj/item/weapon/gun/lawgiver/honkgiver))
		if(clumsy_check(H))
			return image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
		else
			return image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")
	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			return image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAgood")
		else
			return image('icons/obj/gun.dmi', src, "[initial(icon_state)]DNAbad")

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
		user.put_in_hands(magazine)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src].</span>")
		magazine.update_icon()
		magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/lawgiver/proc/activate_mode(var/datum/lawgiver_mode/mode,var/silent = FALSE)
	set waitfor = FALSE

	firing_mode_datum = mode
	firing_mode = mode.firing_mode
	fire_sound = mode.fire_sound
	projectile_type = mode.projectile_type
	fire_delay = mode.fire_delay
	recoil = mode.recoil

	update_icon()
	sleep(0.3 SECONDS)
	if(!silent)
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
	if(dna_check())
		return chamber_round()

/obj/item/weapon/gun/lawgiver/proc/rapidFire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, struggle = 0) //Burst fires don't work well except by calling Fire() multiple times
	rapidFirecheck = 1
	recoil = 1
	var/shot_number = 0
	for (var/i = 1; i <= 3; i++)
		if(i>1 && !in_chamber)
			in_chamber = new projectile_type(src)
		if(firing_mode_datum.rapid_fire_spread)//if rapid fire shot has some spread to it ala gatling gun
			if(shot_number>0)// first shot won't spread
				var/list/turf/possible_turfs = list()
				for (var/turf/T in orange(target, 1))
					possible_turfs += T
				target = pick(possible_turfs)
			shot_number ++
		Fire(target, user, params, struggle)
		recoil = 0
		silenced = 1
	recoil = 1
	silenced = 0
	rapidFirecheck = 0

/obj/item/weapon/gun/lawgiver/proc/fire_double_whammy(var/atom/target, var/mob/living/user, var/list/params, var/struggle)
	var/turf/origin_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	var/orientation = get_dir(origin_turf, target_turf)
	// Turfs to the "left" and to the "right" of the clicked target
	var/projectile1_target = get_step(target_turf, counterclockwise_perpendicular_dirs[orientation])
	var/projectile2_target = get_step(target_turf, clockwise_perpendicular_dirs(orientation))
	Fire(projectile1_target, user, params, struggle)
	if(!in_chamber)
		in_chamber = new projectile_type(src)
	Fire(projectile2_target, user, params, struggle)

/obj/item/weapon/gun/lawgiver/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE) //Overriding this due to introducing the DNA check, and the fact that the round is to be chambered only just before it is fired
	..()
	if(!firing_mode_datum.ammo_casing_type)
		return
	var/obj/item/ammo_casing/new_casing = new firing_mode_datum.ammo_casing_type(user.loc)
	new_casing.BB = null
	new_casing.update_icon()

/obj/item/weapon/gun/lawgiver/proc/chamber_round()
	if(in_chamber)
		if(in_chamber.type == projectile_type)
			return 1
		else
			for(var/datum/lawgiver_mode/M in lawgiver_modes[type])
				if(in_chamber && (in_chamber.type == M.projectile_type))
					magazine.ammo_counters[M] = min(magazine.ammo_counters[M]+1, M.ammo_per_shot)
					QDEL_NULL(in_chamber)
			if(in_chamber)
				return 1
	if(!magazine)
		return 0
	if(!magazine.ammo_counters[firing_mode_datum])
		return 0
	if(!projectile_type)
		return 0
	in_chamber = new projectile_type(src)
	magazine.ammo_counters[firing_mode_datum]--
	return 1

/obj/item/weapon/gun/lawgiver/can_discharge()
	if(!dna_check())
		return FALSE
	if(!magazine)
		return FALSE
	if(!magazine.ammo_counters[firing_mode_datum])
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

	if(clowned == CLOWNABLE && istype(A,/obj/item/toy/crayon/rainbow))
		if(!isturf(loc))
			to_chat(user, "<span class='warning'>\The [src] must be safely placed on the ground before it can be honkified.</span>")
			return
		to_chat(user, "<span class = 'notice'>You begin modifying \the [src].</span>")
		if(do_after(user, src, 4 SECONDS))
			to_chat(user, "<span class = 'notice'>You finish modifying \the [src]!</span>")
			clownify()

/obj/item/weapon/gun/lawgiver/proc/clownify()
	var/obj/item/weapon/gun/lawgiver/honkgiver/HG = new /obj/item/weapon/gun/lawgiver/honkgiver(loc)
	if(magazine) //has magazine at time of clowning, ammo values will automatically be converted
		var/obj/item/ammo_storage/magazine/lawgiver/honkgiver/HGM = HG.magazine
		magazine.honkgiver_ammo_conversion(HGM)	//run honkgiver clip conversion
		HGM.original_type = magazine.type //store our original type into the honkgiver mag in case we get declowned in the future, we can turn into the right mag.
		transfer_fingerprints(magazine,HGM)
	else
		qdel(HG.magazine) //no magazine at time of clowning. honkgiver shall also not have a magazine
		HG.magazine = null
	transfer_fingerprints(src,HG)
	HG.original_type = src.type		//store typepath for lawgiver into honkgiver
	HG.dna_profile_holder = dna_profile
	qdel(src)
	HG.update_icon()

/obj/item/weapon/gun/lawgiver/proc/check_mag_type(obj/item/I, mob/user)
	if(istype(I, /obj/item/ammo_storage/magazine/lawgiver/demolition))
		to_chat(user, "<span class='warning'>You can't load a demolition-model magazine into this [src.name]!</span>")
		return 0
	if(istype(I, /obj/item/ammo_storage/magazine/lawgiver/honkgiver))
		to_chat(user, "<span class='warning'>You can't load a HONK-model magazine into this [src.name]!</span>")
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

/obj/item/weapon/gun/lawgiver/proc/dna_check(var/mob/user)
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return 0
	if(dna_profile)
		if(dna_profile != user.dna.unique_enzymes)
			self_destruct(user)
			return 0
	else
		click_empty(user)
		say("PLEASE REGISTER A DNA SAMPLE.")
		return 0
	return 1

/obj/item/weapon/gun/lawgiver/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(istype(A, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
		return//Shouldnt flag take care of this?

	if(!dna_check(user))
		return

	if(in_chamber)
		QDEL_NULL(in_chamber)
	if(!special_check())
		return
	if(!chamber_round())
		return click_empty(user)

	in_chamber.damage *= damage_multiplier

	if(firing_mode == LAWGIVER_RAPID || firing_mode == HONKGIVER_PIE && !rapidFirecheck)
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
	..(message, class = voiceclass)

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

//HONKGIVER
/*
	DONE:
		[X] HONKSPLOSION WHEN NON CLOWN USES
		[X] replace DNA checks with clumsy checks.
		[X]troubleshoot watergun so it shoots water + honkserum
		RECHARGE THE MAGAZINE BY HONKING? IT?
		[X]ALL THE DIFFERENT HONK SHOTS.
		[X]Scale the amount of shots to be much higher. I need at least 30 pie shots before this thing is empty!
		[X]BOUNCY BALL CUSTOM MESSAGE ON HIT. [X]CUSTOM EFFECT?

*/

/obj/item/weapon/gun/lawgiver/honkgiver
	name = "honkgiver"
	desc = "The Honkgiver, for all your head of clowning needs. You can see the words SCREAM, DOOMLAZOR, WATERGUN, PIE, PEEL and BOUNCY crayoned in small print on its barreling."

	clumsy_check = 0
	firing_mode = HONKGIVER_SCREAM
	magazine_type = /obj/item/ammo_storage/magazine/lawgiver/honkgiver
	icon_state = "honkgiver"
	item_state = "honkgiver"
	voiceclass = "clown"
	var/original_type = null //if this is a clowned lawgiver, the original lawgiver type is stored here for when we get unclowned. otherwise it is adminspawn or vaultloot and cannot be declowned.
	clowned = CLOWNED
	var/dna_profile_holder = null

/obj/item/weapon/gun/lawgiver/honkgiver/New()
	..()
	verbs -= /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample //we only check for clumsy, not DNA

/obj/item/weapon/gun/lawgiver/honkgiver/dna_check(var/mob/user) //this is now a glorified clumsy check
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return 0
	if(!clumsy_check(user))
		self_destruct(user)
		return 0
	return 1

/obj/item/weapon/gun/lawgiver/honkgiver/self_destruct(mob/user) //Big Honk and stun if user isn't clumsy. this doesn't destroy the gun anymore.
	say("HOOOOOOOOOOOOOOOOOOOOOOOOOOOOONK!")
	playsound(src, 'sound/items/AirHorn.ogg', 100, 1)
	user.stuttering += 10
	user.ear_deaf += 4
	user.knockdown += 4
	user.Stun(4)
	user.Jitter(100)
	return

/obj/item/weapon/gun/lawgiver/honkgiver/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker != loc || speech.frequency)
		return
	var/mob/living/carbon/human/H = loc
	if(!clumsy_check(H))
		return
	var/speech_message = speech.message
	for(var/datum/lawgiver_mode/mode in available_modes())
		for(var/trigger in mode.voice_triggers)
			if(findtext(speech_message, trigger))
				activate_mode(mode)
				return

/obj/item/weapon/gun/lawgiver/honkgiver/check_mag_type(obj/item/I, mob/user)
	if(!istype(I, /obj/item/ammo_storage/magazine/lawgiver/honkgiver))
		to_chat(user, "<span class='warning'>This HONK-model [src.name] can only take honkgiver magazines!</span>")
		return 0
	return 1

/obj/item/weapon/gun/lawgiver/honkgiver/decontaminate()
	..()
	unclownify()

/obj/item/weapon/gun/lawgiver/honkgiver/proc/unclownify()
	if(!original_type) //adminspawn or vault honkgiver
		visible_message("<span class='notice'>\The [src] resists all efforts to be brought to mundanity. This... this is a true Honkgiver. Woah...</span>")
	else
		if(!isturf(loc))
			forceMove(get_turf(src))
		var/obj/item/weapon/gun/lawgiver/LG = new original_type(loc)
		if(magazine)
			var/obj/item/ammo_storage/magazine/lawgiver/honkgiver/HGM = magazine
			if(!HGM.original_type) //adminspawn or vault honkgiver
				visible_message("<span class='notice'>\The [magazine] is ejected as it resists your efforts to declownify it! It must truly be a timeless relic of clownliness...</span>")
				RemoveMag()
			else
				magazine.honkgiver_ammo_conversion(LG.magazine)
				transfer_fingerprints(LG.magazine,magazine)
		else
			qdel(LG.magazine)
			LG.magazine = null
		transfer_fingerprints(LG,src)
		LG.dna_profile = dna_profile_holder //hand over the dna profile we held from the original lawgiver
		qdel(src)
		LG.update_icon()


/obj/item/weapon/gun/lawgiver/honkgiver/ultimate //for adminbus and vault loot. Has 9,999,999 shots per ammo type.
	magazine_type = /obj/item/ammo_storage/magazine/lawgiver/honkgiver/ultimate

/obj/item/weapon/gun/lawgiver/honkgiver/ultimate/RemoveMag(var/mob/user) //no removing the ultimate mag from the ultimate honkgiver.
	to_chat(usr, "<span class='notice'>The magazine is too powerful to be removed from \the [src].</span>")
	return 0

/obj/item/weapon/gun/lawgiver/honkgiver/ultimate/available_modes()
	return lawgiver_modes[/obj/item/weapon/gun/lawgiver/honkgiver]

#undef LAWGIVER_DOUBLE_WHAMMY
#undef LAWGIVER_RICOCHET
#undef LAWGIVER_RAPID
#undef LAWGIVER_FLARE
#undef LAWGIVER_STUN
#undef LAWGIVER_LASER
#undef HONKGIVER_SCREAM
#undef HONKGIVER_DOOMLAZOR
#undef HONKGIVER_PIE
#undef HONKGIVER_BALL
#undef HONKGIVER_PEEL
#undef HONKGIVER_WATERSQUIRT
