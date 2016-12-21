/mob/living/carbon/human/proc/handle_clothing()
	var/obj/item/clothing/C
	if(head && istype(head, /obj/item/clothing))
		C = head
		C.on_mob_life(src)
	if(wear_suit && istype(wear_suit, /obj/item/clothing))
		C = wear_suit
		C.on_mob_life(src)
	if(gloves && istype(gloves, /obj/item/clothing))
		C = gloves
		C.on_mob_life(src)
	if(shoes && istype(shoes, /obj/item/clothing))
		C = shoes
		C.on_mob_life(src)
	if(w_uniform && istype(w_uniform, /obj/item/clothing))
		C = w_uniform
		C.on_mob_life(src)
	if(glasses && istype(glasses, /obj/item/clothing))
		C = glasses
		C.on_mob_life(src)
	if(belt && istype(belt, /obj/item/clothing))
		C = belt
		C.on_mob_life(src)
	if(wear_id && istype(wear_id, /obj/item/clothing))
		C = wear_id
		C.on_mob_life(src)
	if(ears && istype(ears, /obj/item/clothing))
		C = ears
		C.on_mob_life(src)
	if(back && istype(back, /obj/item/clothing))
		C = back
		C.on_mob_life(src)
	if(wear_mask && istype(wear_mask, /obj/item/clothing))
		C = wear_mask
		C.on_mob_life(src)