/obj/item/weapon/gun
	name = "gun"
	desc = "A gun, that you can bear. SHALL. NOT. BE. INFRINGED."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	mech_flags = MECH_SCAN_ILLEGAL
	min_harm_label = 20
	harm_label_examine = list("<span class='info'>A label is stuck to the trigger, but it is too small to get in the way.</span>", \
						      "<span class='warning'>A label firmly sticks the trigger to the guard!</span>")

	var/fire_sound = 'sound/weapons/gunshot.ogg'
	var/fire_sound_far = 'sound/weapons/gunshot_far.ogg' //Afterall, they do say gunfire sounds like a small explosion from afar
	var/fire_sound_dist = 7 //How far before we can only hear the sound from afar. Consider as the loudness of the gun. Set to 0 to disable far sounds completely
	var/obj/item/projectile/in_chamber = null
	var/list/caliber //The ammo types the gun will accept (make sure to set them to = 1)
	var/dampened = 0 //Doesn't reverbate and gunfire is two times quieter
	var/silenced = 0 //No attack messages and gunfire is ten times quieter
	var/recoil = 0 //How much camera shake when shooting. + 1 intensity, exact duration
	var/clumsy_check = 1 //If the gun performs a clumsy check at all
	var/tmp/list/mob/living/target //List of people who are being targeted by this gun
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 //We are trying to shoot ourselves in the mouth
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/automatic = 0 //Used to determine if you can target multiple people. In short if you can get more than one round out of the gun on trigger press
	var/target_fire_once = 1 //See targeting.dm
						//1 for keep shooting until aim is lowered
	var/fire_delay = 2
	var/last_fired = 0

	var/gun_flags = 0

//Helper proc for general rate of fire
/obj/item/weapon/gun/proc/ready_to_fire()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/ready_to_fire() called tick#: [world.time]")
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/process_chambered()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/process_chambered() called tick#: [world.time]")
	return 0

/obj/item/weapon/gun/proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/special_check() called tick#: [world.time]")
	return 1

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag) //We're placing gun on a table or in a backpack
		return
	if(harm_labeled >= min_harm_label) //Harm labelling can be used to sabotage the gun
		user << "<span class='warning'>A label sticks the trigger to the trigger guard!</span>"
		return
	if(user && user.client && user.client.gun_mode && !(A in target)) //Using the hostage targetting system. Need to pick up the target
		prefire(A,user,params, "struggle" = struggle) //See targeting.dm
	else //We already have a target, or we are free-firing. So fire away
		Fire(A,user,params, "struggle" = struggle)

/obj/item/weapon/gun/proc/isHandgun()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/isHandgun() called tick#: [world.time]")
	return 1

//We are now firing this gun, we are
/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/Fire() called tick#: [world.time]")

	if(mouthshoot) //We are currently attempting suicide
		perform_firearm_suicide(user) //Do it
		mouthshoot = 0
		return

	//Clumsy users risk being knocked out by the recoil, which is bad
	//Exclude lasertag guns from the M_CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			if((M_CLUMSY in C.mutations) && prob(50)) //General case
				C.visible_message("<span class='warning'>\The [C] accidentally drops \the [src] while trying to jam the trigger and stumbles.</span>", \
				"<span class='danger'>You accidentally drop \the [src] while trying to fire and stumble.</span>")
				C.drop_item(src)
				C.Stun(5)
				return

	if(!user.IsAdvancedToolUser() || isMoMMI(user) || M_HULK in user.mutations) //All species and mutation-related checks, outside of clumsy
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/external/a_hand = H.get_active_hand_organ()
		if(!a_hand.can_use_advanced_tools())
			user << "<span class='warning'>Your [a_hand.name] doesn't have the dexterity to do this!</span>"
			return

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if(!istype(targloc) || !istype(curloc))
		return

	if(!special_check(user)) //The special check fails here, if defined
		return

	if(!ready_to_fire()) //We cannot fire yet, calm down
		return

	if(!process_chambered()) //Check what is chambered
		playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1) //It's empty hon'
		visible_message("<span class='warning'>*click*</span>")

	if(!in_chamber) //The chamber is empty, despite our check. Sanity
		return

	//We log here, we can alo confirm we shoot starting from here here
	if(!istype(src, /obj/item/weapon/gun/energy/laser/redtag) && !istype(src, /obj/item/weapon/gun/energy/laser/bluetag))
		log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[in_chamber.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])[struggle ? " due to being disarmed." :""]" )
	in_chamber.firer = user

	if(user.zone_sel) //The bullet will strike where the user aimed it
		in_chamber.def_zone = user.zone_sel.selecting
	else
		in_chamber.def_zone = "chest"

	if(targloc == curloc) //This should have been handled by attack(), sanity check
		in_chamber.damage *= 1.3
		user.bullet_act(in_chamber)
		if(!recoil) //Don't waste a call for recoil = 0
			shake_camera(user, recoil + 1, recoil)
		returnToPool(in_chamber)
		update_icon()
		return

	if(recoil) //We only make those checks if that weapon has any recoil
		spawn()
			shake_camera(user, recoil + 1, recoil) //Shake the camera
		if(user.locked_to && isobj(user.locked_to) && !user.locked_to.anchored) //If we are locked to an unanchored object
			var/direction = get_dir(user, target)
			spawn()
				var/obj/B = user.locked_to
				var/movementdirection = turn(direction, 180)
				for(var/i = 0; i <= recoil * 3; i++) //We are knocked away three times the recoil's value
					var/inertial_dampening = round(1 + (i * 0.75)) //Linear, but should do. Remember sleep(1) is 1/10th of a second
					B.Move(get_step(user, movementdirection), movementdirection)
					sleep(inertial_dampening)

		/*
		if(M_CLUMSY in user.mutations) //Recoil case. You absolutely cannot fire recoil weapons while clumsy
			user.visible_message("<span class='warning'>\The [user] is knocked clean off \his feet from \the [src]'s recoil.</span>", \
			"<span class='danger'>\The [src]'s recoil knocks you clean off your feet.</span>")
			user.take_organ_damage(0, 25)
			user.drop_item(src)
			user.Stun(10) //Takes a while to get up
		 */

		if((istype(user.loc, /turf/space)) || (user.areaMaster.has_gravity == 0)) //Inertial knockback. For now doesn't scale with knockback, due to how inertia is coded
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	if(silenced) //The gun has been silenced. (Somewhat) silent but deadly
		playsound(user, fire_sound, 10, 1)
	else //Gun isn't silenced. We need to fire a few more things
		playsound(user, fire_sound, dampened ? 50 : 100, 1)
		user.visible_message("<span class='[dampened ? "warning":"danger"]'>[user] fires \the [src][reflex ? " by reflex":""]!</span>", \
		"<span class='[dampened ? "warning":"danger"]'>You fire \the [src][reflex ? "by reflex":""]!</span>", \
		"<span class='danger'>You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!</span>")
		if(!dampened && fire_sound_dist) //Reverbation. Aka the whole station can hear it. Should be standardized, but for now ported from explosion.dm
			for(var/mob/M in player_list)
				if(M.client)
					var/turf/M_turf = get_turf(M)
					var/turf/user_turf = get_turf(user)
					var/dist = get_dist(M_turf, user_turf)
					if(M_turf && M_turf.z == user_turf.z && dist >= fire_sound_dist)
						playsound(M, fire_sound_far, 50, 1)

	//We are done with the special effects fluff. Now for the actual firing-a-projectile action
	in_chamber.original = target
	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.shot_from = src
	in_chamber.silenced = silenced
	//in_chamber.dampened = dampened //TODO: Recheck for inclusion
	in_chamber.current = curloc
	in_chamber.OnFired() //Special effects when fired
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
			in_chamber.process() //At this point, we actually fire the damn thing
	sleep(1)
	in_chamber = null
	update_icon()

	/*
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()
	 */

//We can only fire if the bullet says it's good to go, if there is any at all
/obj/item/weapon/gun/proc/can_fire()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/can_fire() called tick#: [world.time]")
	return process_chambered()

//A bunch of calculations to make sure we can actually hit our intended target
/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/proc/can_hit() called tick#: [world.time]")
	return in_chamber.check_fire(target, user)

//If we are adjacent to our target, we are either killing ourselves or shooting point-blank
/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	//Suicide handling.
	if(M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		if(istype(user.wear_mask, /obj/item/clothing/mask/happy))
			user << "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>"
			return
		mouthshoot = 1
		user.visible_message("<span class='warning'>[user] starts sticking \his [src.name] in \his mouth, ready to pull the trigger.</span>", \
		"<span class='warning'>You start sticking your [src.name] in your mouth. You give yourself ten seconds to pull the trigger.</span>")
		spawn(100) //Ten seconds to pull the trigger
			if(mouthshoot) //The flag was not cleared, we haven't suicided in time
				user.visible_message("<span class='notice'>[user] decides to pull \his [src.name] out of \his mouth. He must have decided life was worth living.</span>", \
				"<span class='notice'>You decide to pull your [src.name] out of your mouth. Life is worth living afterall.</span>")
				mouthshoot = 0
				return
		return

	//Point blank shooting if on harm intent or target we were targeting.
	if(process_chambered())
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'>\The [user] fires \the [src] point blank at [M]!</span>")
			in_chamber.damage *= 1.3
			src.Fire(M,user, 0, 0, 1)
			return
		else if(target && M in target)
			src.Fire(M,user, 0, 0, 1) //Otherwise, shoot!
			return
		else
			return ..() //Allows a player to choose to melee instead of shoot, by being on any intent other than harm.
	else
		return ..() //Our weapon is empty, plan B

/obj/item/weapon/gun/proc/perform_firearm_suicide(var/mob/living/user as mob)

	//Too late to go back now
	if(process_chambered())
		user.visible_message("<span class='danger'>[user] pulls \the [src]'s trigger.</span>", \
		"<span class='danger'>You pull \the [src]'s trigger. It all comes tumbling down.</span>", \
		"<span class='danger'>You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!</span>")

		if(recoil) //We only make those checks if that weapon has any recoil
			spawn()
				shake_camera(user, recoil + 1, recoil) //Shake the camera

		if(silenced)
			playsound(user, fire_sound, 10, 1)
		else
			playsound(user, fire_sound, dampened ? 50 : 100, 1)
			if(!dampened && fire_sound_dist) //Reverbation. Aka the whole station can hear it. Should be standardized, but for now ported from explosion.dm
				for(var/mob/M in player_list)
					if(M.client)
						var/turf/M_turf = get_turf(M)
						var/turf/user_turf = get_turf(user)
						var/dist = get_dist(M_turf, user_turf)
						if(M_turf && M_turf.z == user_turf.z && dist >= fire_sound_dist)
							playsound(M, fire_sound_far, 50, 1)


		in_chamber.on_hit(user) //If there are any on_hit effects, do it now
		if(!in_chamber.nodamage) //Suicide shoots are extremely damaging. You would need a very low caliber to not die from it
			user.apply_damage(in_chamber.damage * 5, in_chamber.damage_type, "head", used_weapon = "Point blank shot through the mouth into the palate with \a [in_chamber]")
		else //Very funny, now hit the fucking ground
			user << "<span class='danger'>Ow.</span>"
			user.apply_effect(110, AGONY, 0)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.Paralyse(20)
		returnToPool(in_chamber)
		mouthshoot = 0
		return
	else
		playsound(get_turf(src), 'sound/weapons/empty.ogg', 100, 1) //It's empty hon'
		visible_message("<span class='warning'>*click*</span>")
		mouthshoot = 0
		return
