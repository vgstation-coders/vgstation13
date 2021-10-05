/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	origin_tech = Tc_MAGNETS + "=1;" + Tc_COMBAT + "=1"
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1
	actions_types = list(/datum/action/item_action/activate_hailer)

	var/nextuse = 0
	var/cooldown = 2 SECONDS
	var/emagged = 0
	var/insults = 0//just in case

/obj/item/device/hailer/verb/activate_hailer()
	set src in usr
	set name = "Activate Hailer"
	set desc = "Activates your hailer. Ctrl+click a turf to use a targeted hail."
	set category = "Object"
	if (!usr || loc != usr)
		return
	return attack_self(usr)

/obj/item/device/hailer/proc/say_your_thing()
	if(emagged)
		if(insults)
			return "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
		else
			return "*BZZZZcuntZZZZT*"
	else
		return "HALT! SECURITY!"

/obj/item/device/hailer/proc/do_your_sound(var/mob/user)
	if(emagged && insults)
		playsound(user, 'sound/voice/binsult.ogg', 100, 1, vary = 0)
		insults--
	else
		playsound(user, 'sound/voice/halt.ogg', 100, 1, vary = 0)
	if(user)
		var/list/bystanders = get_hearers_in_view(world.view, user)
		flick_overlay(image('icons/mob/talk.dmi', user, "hail", MOB_LAYER+1), clients_in_moblist(bystanders), 2 SECONDS)
	nextuse = world.time + cooldown

/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if(world.time < nextuse)
		return
	if(emagged && !insults)
		to_chat(user, "<span class='warning'>[say_your_thing()]</span>")
		return

	var/message = say_your_thing()
	user.visible_message("<span class='warning'>[user]'s [name] [emagged ? "gurgles" : "rasps"], \"[message]\"</span>", \
						"<span class='warning'>Your [name] [emagged ? "gurgles" : "rasps"], \"[message]\"</span>", \
						"<span class='warning'>You hear the computerized voice of a security hailer: \"[message]\"</span>")
	do_your_sound(user)

/obj/item/device/hailer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return

/obj/item/device/hailer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(world.time < nextuse)
		return
	if(proximity_flag && !ismob(target)) //Don't do anything when being put in a backpack, on a table, or anything within one tile of us like opening an airlock. Exception is when used on people, I guess to rub it in someone's face
		return
	if(emagged && !insults)
		to_chat(user, "<span class='warning'>[say_your_thing()]</span>")
		return

	// ~ getting the suspects ~ //
	var/list/mob/living/suspects = list() //Think of it like aim assist for clicking on people with the hailer:
	if(ismob(target)) //If you clicked right on someone, good, let's hail at them
		suspects += target
	if(!suspects.len)
		for(var/mob/living/M in get_turf(target)) //Okay, maybe you misclicked and hit a chair or something, let's try finding them in the turf
			suspects += M
	if(!suspects.len)
		for(var/mob/living/M in orange(1, target)) //Okay jesus, maybe a 3x3 square
			suspects += M
	if(!suspects.len) //Oh okay you weren't even trying
		attack_self(user) //just do the normal hailer thing I guess
		return

	// ~ drawing the images ~ //
	var/list/bystanders = get_hearers_in_view(world.view, user)
	for(var/mob/living/M in suspects)
		flick_overlay(image('icons/mob/talk.dmi', M, "halt", MOB_LAYER+1), clients_in_moblist(bystanders), 2 SECONDS) //One image for each suspect

	// ~ visible message ~ //
	for(var/mob/living/M in suspects)
		M.show_message("<span class='userdanger'>[bicon(src)][say_your_thing()]</span>", MESSAGE_HEAR)
		add_logs(user, M, "security-hailed", 1)
	var/who = suspects.len <= 3 ? english_list(suspects) : "everyone"
	user.visible_message("<span class='danger'>[user] hails for [who] to halt!</span>", \
						"<span class='warning'>You hail for [who] to halt!</span>", \
						"<span class='warning'>You hear the computerized voice of a security hailer: \"[say_your_thing()]\"</span>")

	// ~ sound and cooldown ~ //
	do_your_sound(user)

// Hailer attachment

/obj/item/device/hailer/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0
	if(istype(target, /obj/item/clothing/under) || istype(target, /obj/item/clothing/suit/armor))
		var/obj/item/clothing/C = target
		var/obj/item/clothing/accessory/hailer/H = new()
		if(C.check_accessory_overlap(H))
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to \the [C].</span>")
			return
		if(user.drop_item(src))
			to_chat(user, "<span class='notice'>You attach \the [src] to \the [C].</span>")
			C.attach_accessory(H)
			transfer_fingerprints(src,H)
			forceMove(H)
		return 1
	else
		..()
	return ..()

/obj/item/clothing/accessory/hailer
	name = "hailer"
	desc = "This is attached to something."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice0" //placeholder sprites
	accessory_exclusion = ACCESSORY_HAILER
	var/obj/item/device/hailer/source_hailer
	ignoreinteract = TRUE

/obj/item/clothing/accessory/hailer/New()
	..()
	if (!source_hailer)
		source_hailer = new /obj/item/device/hailer/
		source_hailer.forceMove(src)

/obj/item/clothing/accessory/hailer/Destroy()
	source_hailer = null
	..()

/obj/item/clothing/accessory/hailer/can_attach_to(obj/item/clothing/C)
	return (istype(C, /obj/item/clothing/under) || istype(C, /obj/item/clothing/suit/armor))

/obj/item/clothing/accessory/hailer/on_attached(obj/item/clothing/C)
	..()
	var/datum/action/A = new /datum/action/item_action/activate_hailer_attached(C)
	if(ismob(C.loc))
		var/mob/user = C.loc
		A.Grant(user)
	update_icon()

/obj/item/clothing/accessory/hailer/update_icon()
	if(!attached_to)
		return
	if(attached_to.overlays.len)
		attached_to.overlays -= inv_overlay
	if(icon_state)
		inv_overlay = image("icon" = 'icons/obj/clothing/accessory_overlays.dmi', "icon_state" = "[icon_state]")
		if (attached_to.overlays.len)
			attached_to.overlays -= inv_overlay
		attached_to.overlays += inv_overlay
	if(ishuman(attached_to.loc))
		var/mob/living/carbon/human/H = attached_to.loc
		H.update_inv_by_slot(attached_to.slot_flags)

	attached_to.update_icon()

/obj/item/clothing/accessory/hailer/on_removed(mob/user)
	if(!attached_to)
		return
	icon_state = null
	if(ismob(attached_to.loc))
		var/mob/M = attached_to.loc
		M.regenerate_icons()
	for(var/datum/action/A in attached_to.actions)
		if(istype(A, /datum/action/item_action/activate_hailer_attached))
			qdel(A)
	if(source_hailer)
		source_hailer.forceMove(get_turf(src))
		if(user)
			user.put_in_hands(source_hailer)
		add_fingerprint(user)
		transfer_fingerprints(src,source_hailer)
		source_hailer = null
	update_icon()
	attached_to = null
	qdel(src)

/obj/item/clothing/accessory/hailer/attack_self(mob/user)
	if(user.isUnconscious() || user.restrained())
		return
	if(source_hailer)
		source_hailer.attack_self(user)

/obj/item/clothing/accessory/hailer/attackby(var/obj/item/I, var/mob/user)
	if(I.is_screwdriver(user) && attached_to)
		to_chat(user, "<span class='notice'>You remove [src] from [attached_to].</span>")
		attached_to.remove_accessory(user, src)

/obj/item/clothing/accessory/hailer/on_accessory_interact()
	return -1 //override priority check since you can't pull it off anyway

/datum/action/item_action/activate_hailer_attached
	name = "Activate Hailer"
	desc = "Activates your hailer. Ctrl+click a turf to use a targeted hail."
	//var/obj/item/clothing/accessory/hailer/ownerhail
/*
/datum/action/item_action/activate_hailer_attached/Trigger()
	ownerhail.attack_self(owner)
	to_chat(world, "DEBUG Attempting to hail with [ownerhail].")
*/
