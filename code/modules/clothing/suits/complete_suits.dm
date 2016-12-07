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

/obj/item/complete/outfit/dredd/spawn_objects()
	new /obj/item/clothing/under/darkred(loc)
	new /obj/item/clothing/suit/armor/xcomsquaddie/dredd(loc)
	new /obj/item/clothing/glasses/hud/security(loc)
	new /obj/item/clothing/mask/gas/swat(loc)
	new /obj/item/clothing/head/helmet/dredd(loc)
	new /obj/item/clothing/gloves/combat(loc)
	new /obj/item/clothing/shoes/combat(loc)
	new /obj/item/weapon/storage/belt/security(loc)
	new /obj/item/weapon/gun/lawgiver(loc)