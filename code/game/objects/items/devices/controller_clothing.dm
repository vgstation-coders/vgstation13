/mob/proc/get_neural_flags()
	var/full_flags = 0
	for(var/obj/item/device/neural_equip/equipped in src.get_equipped_items())
		full_flags |= equipped.nl_flags
	return full_flags

/mob/living/silicon/get_neural_flags()
	return 0

/mob/living/silicon/ai/get_neural_flags()
	return CONTROLLER_FULL_LINK

/obj/item/device/neural_equip
	name = "generic neural equipment"
	desc = "It wires into your neurons!"

	icon = 'icons/obj/controller_items.dmi'

	w_class = 4

	var/nl_flags = 0

	siemens_coefficient = 1.5 //don't touch wires with it

/obj/item/device/neural_equip/OnMobDeath(var/mob/living/wearer)
	if(wearer && istype(wearer.loc, /obj/machinery/controller_pod))
		var/obj/machinery/controller_pod/pod = wearer.loc
		pod.mob_death(wearer)

/obj/item/device/neural_equip/goggles
	name = "neural-link goggles"
	desc = "Eyewear that gives the user view through a controlled subject's eyes."

	icon_state = "nl_eyes"
	item_state = "glasses"

	nl_flags = CONTROLLER_VISUAL_LINK

	slot_flags = SLOT_EYES

/obj/item/device/neural_equip/headset
	name = "neural-link headset"
	desc = "A headset that connects to a subject's audio sensors to give remote feedback to the user."

	icon_state = "nl_ear"

	nl_flags = CONTROLLER_AUDIO_LINK

	slot_flags = SLOT_EARS

/obj/item/device/neural_equip/helmet
	name = "neural linker"
	desc = "A helm lined with neural connectors, intended to give the user the highest level of control of the subject."

	icon_state = "nl_helm"
	item_state = "nl_helm"

	nl_flags = CONTROLLER_NEURAL_LINK

	slot_flags = SLOT_HEAD