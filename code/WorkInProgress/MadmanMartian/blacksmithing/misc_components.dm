/obj/item/item_head
	icon = 'icons/obj/misc_components.dmi'
	var/obj/item/result
	var/list/finishing_requirements = list(/obj/item/item_handle) //Things required to finish this object.

/obj/item/item_head/examine(mob/user)
	..()
	if(finishing_requirements.len)
		to_chat(user, "<span class = 'notice'>It looks like it requires:")
		for(var/i in finishing_requirements)
			var/obj/I = i
			to_chat(user, "<span class = 'notice'>A [initial(I.name)]</span>")

/obj/item/item_head/attackby(obj/item/I, mob/user)
	if(is_type_in_list(I, finishing_requirements))
		to_chat(user, "<span class = 'notice'>You begin to attach \the [I] to \the [src].</span>")
		if(do_after(user, src, 4 SECONDS))
			if(istype(I, /obj/item/stack))
				var/obj/item/stack/S = I
				if(!S.use(1))
					return
			else
				if(!user.drop_item(I))
					return
			finishing_requirements.Remove(I.type)
			gen_quality(quality-I.quality, quality, I.material_type)
			if(!istype(I, /obj/item/stack))
				qdel(I) //stacks handle themselves if they run out

			if(!finishing_requirements.len) //We're done
				user.drop_item(src)
				result = new result
				var/datum/material/mat = material_type
				if(mat)
					result.dorfify(mat, 0, quality)
				user.put_in_hands(result)
				qdel(src)
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

/obj/item/sword_handle
	name = "sword handle"
	icon = 'icons/obj/misc_components.dmi'
	icon_state = "sword_handle"
	desc = "A generic sword handle."

/obj/item/cross_guard
	name = "sword crossguard"
	icon = 'icons/obj/misc_components.dmi'
	icon_state = "crossguard"
	desc = "Used to make sure what you're stabbing doesn't slide all the way to your hand, or your hand slide to the stabby bit."

/obj/item/item_head/sword
	name = "sword blade"
	icon_state = "large_metal_blade"
	desc = "Rather unwieldy without a hilt."
	finishing_requirements = list(/obj/item/sword_handle, /obj/item/cross_guard)
	result = /obj/item/weapon/sword

/obj/item/item_head/sword/scimitar
	name = "scimitar blade"
	icon_state = "large_curved_blade"
	desc = "Curved. Swords."
	result = /obj/item/weapon/sword/scimitar

/obj/item/item_head/sword/shortsword
	name = "shortsword blade"
	result = /obj/item/weapon/sword/shortsword

/obj/item/item_head/sword/gladius
	name = "gladius blade"
	result = /obj/item/weapon/sword/gladius
	finishing_requirements = list(/obj/item/sword_handle)

/obj/item/item_head/sword/sabre
	name = "sabre blade"
	icon_state = "large_curved_blade"
	result = /obj/item/weapon/sword/sabre

/obj/item/item_head/tower_shield
	name = "unstrapped tower shield"
	icon_state = "large_plate"
	finishing_requirements = list(/obj/item/stack/leather_strip)
	result = /obj/item/weapon/shield/riot/tower