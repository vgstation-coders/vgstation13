/obj/item/weapon/grenade/holy
	name = "holy hand grenade"
	desc = "One of the many sacred relics made for blowing thine enemies to tiny bits."
	icon_state = "holy_grenade"
	det_time = 3 SECONDS

/obj/item/weapon/grenade/holy/attackby(obj/item/weapon/W, mob/user)
	if(W.is_screwdriver(user))
		to_chat(user, "<span class = 'warning'>The timer seems locked to three seconds.</span>")
		return
	..()

/obj/item/weapon/grenade/holy/prime()
	..()
	playsound(src, 'sound/misc/adminspawn.ogg', 75, 0, 1)
	sleep(15)
	for(var/mob/living/carbon/human/H in view(4,get_turf(src)))
		if(isvampire(H) || iscultist(H))    
			H.dust()
	for(var/mob/living/simple_animal/C in view(4,get_turf(src)))
		if(C.supernatural)
			C.death()
	explosion(get_turf(src), 0, 0, 2, 3)
	qdel(src)
