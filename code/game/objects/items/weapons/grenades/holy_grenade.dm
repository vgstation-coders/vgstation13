#define WIGGLE_ROOM 0.5 SECONDS
#define COUNT_TO 3 SECONDS 	

/obj/item/weapon/grenade/holy
	name = "holy hand grenade"
	desc = "One of the many sacred relics made for blowing thine enemies to tiny bits."
	icon_state = "holy_grenade"
	det_time = 3.5 SECONDS
	armsound = 'sound/weapons/vampkiller.ogg'
	var/activated_at 

/obj/item/weapon/grenade/holy/attackby(obj/item/weapon/W, mob/user)
	if(W.is_screwdriver(user))
		to_chat(user, "<span class = 'warning'>There's no timer to change!</span>")
		return
	..()

/obj/item/weapon/grenade/holy/activate()
	activated_at = world.time
	..()

/obj/item/weapon/grenade/holy/prime()
	..()
	playsound(src, 'sound/misc/adminspawn.ogg', 75, 0, 1)
	sleep(15)
	for(var/mob/living/carbon/human/H in view(4,get_turf(src)))
		if(isvampire(H) || iscultist(H))    
			H.reagents.add_reagent(HOLYWATER, 3)
			H.Stun(10)
			H.Knockdown(10)
			H.flash_eyes(visual = 1)
	for(var/mob/living/simple_animal/C in view(4,get_turf(src)))
		if(C.supernatural)
			C.death()
	explosion(get_turf(src), 0, 0, 4, 3)
	qdel(src)

/obj/item/weapon/grenade/holy/dropped(mob/user)
	if(!active)
		return ..()
	var/thrown_when = world.time - activated_at
	if(thrown_when > COUNT_TO + WIGGLE_ROOM || thrown_when < COUNT_TO - WIGGLE_ROOM)
		to_chat(user, "<span class='warning'>You didn't count to [num2text(COUNT_TO/10)].</span>")
		explosion(get_turf(src), 0, 0, 1, 2)
		qdel(src)
	else
		..()

/obj/item/weapon/grenade/holy/attack_self(mob/user as mob)
	if(iscultist(user) || isvampire(user))
		playsound(src, 'sound/misc/adminspawn.ogg', 75, 0, 1)
		to_chat(user, "<span class='warning'>The holy hand grenade is too sacred for you to use!</span>")
		user.Stun(10)
		user.Knockdown(10)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.flash_eyes(visual = 1)
		return
	..()



#undef COUNT_TO
#undef WIGGLE_ROOM
