/*
 *		Bag of Holding
 *		Miniature black hole
*/

/obj/item/weapon/storage/backpack/holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = Tc_BLUESPACE + "=4"
	item_state = "holdingpack"
	icon_state = "holdingpack"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28

/obj/item/weapon/storage/backpack/holding/miniblackhole
	name = "miniature black hole"
	desc = "A miniature black hole that opens into a localized pocket of Blue Space."
	icon_state = "porthole"
	slot_flags = 0 //doesn't fit on your back!
	w_class = W_CLASS_SMALL //fits in pockets!

/obj/item/weapon/storage/backpack/holding/suicide_act(var/mob/living/user)
	user.visible_message("<span class = 'danger'><b>[user] puts \the [src.name] on \his head and stretches the bag around \himself. With a sudden snapping sound, the bag shrinks to its original size, leaving no trace of [user].</b></span>")
	user.drop_item(src)
	qdel(user)

/obj/item/weapon/storage/backpack/holding/miniblackhole/suicide_act(var/mob/living/user)
	user.visible_message("<span class = 'danger'><b>[user] puts \the [src.name] on the ground and jumps inside, never to be seen again.<</b></span>")
	user.drop_item(src)
	qdel(user)

/obj/item/weapon/storage/backpack/holding/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	if(W == src)
		return // HOLY FUCKING SHIT WHY STORAGE CODE, WHY - pomf
	var/list/recursive_list = recursive_type_check(W, /obj/item/weapon/storage/backpack/holding)
	if(recursive_list.len) // Placing a bag of holding into another will singuloose when stored inside other objects too, such as when on your back or on a diona's back and stuffed in
		singulocreate(recursive_list, user)
		return

//BoH+BoH=Singularity, WAS commented out
/obj/item/weapon/storage/backpack/holding/proc/singulocreate(var/list/obj/item/weapon/storage/backpack/holding/Hs, var/mob/user)
	user.Knockdown(10)
	user.Stun(10)
	to_chat(user, "<span class = 'danger'>The Bluespace interfaces of the two devices catastrophically malfunction, throwing you to the ground in the process!</span>")
	to_chat(user, "<span class='danger'>FUCK!</span>")
	var/turf/T = get_turf(src)
	if(Hs?.len)
		for(var/obj/item/weapon/storage/backpack/holding/H in Hs)
			qdel(H)
	qdel(src)
	var/datum/zLevel/ourzLevel = map.zLevels[user.z]
	if(ourzLevel.bluespace_jammed && !is_on_shuttle(usr))
		//Stop breaking into centcomm via dungeons you shits
		message_admins("[key_name_admin(user)] detonated [counted_english_list(Hs)] and [src], creating an explosion.")
		log_game("[key_name(user)] detonated [counted_english_list(Hs)] and [src], creating an explosion.")
		empulse(T,(20),(40))
		explosion(T, 5, 10, 20, 40, 1, whodunnit = user)
		user.gib() //Just to be sure
	else
		investigation_log(I_SINGULO,"has become a singularity. Caused by [user.key]")
		message_admins("[key_name_admin(user)] detonated [counted_english_list(Hs)] and [src], creating a singularity.")
		log_game("[key_name(user)] detonated [counted_english_list(Hs)] and [src], creating a singularity.")
		var/obj/machinery/singularity/S = new (T)
		S.consume(user) //So the BoHolder can't run away from his wrongdoing

/obj/item/weapon/storage/backpack/holding/singularity_act(var/current_size,var/obj/machinery/singularity/S)
	var/dist = max(current_size, 1)
	empulse(S.loc,(dist*2),(dist*4))
	if(S.current_size <= 3)
		investigation_log(I_SINGULO, "has been destroyed by [src].")
		qdel(S)
	else
		investigation_log(I_SINGULO, "has been weakened by [src].")
		S.energy -= (S.energy/3)*2
		S.check_energy()
	qdel(src)
