/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(access_all_personal_lockers)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/atoms_to_spawn()
	return list(
		pick(/obj/item/weapon/storage/backpack, /obj/item/weapon/storage/backpack/satchel_norm, /obj/item/weapon/storage/backpack/messenger),
		/obj/item/device/radio/headset,
	)


/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/atoms_to_spawn()
	return list(
		/obj/item/clothing/under/color/white,
		/obj/item/clothing/shoes/white,
	)

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinetdetective"
	is_wooden = TRUE
	starting_materials = list(MAT_WOOD = 2*CC_PER_SHEET_WOOD)
	w_type = RECYK_WOOD

/obj/structure/closet/secure_closet/personal/cabinet/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/backpack/satchel/withwallet,
		/obj/item/device/radio/headset,
	)

/obj/structure/closet/secure_closet/personal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		if(src.broken)
			to_chat(user, "<span flags='rose'>It appears to be broken.</span>")
			return
		var/obj/item/weapon/card/id/I = W
		if(!I || !I.registered_name)
			return
		togglelock(user, I.registered_name)
	else
		..() //get the other stuff to do it

/obj/structure/closet/secure_closet/personal/togglelock(mob/user as mob, var/given_name = "")
	if(src.allowed(user) || !src.registered_name || (src.registered_name == given_name)) //they can open all lockers, or nobody owns this, or they own this locker
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				to_chat(O, "<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>")
		src.update_icon()
		if(!src.registered_name && given_name)
			src.registered_name = given_name
			src.desc = "Owned by [given_name]."
	else
		to_chat(user, "<span class='notice'>Access Denied.</span>")
