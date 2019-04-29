/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personell. The first card swiped gains control."
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
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/personal/cabinet/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

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
		if(src.locked)
			src.icon_state = src.icon_locked
		else
			src.icon_state = src.icon_closed
		if(!src.registered_name && given_name)
			src.registered_name = given_name
			src.desc = "Owned by [given_name]."
	else
		to_chat(user, "<span class='notice'>Access Denied.</span>")
