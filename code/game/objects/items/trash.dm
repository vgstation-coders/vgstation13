//Litter, and generally things that aren't particularly useful in any fashion
//Used to be exclusive to items that can be put in the trash bag, but now everything is trash to the trash bag

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = 1.0
	desc = "This is rubbish."
	w_type = NOT_RECYCLABLE
	autoignition_temperature = AUTOIGNITION_PAPER //This is dumb, but it's better than nothing
	fire_fuel = 1
	attack_verb = list("slapped", "whacked", "tapped")

/obj/item/trash/bustanuts
	name = "\improper Busta-Nuts"
	icon_state = "busta_nut"

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "\improper Cheesie Honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "\improper Syndicakes"
	icon_state = "syndi_cakes"

/obj/item/trash/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar"
	icon_state = "danbar"

/obj/item/trash/danitos
	name = "\improper Danitos"
	icon_state = "danitos"

/obj/item/trash/waffles
	name = "waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "plate"
	desc = "The disgruntled's consumer best weapon"
	icon_state = "plate"
	throwforce = 15 //Hits really fucking hard, aerodymanics and stuff
	throw_speed = 6 //It's fast too, blame flying saucers
	attack_verb = list("bludgeoned", "whacked", "slashed")

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	desc = "When a large ham isn't enough"
	icon_state = "tray"
	force = 10 //WAM
	throwforce = 7 //DOUBLE WAM
	throw_speed = 3
	throw_range = 4 //Good luck sending it anywhere fast
	attack_verb = list("slammed")

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/chicken_bucket
	name = "chicken bucket"
	icon_state = "kfc_bucket"

//Special behavior below if warranted

//Is someone being a cunt at the table again ?
/obj/item/trash/plate/attack(mob/M as mob, mob/living/user as mob)
	user.delayNextAttack(10)
	user.visible_message("<span class='danger'>[user] shatters \the [src] on [M]'s head</span>", "<span class='warning'>You shatter \the [src] on [M]'s head</span>")
	if(isliving(M))
		var/mob/living/L = M
		L.apply_damage(20, BRUTE, "head")
	playsound(get_turf(src), "shatter", 70, 1)
	if(ishuman(M))
		var/mob/living/carbon/H = M
		H.Stun(3)
		H.emote("scream",,, 1)
	for(var/mob/O in viewers(M, null))
		shake_camera(O, 2, 3)
	user.drop_item(get_turf(src))
	returnToPool()