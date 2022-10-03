#define POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS 3

/obj/item/deployable_packet
	desc = ""
	w_class = W_CLASS_TINY
	var/activated = 0
	var/deployeditem = null
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/item/deployable_packet/attack_self(mob/user)
	if(!istype(user))
		return
	if(activated)
		return

	to_chat(user, "<span class='warning'>You shake \the [src].</span>")
	to_chat(user, "<span class='danger'>It starts vibrating weirdly!</span>")
	activated = 1

	spawn(POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS SECONDS)
		new deployeditem(get_turf(src)) //used to have the [packet_override = 1] var for powercreep fast spawn from packet, but it broke biomass spawning
		qdel(src)

/obj/item/deployable_packet/biomass
	name = "biomass packet"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "packet"
	deployeditem = /obj/effect/biomass_controller

/obj/item/deployable_packet/biomass/examine(mob/user, size, show_name)
	. = ..()
	to_chat(user, "Derek Baum VII's latest innovation. Carries a cryo-stabilized sample of biomass tissue.")
	to_chat(user, "It reads:\nStep 1: Shake to active.\nStep 2: Throw.\nStep 3: Enjoy.")
	if(activated)
		to_chat(user, "<span class='danger'>It's bubbling weirdly!</span>")

/obj/item/deployable_packet/powercreeper
	name = "powercreeper packet"
	icon = 'icons/obj/structures/powercreeper.dmi'
	icon_state = "packet"
	deployeditem = /obj/structure/cable/powercreeper

/obj/item/deployable_packet/powercreeper/examine(mob/user, size, show_name)
	. = ..()
	to_chat(user, "Derek Baum VII's most popular creation. Carries a self-replicating sample of powercreeper.")
	to_chat(user, "It reads:\nStep 1: Shake to active.\nStep 2: You have [POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS] seconds to run.")
	if(activated)
		to_chat(user, "<span class='danger'>It's sizzling weirdly!</span>")
