//Postage stamps are used to mail letters and packages to centcomm. Using them on a parcel and shipping it off on the supply shuttle
//will store the parcel in a special room and notify admins.

//The code for doing that can be found in the supply shuttle's code!

var/global/list/postage_stamps = list(
	"stamp_sol"		= "Depicted on the stamp is the Sol system, the original home of the human race.",
	"stamp_guy"		= "Depicted on the stamp is Long Dong, a businessman ranked #2 in the list of most influental people in the world.",
	"stamp_jew"		= "Depicted on the stamp is Christian Lynton. You have no idea who he is, but he looks like a cool guy.",
	"stamp_jesus"	= "Depicted on the stamp is Space Jesus, the world record holder for the fastest one-mile run while dribbling five basketballs and everybody's favourite deity."
)

/obj/item/postage_stamp
	name = "postage stamp"

	icon = 'icons/obj/mail.dmi'
	icon_state = "stamp_blank"

	w_class = 1.0
	force = 0
	throwforce = 0
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	throw_range = 1
	throw_speed = 1

/obj/item/postage_stamp/New()
	.=..()

	var/new_appearance = pick(postage_stamps)
	if(new_appearance)
		icon_state = new_appearance
		desc = postage_stamps[new_appearance]

/obj/item/postage_stamp/attack_self(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.hasmouth)
			user << "You lick \the [src]." //Fluff

/obj/item/postage_stamp/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return 0 // not adjacent

	if(istype(target,/obj/item/smallDelivery))
		var/obj/item/smallDelivery/D = target
		if(D.stamped)
			user << "[D] is already stamped!"
			return

		user.drop_item(src)
		D.stamped = 1
		D.stamped_by = key_name(user, 1)
		D.overlays += "stamp"

		user.visible_message("<span class='info'>[user] sticks \the [src] on \the [D].</span>",\
			"<span class='info'>You carefully apply \the [src] to \the [D].</span>")

		qdel(src)
		return

	else if(istype(target,/obj/structure/bigDelivery))
		var/obj/structure/bigDelivery/D = target
		if(D.stamped)
			user << "[D] is already stamped!"
			return

		user.drop_item(src)
		D.stamped = 1
		D.stamped_by = key_name(user, 1)
		D.overlays += "stamp"

		user.visible_message("<span class='info'>[user] stick \the [src] on \the [D].</span>",\
			"<span class='info'>You carefully apply \the [src] to \the [D].</span>")

		qdel(src)
		return
