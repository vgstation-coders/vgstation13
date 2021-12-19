/obj/item/weapon/implant/babelfish
	name = "babelfish"
	icon = ''
	icon_state = ""

/obj/item/weapon/implant/babelfish/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!implanted || !imp_in)
		return
	var/atom/movable/guyTalking = speech.speaker.GetSource()
	if(!imp_in.say_understands(guyTalking, speech.language))
		imp_in.show_message("<span class='maroon'>[guyTalking]: [speech.message]</span>")

/obj/item/weapon/implant/babelfish/handle_removal(var/mob/remover)
	imp_in = null
	implanted = null
	part = null

/obj/item/weapon/implanter/babelfish
	name = "babelfish"
	desc = ""
	icon = ''
	icon_state = ""
	imp_type = /obj/item/weapon/implant/babelfish

/obj/item/weapon/implanter/babelfish/attack(mob/M as mob, mob/user as mob)
	..()
	if(!imp)
		qdel(src)
