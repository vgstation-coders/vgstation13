/obj/item/weapon/pickaxe/excavationdrill
	name = "excavation drill"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "excavationdrill0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	item_state = "excavationdrill"
	excavation_amount = 1
	toolspeed = 0.3
	desc = "Basic archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The tip is adjustable from 1 to 15 cms."
	toolsounds = list('sound/weapons/thudswoosh.ogg')
	drill_verb = "drilling"
	force = 15.0
	w_class = W_CLASS_SMALL
	w_type = RECYK_ELECTRONIC
	attack_verb = list("drills")
	hitsound = 'sound/weapons/circsawhit.ogg'

/obj/item/weapon/pickaxe/excavationdrill/attack_self(mob/user as mob)
	var/depth = round(input("Put the desired depth (1-15 centimeters).", "Set Depth", excavation_amount) as num)
	if(depth>15 || depth<1)
		to_chat(user, "<span class='notice'>Invalid depth.</span>")
		return
	excavation_amount = depth
	to_chat(user, "<span class='notice'>You set the depth to [depth]cm.</span>")
	if (depth<2)
		icon_state = "excavationdrill0"
	else if (depth >=2 && depth <4)
		icon_state = "excavationdrill1"
	else if (depth >=4 && depth <6)
		icon_state = "excavationdrill2"
	else if (depth >=6 && depth <8)
		icon_state = "excavationdrill3"
	else if (depth >=8 && depth <10)
		icon_state = "excavationdrill4"
	else if (depth >=10 && depth <12)
		icon_state = "excavationdrill5"
	else if (depth >=12 && depth <14)
		icon_state = "excavationdrill6"
	else
		icon_state = "excavationdrill7"

/obj/item/weapon/pickaxe/excavationdrill/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It is currently set at [excavation_amount]cm.</span>")

/obj/item/weapon/pickaxe/excavationdrill/adv
	name = "diamond excavation drill"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "Dexcavationdrill0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	item_state = "Dexcavationdrill"
	toolspeed = 0.15
	desc = "Advanced archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision. The diamond tip is adjustable from 1 to 50 cms."

/obj/item/weapon/pickaxe/excavationdrill/adv/attack_self(mob/user as mob)
	var/depth = round(input("Put the desired depth (1-50 centimeters).", "Set Depth", excavation_amount) as num)
	if(depth>50 || depth<1)
		to_chat(user, "<span class='notice'>Invalid depth.</span>")
		return
	excavation_amount = depth
	to_chat(user, "<span class='notice'>You set the depth to [depth]cm.</span>")
	if (depth<6)
		icon_state = "Dexcavationdrill0"
	else if (depth >=6 && depth <12)
		icon_state = "Dexcavationdrill1"
	else if (depth >=12 && depth <18)
		icon_state = "Dexcavationdrill2"
	else if (depth >=18 && depth <24)
		icon_state = "Dexcavationdrill3"
	else if (depth >=24 && depth <30)
		icon_state = "Dexcavationdrill4"
	else if (depth >=30 && depth <36)
		icon_state = "Dexcavationdrill5"
	else if (depth >=36 && depth <42)
		icon_state = "Dexcavationdrill6"
	else
		icon_state = "Dexcavationdrill7"
