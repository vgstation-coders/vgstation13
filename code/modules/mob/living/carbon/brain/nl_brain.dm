/obj/item/device/mmi/posibrain/nl_brain
	name = "neural-link brain"
	desc = "A connectable intelligence holder, lacking its own AI capabilities."
	flags = HEAR

/obj/item/device/mmi/posibrain/nl_brain/attack_self(mob/user)
	return

/obj/item/device/mmi/posibrain/nl_brain/usable_brain()
	return brainmob && brainmob.connected_to

/*for some reason the brainmob inside a brain cannot hear
anything if it is not being controlled by someone, this
manually passes sound through to it in that case*/
/obj/item/device/mmi/posibrain/nl_brain/Hear(var/datum/speech/speech, var/rendered_speech="")
	if (brainmob.connected_to && !brainmob.mind)
		brainmob.Hear(speech, rendered_speech)
		return
	..()