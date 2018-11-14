/mob/living/simple_animal/hologram
	name = "hologram"
	desc = "A holographic image of something"
	icon = 'icons/mob/AI.dmi'
	icon_state = "holo2"
	icon_living = "holo2"
	icon_dead = null
	mob_property_flags = MOB_HOLOGRAPHIC
	var/atom/atom_to_mimic


/mob/living/simple_animal/hologram/death(var/gibbed = FALSE)
	..(gibbed)
	visible_message("<span class = 'notice>\The [src] dissipates from view.</span>")
	qdel(src)


/mob/living/simple_animal/hologram/New()
	..()
	mimic()

/mob/living/simple_animal/hologram/proc/mimic(var/atom/mimic = atom_to_mimic)
	if(!mimic)
		return

	var/atom/thing_to_mimic = new mimic

	var/icon_of_mimic = getHologramIcon(icon(thing_to_mimic.icon, thing_to_mimic.icon_state))

	icon = icon_of_mimic
	name = thing_to_mimic.name
	var/datum/log/L = new
	thing_to_mimic.examine(L)
	desc = L.log
	qdel(L)
	qdel(thing_to_mimic)

/mob/living/simple_animal/hologram/examine(mob/user, var/size = "")
	if(desc)
		to_chat(user, desc)

/mob/living/simple_animal/hologram/RangedAttack(var/atom/A)
	if((istype(A, /obj) || isliving(A)) && A != src)
		mimic(A.type)


/mob/living/simple_animal/hologram/corgi
	atom_to_mimic = /mob/living/simple_animal/corgi

/mob/living/simple_animal/hologram/corgi_puppy
	atom_to_mimic = /mob/living/simple_animal/corgi/puppy

/mob/living/simple_animal/hologram/chicken
	atom_to_mimic = /mob/living/simple_animal/chicken

/mob/living/simple_animal/hologram/cow
	atom_to_mimic = /mob/living/simple_animal/cow

/mob/living/simple_animal/hologram/tajaran_dancer
	atom_to_mimic = /mob/living/simple_animal/hostile/humanoid/tajaran/dancer

/mob/living/simple_animal/hologram/advanced
	name = "hologram"
	desc = "A holographic image of a person."
	icon_state = "holo3"
	icon_living = "holo3"
	held_items = list(null, null)
	flags = HEAR_ALWAYS
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "punches"
	var/obj/item/head
	var/obj/item/w_uniform
	var/obj/item/wear_suit
	var/list/obj/abstract/Overlays/obj_overlays[TOTAL_LAYERS]
	var/obj/machinery/computer/HolodeckControl/connected_holoconsole

/mob/living/simple_animal/hologram/advanced/New()
	..()
	name = "[name] ([rand(1, 1000)])"
	real_name = name
	obj_overlays[HEAD_LAYER]		= getFromPool(/obj/abstract/Overlays/head_layer)
	obj_overlays[UNIFORM_LAYER]		= getFromPool(/obj/abstract/Overlays/uniform_layer)
	obj_overlays[SUIT_LAYER]		= getFromPool(/obj/abstract/Overlays/suit_layer)

/mob/living/simple_animal/hologram/advanced/Login()
	..()
	to_chat(src, "You are a hologram. You can perform a few basic functions, and are unable to leave the holodeck.\
		\n<span class='danger'>You know nothing of this station or its crew except what you learn from this point on.</span>\
		\n<span class='danger'>Do not damage the holodeck. Do not harm crew members without their consent.</span>")
	if(transmogged_from)
		to_chat(src, "Use the spell in the top-right corner of the screen to go back to being a ghost.")

/mob/living/simple_animal/hologram/advanced/Destroy()
	head = null
	w_uniform = null
	wear_suit = null
	for (var/obj/item/O in held_items)
		O.dropped(src)
	if(connected_holoconsole)
		connected_holoconsole.connected_holopeople.Remove(src)
		connected_holoconsole = null
	transmogrify()
	..()

/mob/living/simple_animal/hologram/RangedAttack(var/atom/A)
	return

/mob/living/simple_animal/hologram/advanced/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_hand(src)

/mob/living/simple_animal/hologram/advanced/Life()
	..()
	regular_hud_updates()
	if(!istype(get_area(src), /area/holodeck) || (mind && !client))
		dissipate()

/mob/living/simple_animal/hologram/proc/dissipate()
	qdel(src)

/mob/living/simple_animal/hologram/advanced/can_wield()
	return 1

/mob/living/simple_animal/hologram/advanced/attack_hand(mob/living/M)
	switch(M.a_intent)
		if(I_HELP)
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] gives [src] a [pick("hug","warm embrace")].</span>", \
				"<span class='notice'>You hug [src].</span>", \
				)

		if(I_HURT)
			M.unarmed_attack_mob(src)

		if(I_GRAB)
			M.grab_mob(src)

		if(I_DISARM)
			M.disarm_mob(src)

/mob/living/simple_animal/hologram/advanced/attack_alien(mob/living/M)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			return M.unarmed_attack_mob(src)

		if (I_GRAB)
			return M.grab_mob(src)

		if (I_DISARM)
			return M.disarm_mob(src)

/mob/living/simple_animal/hologram/advanced/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/simple_animal/hologram/advanced/attack_martian(mob/M)
	return attack_hand(M)

/mob/living/simple_animal/hologram/advanced/attack_paw(mob/M)
	return attack_hand(M)
