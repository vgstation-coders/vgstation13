/obj/item/complete/proc/spawn_objects()
	return

/obj/item/complete/New()
	..()
	spawn_objects()
	qdel(src)




/obj/item/complete/rig/wizard/spawn_objects()
	new /obj/item/clothing/head/helmet/space/rig/wizard(loc)
	new /obj/item/clothing/suit/space/rig/wizard(loc)
	new /obj/item/clothing/gloves/purple(loc)
	new /obj/item/clothing/shoes/sandal(loc)

/obj/item/complete/rig/nazi/spawn_objects()
	new /obj/item/clothing/head/helmet/space/rig/nazi(loc)
	new /obj/item/clothing/suit/space/rig/nazi(loc)

/obj/item/complete/rig/soviet/spawn_objects()
	new /obj/item/clothing/head/helmet/space/rig/soviet(loc)
	new /obj/item/clothing/suit/space/rig/soviet(loc)
