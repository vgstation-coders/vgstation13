/obj/item/device/mmi/posibrain/nl_brain
	name = "neural-link brain"
	desc = "A connectable intelligence holder, lacking its own AI capabilities."

/obj/item/device/mmi/posibrain/nl_brain/attack_self(mob/user)
	return

/obj/item/device/mmi/posibrain/nl_brain/usable_brain()
	return brainmob && brainmob.connected_to