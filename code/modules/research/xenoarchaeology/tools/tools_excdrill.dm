/obj/item/weapon/pickaxe/excavationdrill
	name = "excavation drill"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "excavationdrill0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	item_state = "excavationdrill"
	excavation_amount = 0.5
	digspeed = 30
	desc = "Basic archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The tip is adjustable from 1 to 30 cms."
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "drilling"
	force = 15.0
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	attack_verb = list("drills")
	hitsound = 'sound/weapons/circsawhit.ogg'

/obj/item/weapon/pickaxe/excavationdrill/attack_self(mob/user as mob)
	var/depth = input("Put the desired depth (1-30 centimeters).", "Set Depth", excavation_amount*2) as num
	if(depth>30 || depth<1)
		to_chat(user, "<span class='notice'>Invalid depth.</span>")
		return
	excavation_amount = depth/2
	to_chat(user, "<span class='notice'>You set the depth to [depth]cm.</span>")
	if (depth<4)
		icon_state = "excavationdrill0"
	else if (depth >=4 && depth <8)
		icon_state = "excavationdrill1"
	else if (depth >=8 && depth <12)
		icon_state = "excavationdrill2"
	else if (depth >=12 && depth <16)
		icon_state = "excavationdrill3"
	else if (depth >=16 && depth <20)
		icon_state = "excavationdrill4"
	else if (depth >=20 && depth <24)
		icon_state = "excavationdrill5"
	else if (depth >=24 && depth <28)
		icon_state = "excavationdrill6"
	else
		icon_state = "excavationdrill7"

/obj/item/weapon/pickaxe/excavationdrill/examine(mob/user)
	..()
	var/depth = excavation_amount*2
	to_chat(user, "<span class='info'>It is currently set at [depth]cm.</span>")

/obj/item/weapon/pickaxe/excavationdrill/adv
	name = "diamond excavation drill"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "Dexcavationdrill0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	item_state = "Dexcavationdrill"
	digspeed = 15
	desc = "Advanced archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The diamond tip is adjustable from 1 to 100 cms."

/obj/item/weapon/pickaxe/excavationdrill/adv/attack_self(mob/user as mob)
	var/depth = input("Put the desired depth (1-100 centimeters).", "Set Depth", excavation_amount*2) as num
	if(depth>100 || depth<1)
		to_chat(user, "<span class='notice'>Invalid depth.</span>")
		return
	excavation_amount = depth/2
	to_chat(user, "<span class='notice'>You set the depth to [depth]cm.</span>")
	if (depth<12)
		icon_state = "Dexcavationdrill0"
	else if (depth >=12 && depth <24)
		icon_state = "Dexcavationdrill1"
	else if (depth >=24 && depth <36)
		icon_state = "Dexcavationdrill2"
	else if (depth >=36 && depth <48)
		icon_state = "Dexcavationdrill3"
	else if (depth >=48 && depth <60)
		icon_state = "Dexcavationdrill4"
	else if (depth >=60 && depth <72)
		icon_state = "Dexcavationdrill5"
	else if (depth >=72 && depth <84)
		icon_state = "Dexcavationdrill6"
	else
		icon_state = "Dexcavationdrill7"