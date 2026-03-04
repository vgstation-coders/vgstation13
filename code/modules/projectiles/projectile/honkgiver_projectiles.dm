//It like a taser bolt but without the stun. It makes people scream and walk slow.
/obj/item/projectile/energy/electrode/scream_shot
	name = "scream shot"
	icon_state = "spark"
	stun = 0
	weaken = 0
	agony = 0
	stutter = 5
	jittery = 10
	hitsound = 'sound/weapons/taserhit.ogg'
	movement_speed_reduction = -0.25 //this makes you faster when you get shot!
	speed_reduction_duration = 15
	has_special_suicide = TRUE //will override the default mouth shot suicide.

/obj/item/projectile/energy/electrode/robot_on_hit(var/mob/living/atarget, var/blocked)
	atarget.emote("buzz", TRUE)
	..()

//It's big, its flashy, it's noisy, and it does absolutely fuck all except make the victim deaf. Also may burn off victim's facial hair.
/obj/item/projectile/beam/doomlazorz
	name = "ultra-lethal-death-laser of doom"
	icon_state = "ultradeathray"
	kill_count = 500
	phase_type = PROJREACT_MOBS|PROJREACT_WINDOWS|PROJREACT_BLOB
	penetration = -1
	damage = 0
	nodamage = 1
	has_special_suicide = TRUE

/obj/item/projectile/beam/doomlazorz/custom_mouthshot(mob/living/user)
	var/datum/organ/external/head/user_head = user.get_organ(LIMB_HEAD)
	user_head.dust()
	var/suicidesound = pick('sound/misc/suicide/suicide1.ogg','sound/misc/suicide/suicide2.ogg','sound/misc/suicide/suicide3.ogg','sound/misc/suicide/suicide4.ogg','sound/misc/suicide/suicide5.ogg','sound/misc/suicide/suicide6.ogg')
	playsound(src, pick(suicidesound), 30, channel = 125)
	log_attack("<font color='red'>[key_name(user)] committed suicide with \the [src].</font>")
	user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] committed suicide with \the [src]</font>"

/obj/item/projectile/beam/doomlazorz/to_bump(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		doomify(L)
		return 0
	else
		return ..()

/obj/item/projectile/beam/doomlazorz/on_hit(var/atom/A, var/blocked = 0)
	if(isliving(A))
		var/mob/living/L = A
		doomify(L)
	..()

/obj/item/projectile/beam/doomlazorz/proc/doomify(mob/living/L)
	var/prot_value = 0
	if(!L.earprot())
		L.ear_deaf += 10
		prot_value++
	if(!L.eyecheck())
		L.flash_eyes(affect_silicon = 1)
		L<<sound('sound/effects/ear_ring_single.ogg') //play ear ringing for the target
		prot_value++
	if(prot_value<2)
		shake_camera(L,6,6)
		L.audible_scream()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.species.name == "Human")
			if(prob(50))
				var/lost_hair = FALSE
				if(!(H.my_appearance.h_style == "Bald") && (H.get_body_part_coverage(MOUTH)))
					H.my_appearance.h_style = "Bald"
					lost_hair = TRUE
				if(!(H.my_appearance.f_style == "Shaved") && (H.get_body_part_coverage(HEAD)))
					H.my_appearance.f_style = "Shaved"
					lost_hair = TRUE
				if(lost_hair)
					L.visible_message("<span class='warning'>[H.name]'s facial hair is vaporized away by the intense blast of energy!</span>")
					H.update_hair()
			if(prob(0.01))//one-in-ten-thousand chance
				L.visible_message("<span class='danger'>[H.name]'s flesh is vaporized into dust by the super intense blast of energy!</span>")
				H.makeSkeleton()
				H.knockdown += 4
				H.stuttering += 10


//A bouncy ball that bounces off virtually everything. It deals one tile of knockback when it hits a living mob.
/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball
	name = "bouncy ball shot"
	icon_state = "ball"
	damage = 0
	stun = 0
	weaken = 0
	bounces = -1
	agony = 0
	nodamage = 1
	penetration = 0
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	kill_count = 150
	hitsound = "sound/effects/boink.ogg"
	bounce_sound = "sound/effects/boink.ogg"
	embed = 0
	has_special_suicide = TRUE

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball/on_hit(var/atom/target, var/blocked = 0)
	..()
	if(isliving(target))
		var/mob/living/M = target
		if(M.canmove)
			var/turf/T = get_turf(src)
			var/turf/W = get_turf(target)
			var/destination = get_dir(T,W)
			step(M, destination)

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball/admin_warn(mob/living/M)
	return 0 //don't log it will spam admin logs and they shouldn't damage anyways

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball/bump_original_check()
	return

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball/custom_mouthshot(mob/living/user)
	playsound(src, 'sound/misc/balloon_pop.ogg', 75, 1)
	flick("ball_pop",src)
	user.gib(FALSE,FALSE)
	log_attack("<font color='red'>[key_name(user)] committed suicide with \the [src].</font>")
	user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] committed suicide with \the [src]</font>"

//a shot of water + a random but harmless chem. Slips people that walk over the water.
/obj/item/projectile/beam/liquid_stream/honkgiver_stream
	nodamage = 1
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	var/list/random_liquid_list = list(HONKSERUM, BUSTANUT, LOCUTOGEN, ANTHRACENE)

/obj/item/projectile/beam/liquid_stream/honkgiver_stream/New(atom/A, var/t_range=3, var/m_color, var/m_alpha=255)
	..(A)
	create_reagents(20)
	reagents.add_reagent(WATER, 10)
	reagents.add_reagent(pick(random_liquid_list), 10)
	travel_range = t_range
	beam_color = pick(random_color_list)
	alpha = m_alpha
	travel_range = 7

//A fast moving projectile pie. It's fired in a burst with a some spread. Great for blinding a crowd.
/obj/item/projectile/bullet/pie_shot
	name = "high-velocity projectile pie"
	icon_state = "pie"
	penetration = 0
	damage = 0
	projectile_speed = 0.5
	custom_impact = 1
	embed = 0
	nodamage = 1
	has_special_suicide = TRUE

/obj/item/projectile/bullet/pie_shot/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/obj/item/weapon/reagent_containers/food/snacks/pie/empty/no_throwforce/P = new  /obj/item/weapon/reagent_containers/food/snacks/pie/empty/no_throwforce
	P.throw_impact(target)

/obj/item/projectile/bullet/pie_shot/custom_mouthshot(mob/living/user)
	on_hit(user,0)

//A high velocity banana peel that flies straight through mobs. applies a banana slip on everything it hits.
/obj/item/projectile/bullet/peel_shot
	name = "high-velocity banana peel"
	icon_state = "peel"
	damage = 0
	embed = 0
	projectile_speed = 0.5 							//THE PEEL SHALL FLY
	kill_count = 100 								//ALL UPRIGHT SHALL LIE
	phase_type = PROJREACT_MOBS					 	//NO FOOT NOR HEEL
	penetration = 100 								//CAN STOP THIS PEEL
	custom_impact = 1
	nodamage = 1
	has_special_suicide = TRUE

/obj/item/projectile/bullet/peel_shot/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/obj/item/weapon/bananapeel/B = new  /obj/item/weapon/bananapeel/
	if(istype(target,/atom/movable))
		B.handle_slip(target)
	qdel(B)

/obj/item/projectile/bullet/peel_shot/custom_mouthshot(mob/living/user)
	//gibs user's head and continues to fly in direction opposite of facing.
	var/datum/organ/external/head/user_head = user.get_organ(LIMB_HEAD)
	user_head.explode()
	var/obj/item/projectile/bullet/peel_shot/PS = new /obj/item/projectile/bullet/peel_shot(get_turf(user))
	PS.starting = get_turf(user)
	PS.current = get_turf(user)
	PS.original = get_step(user, opposite_dirs[user.dir])
	PS.target = get_step(user, opposite_dirs[user.dir])
	PS.OnFired(PS.original)
	PS.yo = PS.original.y - PS.current.y
	PS.xo = PS.original.x - PS.current.x
	PS.process()
	log_attack("<font color='red'>[key_name(user)] committed suicide with \the [src].</font>")
	user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] committed suicide with \the [src]</font>"
