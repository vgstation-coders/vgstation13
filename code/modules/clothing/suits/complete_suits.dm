//Complete outfits

/obj/item/clothing/suit/space/rig/wizard/complete/New()	//Use to spawn a complete gemsuit set all at once
	..()
	new /obj/item/clothing/head/helmet/space/rig/wizard(loc)
	new /obj/item/clothing/suit/space/rig/wizard(loc)
	new /obj/item/clothing/gloves/purple(loc)
	new /obj/item/clothing/shoes/sandal(loc)
	qdel(src)

/obj/item/clothing/suit/space/rig/nazi/complete/New()
	..()
	new /obj/item/clothing/head/helmet/space/rig/nazi(loc)
	new /obj/item/clothing/suit/space/rig/nazi(loc)
	qdel(src)
	
/obj/item/clothing/suit/space/rig/soviet/complete/New()
	..()
	new /obj/item/clothing/head/helmet/space/rig/soviet(loc)
	new /obj/item/clothing/suit/space/rig/soviet(loc)
	qdel(src)