/datum/clockcult_power/geis
	name			= "Geis"
	desc			= "Imbues the slab with divine energy, allowing the user to read from it and convert unprotected targets in an adjacent tile. Implanted targets are immune to conversion by Geis. Humans and silicons are both valid targets."

	invocation		= "Rayvtugra urngura! Nyy gval orsber Ratvar! Chetr nyy hageh’guf naq ubabe Ratvar."
	cast_time		= 60
	loudness		= CLOCK_CHANTED
	req_components	= list(CLOCK_GEIS = 1)

/datum/clockcult_power/geis/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	C.visible_message("<span class='notice'>\The [src] starts glowing!</span>")
	C.converting = TRUE
	C.update_icon()
