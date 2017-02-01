/obj/item/airbag
	name = "personal airbag"
	desc = "One-use protection from high-speed collisions."
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/airbag/New(atom/A, var/deployed)
	..(A)
	if(deployed)
		icon = 'icons/obj/structures.dmi'
		icon_state = "snowbarricade"
		anchored = 1
		spawn(30)
			qdel(src)

/obj/item/airbag/proc/deploy()
	to_chat(world, "SOUND GOES HERE")
	qdel(src)