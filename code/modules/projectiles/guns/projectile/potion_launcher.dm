/obj/item/weapon/gun/potionlauncher
	name = "potion launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "potionlauncher"
	item_state = "potionlauncher"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	desc = "The Wizard Federation's answer to the ongoing arms race with NanoTrasen and the Syndicate. This launcher can hold up to 5 potions for rapid potion throwing."
	w_class = W_CLASS_LARGE
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/potions = new/list()
	var/max_potions = 5
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL

/obj/item/weapon/gun/potionlauncher/examine(mob/user)
	..()
	if(!(potions.len))
		to_chat(user, "<span class='info'>It is empty.</span>")
		return
	to_chat(user, "<span class='info'>It has [potions.len] / [max_potions] potions loaded.</span>")
	for(var/obj/item/potion/G in potions)
		to_chat(user, "[bicon(G)] [G.name]")

/obj/item/weapon/gun/potionlauncher/attackby(obj/item/I as obj, mob/user as mob)

	if((istype(I, /obj/item/potion)))
		if(potions.len < max_potions)
			if(user.drop_item(I, src))
				potions += I
				to_chat(user, "<span class='notice'>You load the [I.name] into the [src.name].</span>")
				to_chat(user, "<span class='notice'>[potions.len] / [max_potions] potions loaded.</span>")
		else
			to_chat(user, "<span class='warning'>The [src.name] cannot hold more potions.</span>")

/obj/item/weapon/gun/potionlauncher/afterattack(obj/target, mob/user , flag)

	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(potions.len)
		spawn(0) fire_potion(target,user)
	else
		to_chat(usr, "<span class='warning'>The [src.name] is empty.</span>")

/obj/item/weapon/gun/potionlauncher/proc/fire_potion(atom/target, mob/user)
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("<span class='warning'>[] fired a potion!</span>", user), 1)
	to_chat(user, "<span class='warning'>You fire the potion launcher!</span>")
	var/obj/item/potion/F = potions[1] //Now with less copypasta!
	potions -= F
	F.forceMove(user.loc)
	F.throw_at(target, 30, 2)
	message_admins("[key_name_admin(user)] fired [F.name] from [src.name].")
	log_game("[key_name_admin(user)] launched [F.name] from [src.name].")
	//F.active = 1
	//F.icon_state = initial(icon_state) + "_active"
	playsound(user.loc, 'sound/effects/slingshot.ogg', 50, 1, -3)