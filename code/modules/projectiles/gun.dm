#define UNCLOWN 1
#define CLOWNABLE 2
#define CLOWNED 3
#define SILENCER_OFFSET_X 1
#define SILENCER_OFFSET_Y 2

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	var/clowned = UNCLOWN //UNCLOWN, CLOWNABLE, or CLOWNED
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = Tc_COMBAT + "=1"
	attack_verb = list("strikes", "hits", "bashes")
	mech_flags = MECH_SCAN_ILLEGAL
	min_harm_label = 20
	harm_label_examine = list("<span class='info'>A label is stuck to the trigger, but it is too small to get in the way.</span>", "<span class='warning'>A label firmly sticks the trigger to the guard!</span>")
	ghost_read = 0
	hitsound = 'sound/weapons/smash.ogg'
	on_armory_manifest = TRUE
	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/fire_action = "fire"
	var/empty_sound = 'sound/weapons/empty.ogg'
	var/fire_volume = 50 //the volume of the fire_sound
	var/obj/item/projectile/in_chamber = null
	var/list/caliber //the ammo the gun will accept. Now multiple types (make sure to set them to =1)
	var/silenced = 0
	var/list/silencer_offset = list() //x,y coords to bump silencer overlay to FROM (4,13) (use barrel end pixel position)
	var/list/gun_part_overlays = list() //holds copy of overlays to allow for sane manipulation
	var/recoil = 0
	var/ejectshell = 1

	var/clumsy_check = 1				//Whether the gun disallows clumsy users from firing it.
	var/honor_check = 1                 // Same, but highlanders and bombermen.
	var/advanced_tool_user_check = 1	//Whether the gun disallows users that cannot use advanced tools from firing it.
	var/MoMMI_check = 1					//Whether the gun disallows MoMMIs from firing it.
	var/nymph_check = 1					//Whether the gun disallows diona nymphs from firing it.
	var/hulk_check = 1					//Whether the gun disallows hulks from firing it.
	var/golem_check = 1					//Whether the gun disallows golems from firing it.
	var/manifested_check = 1			//Whether the gun disallows manifested ghosts from firing it.

	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 1 	// 0 for one bullet after tarrget moves and aim is lowered,
						//1 for keep shooting until aim is lowered
	var/fire_delay = 2
	var/last_fired = 0
	var/delay_user = 4	//how much to delay the user's next attack by after firing

	var/conventional_firearm = 1	//Used to determine whether, when examined, an /obj/item/weapon/gun/projectile will display the amount of rounds remaining.
	var/jammed = 0

	var/projectile_color = null
	var/projectile_color_shift = null

	var/pai_safety = TRUE	//To allow the pAI to activate or deactivate firing capability

	// Tells is_honorable() which special_roles to respect.
	var/honorable = HONORABLE_BOMBERMAN | HONORABLE_HIGHLANDER | HONORABLE_NINJA
	var/kick_fire_chance = 5

	//Affects the accuracy of the weapon
	var/gun_excessive_missing //If toggled on, projectiles that fail to hit a specified zone will always miss
	var/gun_miss_chance_value //Additive miss chance
	var/gun_miss_message //Message that shows up as an addition to the message text
	var/gun_miss_message_replace //If toggled on, will cause gun_miss_message to replace the entire missing message

	//This is a list that allows admins to alter projectile properties mid-round via assoc list.
	//Usage: vv the gun, C a new list, add text variable equal to the variable name you want to change,
	//Then set an associative value equal to the new value you want to change it to.
	//aka if you want to change the damage to 25, add a list with entry: text damage and associated value num 25
	var/list/bullet_overrides
	//And this overrides whatever's in the chamber.
	var/bullet_type_override

/obj/item/weapon/gun/New()
	..()
	if(isHandgun())
		quick_equip_priority |= list(slot_w_uniform) // for holsters

/obj/item/weapon/gun/Destroy()
	if(in_chamber)
		QDEL_NULL(in_chamber)
	..()

/obj/item/weapon/gun/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/process_chambered()
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	return 1

/obj/item/weapon/gun/proc/failure_check(var/mob/M) //special_check, but in a different place
	return 1

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/proc/can_discharge() //because process_chambered() is an atrocity
	return 0

/obj/item/weapon/gun/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
		return//Shouldnt flag take care of this?

	if (user.is_pacified(VIOLENCE_GUN,A,src))
		return

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params, "struggle" = struggle) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params, "struggle" = struggle) //Otherwise, fire normally.

/obj/item/weapon/proc/isHandgun()
	return FALSE //Make this proc return TRUE for handgun-shaped weapons (or in general, small enough weapons I guess)

/obj/item/weapon/gun/proc/play_firesound(mob/user, var/reflex)
	if(istype(silenced, /obj/item/gun_part/silencer))
		var/obj/item/gun_part/silencer/A = silenced
		if(fire_sound)
			playsound(user, fire_sound, fire_volume/A.volume_mult, 1)
		else if (in_chamber.fire_sound)
			playsound(user, in_chamber.fire_sound, fire_volume/A.volume_mult, 1)
		if(A.volume_mult <= 1)
			user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
			"<span class='warning'>You [fire_action] [src][reflex ? " by reflex":""]!</span>", \
			"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
	else
		if(fire_sound)
			playsound(user, fire_sound, fire_volume, 1)
		else if (in_chamber.fire_sound)
			playsound(user, in_chamber.fire_sound, fire_volume, 1)
		if(!silenced)
			user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
			"<span class='warning'>You [fire_action] [src][reflex ? "by reflex":""]!</span>", \
			"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

/obj/item/weapon/gun/proc/can_Fire(mob/user, var/display_message = 0)
	var/firing_dexterity = 1
	if(advanced_tool_user_check)
		if (!user.dexterity_check())
			firing_dexterity = 0
	if(MoMMI_check)
		if(isMoMMI(user))
			firing_dexterity = 0
	if(nymph_check)
		if(istype(user, /mob/living/carbon/monkey/diona))
			firing_dexterity = 0
	if(!firing_dexterity)
		if(display_message)
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0

	if(istype(user, /mob/living))
		if(hulk_check)
			var/mob/living/M = user
			if (M_HULK in M.mutations)
				if(display_message)
					to_chat(M, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
				return 0
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		if(golem_check)
			if(isgolem(H))
				if(display_message)
					to_chat(user, "<span class='warning'>Your fat fingers don't fit in the trigger guard!</span>")
				return 0
		if(manifested_check)
			if(ismanifested(H))
				if(display_message)
					to_chat(user, "<span class='warning'>It would dishonor the master to use anything but his unholy blade!</span>")
				return 0
		var/datum/organ/external/a_hand = H.get_active_hand_organ()
		if(!a_hand.can_use_advanced_tools())
			if(display_message)
				to_chat(user, "<span class='warning'>Your [a_hand.display_name] doesn't have the dexterity to do this!</span>")
			return 0
	return 1

/obj/item/weapon/gun/proc/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	//Exclude lasertag guns from the M_CLUMSY check.
	. = reset_point_blank_shot()

	if(!can_Fire(user, 1))
		return

	var/explode = FALSE
	var/dehand = FALSE
	if(istype(user, /mob/living))
		var/mob/living/M = user
		var/honor = is_honorable(M, honorable)
		if(honor_check && honor == MERELY_HONORABLE) //Merely honorable people simply cannot use guns
			to_chat(M, "<span class='notice'>You are too honorable to use such weapons!</span>")
			return
		if(clumsy_check && clumsy_check(M) && prob(50))
			explode = TRUE
		if(honor_check && honor == VERY_HONORABLE)
			explode = TRUE
			dehand = TRUE
		if(explode)
			if(dehand)
				var/limb_index = user.is_holding_item(src)
				var/datum/organ/external/L = M.find_organ_by_grasp_index(limb_index)
				visible_message("<span class='sinister'>[src] blows up in [M]'s [L.display_name]!</span>")
				L.droplimb(1)
			else
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
			M.drop_item(src, force_drop = 1)
			qdel(src)
			return

	add_fingerprint(user)
	var/atom/originaltarget = target

	var/turf/curloc = user.loc
	if(use_shooter_turf)
		curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	if(defective)
		target = get_inaccuracy(originaltarget, 1+recoil)
		targloc = get_turf(target)

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!")
		return

	if(!process_chambered() || jammed) //CHECK
		return click_empty(user)

	if(bullet_type_override && ispath(bullet_type_override, /obj/item/projectile))
		in_chamber = new bullet_type_override

	if(!in_chamber)
		return
	if(defective)
		if(!failure_check(user))
			return
	if(!istype(src, /obj/item/weapon/gun/energy/tag))
		log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [originaltarget] [ismob(target) ? "([originaltarget:ckey])" : ""] ([originaltarget.x],[originaltarget.y],[originaltarget.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user

	if(user.zone_sel)
		in_chamber.def_zone = user.zone_sel.selecting
	else
		in_chamber.def_zone = LIMB_CHEST

	if(targloc == curloc)
		target.bullet_act(in_chamber)
		QDEL_NULL(in_chamber)
		update_icon()
		play_firesound(user, reflex)
		return

	if(recoil)
		spawn()
			directional_recoil(user, recoil, get_angle(user, target))
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

		user.apply_inertia(get_dir(target, user))

	in_chamber.original = target
	in_chamber.forceMove(get_turf(user))
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	user.delayNextAttack(delay_user) // TODO: Should be delayed per-gun.
	in_chamber.silenced = silenced
	in_chamber.current = curloc
	in_chamber.OnFired()
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	in_chamber.inaccurate = (istype(user.locked_to, /obj/structure/bed/chair/vehicle))
	if(projectile_color)
		in_chamber.apply_projectile_color(projectile_color)
	if(projectile_color_shift)
		in_chamber.apply_projectile_color_shift(projectile_color_shift)
	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])
	if(gun_excessive_missing)
		in_chamber.excessive_missing = gun_excessive_missing
	if(gun_miss_chance_value)
		in_chamber.projectile_miss_chance = gun_miss_chance_value
	if(gun_miss_message)
		in_chamber.projectile_miss_message = gun_miss_message
	if(gun_miss_message_replace)
		in_chamber.projectile_miss_message_replace = gun_miss_message_replace

	if(bullet_overrides)
		for(var/bvar in in_chamber.vars)
			for(var/o in bullet_overrides)
				if(bvar == o)
					in_chamber.vars[bvar] = bullet_overrides[o]

	play_firesound(user, reflex)

	spawn()
		if(in_chamber)
			in_chamber.process()
	sleep(1)
	in_chamber = null

	update_icon()

	user.update_inv_hand(user.active_hand)

	if(defective && recoil && prob(3))
		var/throwturf = get_ranged_target_turf(user, pick(alldirs), 7)
		user.drop_item()
		user.visible_message("\The [src] jumps out of [user]'s hands!","\The [src] jumps out of your hands!")
		throw_at(throwturf, rand(3, 6), 3)
		return 1

	return 1

/obj/item/weapon/gun/proc/reset_point_blank_shot()
	if(in_chamber && in_chamber.point_blank)
		in_chamber.point_blank = FALSE
		in_chamber.damage = in_chamber.damage/1.3

/obj/item/weapon/gun/proc/canbe_fired()
	return process_chambered()

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return in_chamber.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		if(empty_sound)
			user.visible_message("*click click*", "<span class='danger'>*click*</span>")
			playsound(user, empty_sound, 100, 1)
	else
		if(empty_sound)
			src.visible_message("*click click*")
			playsound(src, empty_sound, 100, 1)

/obj/item/weapon/gun/attack(mob/living/M, mob/living/user, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		if(istype(M.wear_mask, /obj/item/clothing/mask/happy))
			to_chat(M, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
			return
		mouthshoot = 1
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!do_after(user,src, 40))
			M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			mouthshoot = 0
			return
		if (process_chambered())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				var/obj/item/gun_part/silencer/A = silenced
				if(fire_sound)
					playsound(user, fire_sound, fire_volume/A.volume_mult, 1)
				else if (in_chamber.fire_sound)
					playsound(user, in_chamber.fire_sound, fire_volume/A.volume_mult, 1)
			else
				if(fire_sound)
					playsound(user, fire_sound, fire_volume, 1)
				else if (in_chamber.fire_sound)
					playsound(user, in_chamber.fire_sound, fire_volume, 1)
			in_chamber.firer = M
			in_chamber.on_hit(M)
			if(in_chamber.has_special_suicide)
				in_chamber.custom_mouthshot(user)
			else if (!in_chamber.nodamage)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, LIMB_HEAD, used_weapon = "Point blank shot in the mouth with \a [in_chamber]")
				user.death()
				var/suicidesound = pick('sound/misc/suicide/suicide1.ogg','sound/misc/suicide/suicide2.ogg','sound/misc/suicide/suicide3.ogg','sound/misc/suicide/suicide4.ogg','sound/misc/suicide/suicide5.ogg','sound/misc/suicide/suicide6.ogg')
				playsound(src, pick(suicidesound), 30, channel = 125)
				log_attack("<font color='red'>[key_name(user)] committed suicide with \the [src].</font>")
				user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] committed suicide with \the [src]</font>"
			else
				to_chat(user, "<span class = 'notice'>Ow...</span>")
				user.apply_effect(110,AGONY,0)
			QDEL_NULL(in_chamber)
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (can_discharge()) //Need to have something to fire but not load it up yet
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == I_HURT)
			if (user.is_pacified())
				to_chat(user, "<span class='notice'>[pick("Hey that's dangerous...wouldn't want hurting people.","You don't feel like firing \the [src] at \the [M].","Peace, my [user.gender == FEMALE ? "girl" : "man"]...")]</span>")
				return
			user.visible_message("<span class='danger'> \The [user] fires \the [src] point blank at [M]!</span>")
			if (process_chambered() && !in_chamber.point_blank) //Load whatever it is we fire
				in_chamber.damage *= 1.3 //Some guns don't work with damage / chambers, like dart guns!
				in_chamber.point_blank = TRUE
			src.Fire(M,user,0,0,1)
			return
		else if(target && (M in target))
			process_chambered()
			src.Fire(M,user,0,0,1) ///Otherwise, shoot!
			return
		else
			return ..() //Allows a player to choose to melee instead of shoot, by being on help intent.
	else
		return ..() //Pistolwhippin'

/obj/item/weapon/gun/state_controls_pai(obj/item/device/paicard/P)
	if(P.pai)
		to_chat(P.pai, "<span class='info'><b>You have been connected to \a [src].</b></span>")
		to_chat(P.pai, "<span class='info'>Your controls are:</span>")
		to_chat(P.pai, "<span class='info'>- PageDown / Z(hotkey mode): Connect or disconnect from \the [src]'s firing mechanism.</span>")
		to_chat(P.pai, "<span class='info'>- Click on a target: Fire \the [src] at the target.</span>")

/obj/item/weapon/gun/attack_integrated_pai(mob/living/silicon/pai/user)
	if(!pai_safety)
		to_chat(user, "<span class='notice'>You connect to \the [src]'s firing mechanism.</span>")
	else
		to_chat(user, "<span class='notice'>You disconnect from \the [src]'s firing mechanism.</span>")
	pai_safety = !pai_safety

/obj/item/weapon/gun/on_integrated_pai_click(mob/living/silicon/pai/user, var/atom/A)	//to allow any gun to be pAI-compatible, on a basic level, just by varediting
	if(check_pai_can_fire(user))
		Fire(A,user,use_shooter_turf = TRUE)

/obj/item/weapon/gun/proc/check_pai_can_fire(mob/living/silicon/pai/user)	//for various restrictions on when pAIs can fire a gun into which they're integrated
	if(get_holder_of_type(user, /obj/structure/disposalpipe) || get_holder_of_type(user, /obj/machinery/atmospherics/pipe))	//can't fire the gun from inside pipes or disposal pipes
		to_chat(user, "<span class='warning'>You can't aim \the [src] properly from this location!</span>")
		return FALSE
	else if(!pai_safety)
		to_chat(user, "<span class='warning'>You're not connected to \the [src]'s firing mechanism!</span>")
		return FALSE
	else
		return TRUE

/obj/item/weapon/gun/attackby(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = A
		if(!isHandgun() || !G.isHandgun() || !user.create_in_hands(src, new /obj/item/weapon/gun/akimbo(loc, src, G), G, move_in = TRUE))
			to_chat(user, "<span class = 'warning'>You can not combine \the [G] and \the [src].</span>")
	if(clowned == CLOWNABLE && istype(A,/obj/item/toy/crayon/rainbow))
		to_chat(user, "<span class = 'notice'>You begin modifying \the [src].</span>")
		if(do_after(user, src, 4 SECONDS))
			to_chat(user, "<span class = 'notice'>You finish modifying \the [src]!</span>")
			clowned = CLOWNED
			update_icon()
	..()

/obj/item/weapon/gun/decontaminate()
	..()
	if(clowned == CLOWNED)
		clowned = CLOWNABLE
		update_icon()

/obj/item/weapon/gun/update_icon()
	icon_state = initial(icon_state) + "[clowned == CLOWNED ? "c" : ""]"

/obj/item/weapon/gun/proc/bullet_hitting(var/obj/item/projectile/P,var/atom/atarget)
	return

/obj/item/weapon/gun/kick_act(mob/living/carbon/human/H)
	. = ..()
	if(prob(kick_fire_chance))
		var/list/targets = list()
		for(var/turf/t in oview(6))
			targets += t
		var/target = pick(targets)
		src.Fire(target,H,0,0,1)
