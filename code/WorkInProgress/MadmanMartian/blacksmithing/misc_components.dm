/obj/item/item_head
	icon = 'icons/obj/misc_components.dmi'
	var/obj/item/result

/obj/item/item_head/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/item_handle))
		to_chat(user, "<span class = 'notice'>You begin to attach \the [I] to \the [src].</span>")
		if(do_after(user, src, 4 SECONDS))
			user.drop_item(I)
			user.drop_item(src)
			result = new result
			var/datum/material/mat = material_type
			if(mat)
				result.dorfify(mat, 0, quality)
			qdel(I)
			qdel(src)
			user.put_in_hands(result)
			return
	..()

/obj/item/item_head/hammer_head
	name = "hammer head"
	icon_state = "hammer_head"
	desc = "unlike the shark, this one lacks bite."
	result = /obj/item/weapon/hammer

/obj/item/item_head/pickaxe_head
	name = "pickaxe head"
	icon_state = "pickaxe_head"
	desc = "To strike the earth, you will need a handle on the situation"
	result = /obj/item/weapon/pickaxe

/obj/item/item_handle
	name = "item handle"
	icon = 'icons/obj/misc_components.dmi'
	icon_state = "item_handle"
	desc = "a generic handle, with no purpose."