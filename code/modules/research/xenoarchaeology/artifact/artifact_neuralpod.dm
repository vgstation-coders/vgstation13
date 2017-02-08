/obj/structure/closet/crate/large/neural_pod/New()
	. = ..()
	var/obj/pod = new/obj/machinery/controller_pod(src)
	pod.anchored = 0
	if(prob(66)) //more likely to get the helmet
		new/obj/item/device/neural_equip/helmet(src)
	else
		new/obj/item/device/neural_equip/headset(src)
		new/obj/item/device/neural_equip/goggles(src)

	new/obj/item/device/mmi/posibrain/nl_brain(src)
	new/obj/item/device/mmi/posibrain/nl_brain(src)
	new/obj/item/device/mmi/posibrain/nl_brain(src)