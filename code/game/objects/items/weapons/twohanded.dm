/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		High Energy Frequency Blade
 */

///////////OFFHAND///////////////
//what the mob gets when wielding something
/obj/item/offhand
	w_class = W_CLASS_HUGE
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	name = "offhand"
	abstract = 1
	var/obj/item/wielding = null

/obj/item/offhand/pregive(mob/living/carbon/giver, mob/living/carbon/receiver)
	giver.swap_hand()
	receiver.give_item(giver)
	return FALSE

/obj/item/offhand/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	return FALSE

/obj/item/offhand/dropped(user)
	if(!wielding)
		qdel(src)
		return null
	return wielding.unwield(user)


/obj/item/offhand/unwield(user)
	if(!wielding)
		qdel(src)
		return null
	return wielding.unwield(user)

/obj/item/offhand/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(istype(target, /obj/item/weapon/storage)) //we place automatically
		return
	if(wielding)
		if(!target.attackby(wielding, user))
			wielding.afterattack(target, user, proximity_flag, click_parameters)
		return 1

/obj/item/offhand/attack_self(mob/user)
	if(!wielding)
		qdel(src)
		return null
	return wielding.unwield(user)

/obj/item/offhand/proc/attach_to(var/obj/item/I)
	I.wielded = src
	wielding = I
	name = wielding.name + " offhand"
	desc = "Your second grip on the [I.name]"

/obj/item/offhand/IsShield()//if the actual twohanded weapon is a shield, we count as a shield too!
	return wielding.IsShield()
/*
 * Fireaxe
 */
/obj/item/weapon/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	hitsound = "sound/weapons/bloodyslice.ogg"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	w_class = W_CLASS_LARGE
	sharpness = 1.2
	sharpness_flags = SHARP_BLADE | CHOPWOOD
	force = 10
	var/force_wielded = 40
	slot_flags = SLOT_BACK
	attack_verb = list("attacks", "chops", "cleaves", "tears", "cuts")
	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	slowdown = FIREAXE_SLOWDOWN

/obj/item/weapon/fireaxe/update_wield(mob/user)
	..()
	item_state = "fireaxe[wielded ? 1 : 0]"
	force = wielded ? force_wielded : initial(force)
	if(user)
		user.update_inv_hands()

/obj/item/weapon/fireaxe/suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is smashing \himself in the head with the [src.name]! It looks like \he's commit suicide!</span>")
		return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity)
		return
	..()
	if(A && wielded && (istype(A,/obj/structure/window))) //destroys windows and grilles in one hit
		user.delayNextAttack(8)
		if(istype(A,/obj/structure/window))
			var/pdiff=performWallPressureCheck(A.loc)
			if(pdiff>0)
				message_admins("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(A.loc)]!")
				log_admin("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([user.ckey]) at [A.loc]!")
			var/obj/structure/window/W = A
			W.shatter()
		else
			QDEL_NULL(A)
	else if(A && wielded && (istype(A, /turf/simulated/floor))) //removes floor plating
		var/turf/simulated/floor/T = A
		to_chat(viewers(user), "<span class='danger'>[user] begins to remove the plating using \the [src]!</span>")
		var/breaktime = 6 SECONDS
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.get_strength() >= 2)
				breaktime = 3 SECONDS
		if(!do_after(user, T, breaktime, 3, custom_checks = new /callback(src, /obj/item/weapon/fireaxe/proc/on_do_after)))
			return
		playsound(src, 'sound/effects/plate_drop.ogg', 50, 1)
		to_chat(viewers(user), "<span class='danger'>[user] finishes removing the plating!</span>")
		add_gamelogs(user, "deconstructed \the [T] with \the [src]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
		T.investigation_log(I_RCD,"was deconstructed by [user]") //not RCD but still fits in this category
		T.ChangeTurf(T.get_underlying_turf())

/obj/item/weapon/fireaxe/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/tool/crowbar/halligan))
		var/obj/item/tool/crowbar/halligan/H = I
		to_chat(user, "<span class='notice'>You attach \the [src] and [H] to carry them easier.</span>")
		var/obj/item/tool/irons/SI = new (user.loc)
		SI.fireaxe = H
		SI.halligan = src
		user.drop_item(H)
		H.forceMove(SI)
		user.drop_item(src)
		forceMove(SI)
		user.put_in_hands(SI)
		return 1
	return ..()

/obj/item/weapon/fireaxe/proc/on_do_after(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	. = do_after_default_checks(arglist(args))
	if(.)
		playsound(src,"sound/misc/clang.ogg",50,1)

/*
 * High-Frequency Blade
 */
/obj/item/weapon/katana/hfrequency
	icon_state = "hfrequency0"
	item_state = "hfrequency0"
	name = "high-frequency blade"
	desc = "Keep hands off blade at all times."
	slot_flags = SLOT_BACK
	throwforce = 35
	throw_speed = 5
	throw_range = 10
	sharpness = 2
	sharpness_flags = SHARP_TIP | SHARP_BLADE | CHOPWOOD | CUT_WALL | CUT_AIRLOCK //it's a really sharp blade m'kay
	w_class = W_CLASS_LARGE
	flags = FPRINT | TWOHANDABLE
	mech_flags = MECH_SCAN_FAIL
	origin_tech = Tc_MAGNETS + "=4;" + Tc_COMBAT + "=5"

/obj/item/weapon/katana/hfrequency/update_wield(mob/user)
	..()
	item_state = "hfrequency[wielded ? 1 : 0]"
	force = wielded ? 200 : 50
	sharpness = wielded ? 100 : 2
	armor_penetration = wielded ? 100 : 50
	if(user)
		user.update_inv_hands()
	return

/obj/item/weapon/katana/hfrequency/IsShield()
	if(wielded)
		return 1
	else
		return 0


//spears
/obj/item/weapon/spear
	icon_state = "spearglass0"
	var/base_state = "spearglass"

	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	sharpness = 0.8
	sharpness_flags = SHARP_TIP | INSULATED_EDGE
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK
	throwforce = 15
	flags = TWOHANDABLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "pokes", "jabs", "tears", "gores")

	var/base_force = 10

/obj/item/weapon/spear/update_wield(mob/user)
	icon_state = "[base_state][wielded ? 1 : 0]"
	item_state = "[base_state][wielded ? 1 : 0]"

	force = base_force
	if(wielded)
		force += 8

	if(user)
		user.update_inv_hands()
	return

/obj/item/weapon/spear/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/organ/external/head))
		if(loc == user)
			user.drop_item(src, force_drop = 1)
		var/obj/structure/headpole/H = new (get_turf(src), W, src)
		user.drop_item(W, H, force_drop = 1)

/obj/item/weapon/spear/attack(var/mob/living/M, var/mob/user)
	var/obj/item/I
	if(user.zone_sel.selecting == "l_hand")
		I = M.get_held_item_by_index(GRASP_LEFT_HAND)
	else if(user.zone_sel.selecting == "r_hand")
		I = M.get_held_item_by_index(GRASP_RIGHT_HAND)
	if(I && istype(I,src.type) && user.a_intent == I_HELP)
		playsound(get_turf(user), 'sound/weapons/Genhit.ogg', 50, 1)
		visible_message("<span class='bad'>[user] high spears [M], but it feels too similar to doing it with a shovel, and isn't good.</span>",\
						"<span class='bad'>You high spear [M], but it feels too similar to doing it with a shovel, and isn't good.</span>")
	else
		..()

/obj/item/weapon/spear/wooden
	name = "steel spear"
	desc = "An ancient weapon of an ancient design, with a smooth wooden handle and a sharp steel blade."
	icon_state = "spear0"
	base_state = "spear"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')

	force = 16
	throwforce = 25

/obj/item/binoculars
	name = "binoculars"
	desc = "Used for long-distance surveillance."
	icon_state = "binoculars"
	item_state = "binoculars"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	gender = PLURAL
	flags = FPRINT | TWOHANDABLE
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL

/obj/item/binoculars/proc/mob_moved(atom/movable/mover)
	if(wielded)
		unwield(mover)

/obj/item/binoculars/update_wield(mob/user)
	if(wielded)
		user.register_event(/event/moved, src, nameof(src::mob_moved()))
		user.visible_message("\The [user] holds \the [src] up to \his eyes.","You hold \the [src] up to your eyes.")
		item_state = "binoculars_wielded"
		user.regenerate_icons()
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(C.view + 7)
	else
		user.unregister_event(/event/moved, src, nameof(src::mob_moved()))
		user.visible_message("\The [user] lowers \the [src].","You lower \the [src].")
		item_state = "binoculars"
		user.regenerate_icons()
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(C.view - 7)
