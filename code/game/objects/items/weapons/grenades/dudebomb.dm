/obj/item/weapon/grenade/dudebomb
	name = "dudebomb"
	icon_state = "dudebomb"
	item_state = "dudebomb"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_COMBAT + "=2"
	det_time = 12 SECONDS
	armsound = 'sound/weapons/dudebomb.ogg'

/obj/item/weapon/grenade/dudebomb/prime()
	var/turf/you_vile_cur = get_turf(src)
	if(!you_vile_cur)
		return
	var/list/dudes_to_bomb = get_all_mobs_in_dview(you_vile_cur, ignore_types = list(/mob/living/carbon/brain, /mob/living/silicon))
	for(var/mob/living/M in dudes_to_bomb)
		if(ishuman(M))
			var/mob/living/carbon/human/GOGOGOGOGOGO = M
			if(!GOGOGOGOGOGO.stat)
				GOGOGOGOGOGO.say("Yeah, Gal-O Sengen.")
			spawn(2 SECONDS)
				var/turf/T = get_turf(GOGOGOGOGOGO)
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,null,anim_plane = MOB_PLANE)
				GOGOGOGOGOGO.GALize()
	qdel(src)

/obj/item/weapon/grenade/dudebomb/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='attack'>You prime \the [name]! [det_time/10] seconds!</span>")

			activate(user, FALSE)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

/obj/item/weapon/grenade/dudebomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	to_chat(user, "<span class = 'warning'>YEAH, GAL-O SENGEN.</span>")
