/*  Glow Orb
As the name implies, just exists to glow a slight blue light.

If touched by somebody on help intent, will attempt to follow them until they move out of view.

If attacked or hit by anything, powers down back into /obj/item/weapon/glow_orb

If hit by lightning, overpowers and explodes like a flashbang, blinding everyone in immediate vicinity
*/

/mob/living/simple_animal/hostile/glow_orb
	name = "strange glowing orb"
	desc = "A hovering glowing orb, drifting to-and-fro lazily under its own power."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "glow_stone_active"
	icon_living = "glow_stone_active"
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_LIGHTING_LAYER
	health = 5
	maxHealth = 5
	density = 0 //people can pass over it

	attacktext = "illuminates"
	attack_sound = 'sound/weapons/orb_shine.ogg'
	melee_damage_lower = 0
	melee_damage_upper = 0

	response_help = "gently touches"
	response_disarm = "shakes"
	response_harm = "shatters"

	supernatural = 1
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = T0C+1768 //Melting point of platinum

	wander = 0
	mob_property_flags = MOB_CONSTRUCT

	var/following //Who are we following
	var/scan_time = 3 SECONDS
	var/last_scan = 0
	var/unstable = 0

	blooded = FALSE


/mob/living/simple_animal/hostile/glow_orb/New()
	..()
	set_light(4,1,"#0068B2")

/mob/living/simple_animal/hostile/glow_orb/Life()
	..()
	if(unstable)
		walk(src, 0)
		return
	if(following && last_scan < world.time+scan_time)
		var/following_found
		var/list/can_see = view(src, vision_range)
		for(var/mob/living/L in can_see)
			if(L == following)
				following_found = 1
				break
		if(!following_found)
			set_light(4, 1, "#0068B2")
			following = null

/mob/living/simple_animal/hostile/glow_orb/CanAttack(atom/new_target)
	if(unstable)
		return 0
	if(following && new_target == following)
		return 1
	return 0

/mob/living/simple_animal/hostile/glow_orb/AttackingTarget()
	return

/mob/living/simple_animal/hostile/glow_orb/Process_Spacemove(var/check_drift = 0)
	return 1


/mob/living/simple_animal/hostile/glow_orb/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == I_HELP)
		if(M != following)
			to_chat(M, "<span class = 'notice'>\The [src] bobs excitedly, and glides towards you.</span>")
			following = M
			set_light(4, 1, "#68E8FF")
		else if(M == following)
			to_chat(M, "<span class = 'notice'>\The [src] droops idly as it maintains position.</span>")
			following = null
			set_light(4, 1, "#0068B2")
			walk(src,0)
	else
		death()

	..()

/mob/living/simple_animal/hostile/glow_orb/death(var/gibbed = FALSE)
	..(gibbed)
	visible_message("<span class = 'notice'>\The [src] grows dim as it falls to the ground.</span>")
	flick("glow_stone_deactivate", src)
	spawn(10)
		playsound(src, 'sound/weapons/orb_deactivate.ogg', 50,1)
		kill_light()
		new/obj/item/weapon/glow_orb(get_turf(src))
		qdel(src)
		return

/mob/living/simple_animal/hostile/glow_orb/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam/lightning/spell) || istype(P, /obj/item/projectile/energy/electrode))
		if(!unstable)
			visible_message("<span class = 'warning'>\The [src]'s light grows greater in intensity, and begins to shake uncontrollably.</span>")
			set_light(world.view,3,"#ff2014")
			detonate()
		return

	return ..()

/mob/living/simple_animal/hostile/glow_orb/DestroySurroundings()
	if(!melee_damage_lower)
		return //It's a floating light bulb, it's not going to break a window
	..()
/mob/living/simple_animal/hostile/glow_orb/proc/detonate()
	unstable = 1
	playsound(src,'sound/weapons/inc_tone.ogg', 50, 1)
	flick("glow_stone_critical", src)
	status_flags &= ~GODMODE
	spawn(2 SECONDS)
		var/turf/T = get_turf(src)
		if(!T)
			return
		var/list/mobs_to_flash_and_bang = get_all_mobs_in_dview(T, ignore_types = list(/mob/living/carbon/brain, /mob/living/silicon/ai))


		for(var/mob/living/M in mobs_to_flash_and_bang)
				//Checking for protections
			var/eye_safety = 0
			var/ear_safety = 0


			eye_safety = M.eyecheck()
			ear_safety = M.earprot() //some arbitrary measurement of ear protection, I guess? doesn't even matter if it goes above 1

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.head, /obj/item/clothing/head/helmet))
					ear_safety += 1
			if(M_HULK in M.mutations)
				ear_safety += 1
			if(istype(M.loc, /obj/mecha))
				ear_safety += 1

			//Flashing everyone
			if(eye_safety < 1)
				M.flash_eyes(visual = 1, affect_silicon = 1)
				M.Stun(10)
				M.Knockdown(10)

			//Now applying sound
			if(!ear_safety)
				to_chat(M, "<span class='userdanger'>BANG</span>")
				playsound(src, 'sound/effects/bang.ogg', 60, 1)
			else
				to_chat(M, "<span class='danger'>BANG</span>")
				playsound(src, 'sound/effects/bang.ogg', 25, 1)

			if((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
				if(ear_safety > 0)
					M.Stun(2)
					M.Knockdown(2)
				else
					M.Stun(10)
					M.Knockdown(10)
					if ((prob(14) || (M == src.loc && prob(70))))
						M.ear_damage += rand(1, 10)
					else
						M.ear_damage += rand(0, 5)
						M.ear_deaf = max(M.ear_deaf,15)

			else if(get_dist(M, T) <= 5)
				if(!ear_safety)
					M.Stun(8)
					M.Knockdown(8)
					M.ear_damage += rand(0, 3)
					M.ear_deaf = max(M.ear_deaf,10)

			else if(!ear_safety)
				M.Stun(4)
				M.Knockdown(4)
				M.ear_damage += rand(0, 1)
				M.ear_deaf = max(M.ear_deaf,5)

		qdel(src)
