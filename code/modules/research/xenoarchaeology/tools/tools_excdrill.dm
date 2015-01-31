/obj/item/weapon/pickaxe/excavationdrill
	name = "excavation drill"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	item_state = "surgicaldrill"
	excavation_amount = 15
	digspeed = 30
	desc = "Handheld drill capable of perforating rocks at various depths (1-30 centimeters)."
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "drilling"
	w_class = 1
	attack_verb = list("drilled")
	
/obj/item/weapon/pickaxe/excavationdrill/attack_self(mob/user as mob)
	var/depth = input("Put the desired depth (1-30 centimeters).", "Set Depth", 30) as num
	if(depth>30 || depth<1)
		user << "<span class='notice'>Invalid depth.</span>"
		return
	excavation_amount = depth/2
	user << "<span class='notice'>You set the depth to [depth]cm.</span>"