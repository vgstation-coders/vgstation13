//It like a taser bolt but without the stun. It makes people scream and walk slow.
/obj/item/projectile/energy/electrode/scream_shot
	name = "scream shot"
	icon_state = "spark"
	stun = 0
	weaken = 0
	stutter = 5
	jittery = 10
	hitsound = 'sound/weapons/taserhit.ogg'
	movement_speed_reduction = 0.75
	speed_reduction_duration = 15

//It's big, its flashy, it's noisy, and it does absolutely fuck all except make you deaf.
/obj/item/projectile/beam/doomlazorz
	name = "ultra-lethal-death-laser of doom"
	icon_state = "ultradeathray"
	kill_count = 500
	phase_type = PROJREACT_MOBS|PROJREACT_WINDOWS|PROJREACT_BLOB
	penetration = -1
	damage = 0
	nodamage = 1
	//custom_impact = 1

/obj/item/projectile/beam/doomlazorz/to_bump(atom/A)
	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself
	if(isliving(A))
		var/mob/living/L = A
		doomify(L)
	else
		return ..()

/obj/item/projectile/beam/doomlazorz/proc/doomify(var/mob/living/L, var/blocked = 0)
	var/prot_value = 0
	if(!L.earprot())
		L.ear_deaf += 10
		to_chat(L, "<span class='notice'>Your ears ring!</span>")
		prot_value++
	if(!L.eyecheck())
		L.flash_eyes(affect_silicon = 1)
		L<<sound('sound/effects/ear_ring_single.ogg') //play ear ringing for the target
		prot_value++
	if(prot_value<2)
		shake_camera(L,6,6)
		L.audible_scream()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.species.name == "Human" && prob(50))
			var/lost_hair = FALSE
			if(!(H.my_appearance.h_style == "Bald") && (H.get_body_part_coverage(MOUTH)))
				H.my_appearance.h_style = "Bald"
				lost_hair = TRUE
			if(!(H.my_appearance.f_style == "Shaved") && (H.get_body_part_coverage(HEAD)))
				H.my_appearance.f_style = "Shaved"
				lost_hair = TRUE
			if(lost_hair)
				visible_message("<span class='warning'>All of [H.name]'s facial hair is vaporized away by the intense blast of energy!</span>")
				H.update_hair()

//TODO make it pop when it is finally destroyed!
//A bouncy ball that bounces off virtually everything. It deals one tile of knockback when it hits a living mob and screen shakes them.
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
	//decay_type = //this is what drops when it ceases to exist// drop pop effect

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball/on_hit(var/atom/target, var/blocked = 0)
	..()
	if(isliving(target))//knockback on hit
		var/turf/T = get_turf(src)
		var/turf/W = get_turf(target)
		var/destination = get_dir(T,W)
		var/mob/living/M = target
		M.throw_at(get_edge_target_turf(target,destination),1,1)

//a shot of water + honkserum. Slips people that walk over the water, and if you hit them in the mouth they'll honk like a clown.
/obj/item/projectile/beam/liquid_stream/honkgiver_stream

/obj/item/projectile/beam/liquid_stream/honkgiver_stream/New(atom/A, var/t_range=3, var/m_color, var/m_alpha=255)
	..(A)
	create_reagents(20)
	reagents.add_reagent(WATER, 10)
	reagents.add_reagent(HONKSERUM, 10)
	travel_range = t_range
	beam_color = m_color
	alpha = m_alpha
	travel_range = 7

//A fast moving pie. Is fired in rapid fire mode where it has a little bit of spread. great for blinding a crowd.
/obj/item/projectile/bullet/pie_shot
	name = "high-velocity projectile pie"
	icon_state = "pie"
	penetration = 0
	damage = 0
	projectile_speed = 0.5
	custom_impact = 1
	embed = 0

/obj/item/projectile/bullet/pie_shot/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new  /obj/item/weapon/reagent_containers/food/snacks/pie
	P.throw_impact(target)

//A high velocity banana peel that flies straight through mobs. applies a banana slip on everything it hits.
/obj/item/projectile/bullet/peel_shot
	//banana peel shot keeps going!
	name = "high-velocity banana peel"
	icon_state = "peel"
	damage = 0
	embed = 0
	projectile_speed = 0.5 							//THE PEEL SHALL FLY
	kill_count = 100 								//ALL UPRIGHT SHALL LIE
	phase_type = PROJREACT_MOBS					 	//NO FOOT NOR HEEL
	penetration = 100 								//CAN STOP THIS PEEL
	custom_impact = 1

/obj/item/projectile/bullet/peel_shot/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/obj/item/weapon/bananapeel/B = new  /obj/item/weapon/bananapeel/
	if(istype(target,/atom/movable))
		B.handle_slip(target)
	qdel(B)
