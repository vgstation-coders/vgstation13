/**
* Exile Implants 2.0
*
* Since away missions are fucked, here's an alternative implementation.
*
* Instead of confining someone within an away mission, this locks someone to the asteroid.
*/
/obj/item/weapon/implanter/exile
	name = "implanter-exile"
	implant_path = /obj/item/weapon/implant/exile

/obj/item/weapon/implant/exile
	name = "exile"
	desc = "Prevents you from returning from the asteroid"

/obj/item/weapon/implant/exile/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
				<b>Implant Details:</b> The host of this implant will be prevented from returning to the station."}
	return dat

/obj/item/weapon/implant/exile/attempt_implant(mob/M)
	if(!istype(M, /mob/living/carbon))
		return 0
	var/mob/living/carbon/I = M
	to_chat(I, "<span class='notice'>You shiver as you feel a weak bluespace void surround you.</span>")
	I.locked_to_z = ASTEROID_Z
	return 1

/obj/item/weapon/implantcase/exile
	name = "Glass Case- 'Exile'"
	desc = "A case containing an exile implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-red"
	implant_path = /obj/item/weapon/implant/exile

/obj/structure/closet/secure_closet/exile
	name = "Exile Implants"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/exile/atoms_to_spawn()
	return list(
		/obj/item/weapon/implanter/exile,
		/obj/item/weapon/implantcase/exile = 5,
	)
