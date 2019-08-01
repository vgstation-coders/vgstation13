#define POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS 3

/obj/item/powercreeper_packet
	name = "powercreeper packet"
	desc = ""
	icon = 'icons/obj/structures/powercreeper.dmi'
	icon_state = "packet"
	var/activated = 0

/obj/item/powercreeper_packet/attack_self(mob/user)
	if(!istype(user))
		return
	if(activated)
		return

	to_chat(user, "<span class='warning'>You shake \the [src].</span>")
	to_chat(user, "<span class='danger'>It starts sizzling weirdly!</span>") //english people help me with these words
	activated = 1
	
	spawn(POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS SECONDS)
		new /obj/structure/cable/powercreeper(get_turf(src), packet_override = 1)
		qdel(src)

/obj/item/powercreeper_packet/examine(mob/user, size, show_name)
	. = ..()
	to_chat(user, "It reads:\nStep 1: Shake to active.\nStep 2: You have [POWERCREEP_PACKET_ACTIVATION_TIME_IN_SECONDS] seconds to run.")
	if(activated)
		to_chat(user, "<span class='danger'>Its sizzling weirdly!</span>")