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
	flags = SLOWDOWN_WHEN_CARRIED
	var/obj/item/wielding = null

/obj/item/offhand/dropped(user)
	if(!wielding)
		returnToPool(src)
		return null
	return wielding.unwield(user)


/obj/item/offhand/unwield(user)
	if(!wielding)
		returnToPool(src)
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
	slot_flags = SLOT_BACK
	attack_verb = list("attacks", "chops", "cleaves", "tears", "cuts")
	flags = FPRINT | TWOHANDABLE

/obj/item/weapon/fireaxe/update_wield(mob/user)
	..()
	item_state = "fireaxe[wielded ? 1 : 0]"
	force = wielded ? 40 : initial(force)
	if(user)
		user.update_inv_hands()

/obj/item/weapon/fireaxe/suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is smashing \himself in the head with the [src.name]! It looks like \he's commit suicide!</span>")
		return (BRUTELOSS)

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
			W.Destroy(brokenup = 1)
		else
			qdel(A)
			A = null


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT | TWOHANDABLE
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/dualsaber/update_wield(mob/user)
	..()
	icon_state = "dualsaber[wielded ? 1 : 0]"
	item_state = "dualsaber[wielded ? 1 : 0]"
	force = wielded ? 30 : 3
	w_class = wielded ? 5 : 2
	sharpness_flags = wielded ? SHARP_TIP | SHARP_BLADE | INSULATED_EDGE | HOT_EDGE | CHOPWOOD : 0
	sharpness = wielded ? 1.5 : 0
	hitsound = wielded ? "sound/weapons/blade1.ogg" : "sound/weapons/empty.ogg"
	if(user)
		user.update_inv_hands()
	playsound(get_turf(src), wielded ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 50, 1)
	return

/obj/item/weapon/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if(clumsy_check(user) && (wielded) &&prob(40))
		to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn for(var/i=1, i<=8, i++)
			user.dir = turn(user.dir, 45)
			sleep(1)

/obj/item/weapon/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0
/*
 * Banana Bunch
 */
/obj/item/weapon/dualsaber/bananabunch
	icon_state = "bananabunch0"
	name = "banana bunch"
	desc = "Potential for some serious chaos."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT | TWOHANDABLE
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/dualsaber/bananabunch/update_wield(mob/user)
	..()
	icon_state = "bananabunch[wielded ? 1 : 0]"
	item_state = "bananabunch[wielded ? 1 : 0]"
	force = wielded ? 30 : 3
	w_class = wielded ? 5 : 2
	sharpness_flags = wielded ? SHARP_TIP | SHARP_BLADE | INSULATED_EDGE | HOT_EDGE | CHOPWOOD : 0
	sharpness = wielded ? 1.5 : 0
	hitsound = wielded ? "sound/weapons/blade1.ogg" : "sound/weapons/empty.ogg"
	if(user)
		user.update_inv_hands()
	playsound(get_turf(src), wielded ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 50, 1)
	return

/obj/item/weapon/dualsaber/bananabunch/attack(target as mob, mob/living/user as mob)
	if(user.mind && !(user.mind.assigned_role == "Clown"))
		to_chat(user, "<span class='warning'>Your clumsy hands fumble and you slice yourself open with [src].</span>")
		user.take_organ_damage(40,50)
		return
	if((wielded) && (user.mind.assigned_role == "Clown"))
		..()
		spawn for(var/i=1, i<=8, i++)
			user.dir = turn(user.dir, 45)
			sleep(1)

/obj/item/weapon/dualsaber/bananabunch/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/dualsaber/bananabunch/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(2, 2, 1))
			M.simple_message("<span class='notice'>You slipped on [src]!</span>",
				"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/obj/item/weapon/dualsaber/bananabunch/clumsy_check(mob/living/user)
	return 0

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
	sharpness_flags = SHARP_TIP | SHARP_BLADE | CHOPWOOD
	w_class = W_CLASS_LARGE
	flags = FPRINT | TWOHANDABLE
	origin_tech = Tc_MAGNETS + "=4;" + Tc_COMBAT + "=5"

/obj/item/weapon/katana/hfrequency/update_wield(mob/user)
	..()
	item_state = "hfrequency[wielded ? 1 : 0]"
	force = wielded ? 200 : 50
	sharpness = wielded ? 100 : 2
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
	if(istype(W, /obj/item/weapon/organ/head))
		if(loc == user)
			user.drop_item(src, force_drop = 1)
		var/obj/structure/headpole/H = new (get_turf(src), W, src)
		user.drop_item(W, H, force_drop = 1)

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
	var/event_key

/obj/item/binoculars/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(wielded)
		unwield(holder)

/obj/item/binoculars/update_wield(mob/user)
	if(wielded)
		event_key = user.on_moved.Add(src, "mob_moved")
		user.visible_message("\The [user] holds \the [src] up to \his eyes.","You hold \the [src] up to your eyes.")
		item_state = "binoculars_wielded"
		user.regenerate_icons()
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(C.view + 7)
	else
		user.on_moved.Remove(event_key)
		user.visible_message("\The [user] lowers \the [src].","You lower \the [src].")
		item_state = "binoculars"
		user.regenerate_icons()
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.changeView(C.view - 7)

/obj/item/weapon/bloodlust
	icon_state = "bloodlust0"
	name = "high-frequency pincer blade \"bloodlust\""
	desc = "A scissor-like weapon made using two high-frequency machetes. Don't run with it in your hands."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 17
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	attack_delay = 25 // Heavy.
	w_class = W_CLASS_LARGE
	flags = FPRINT | TWOHANDABLE
	sharpness_flags = SHARP_BLADE | SERRATED_BLADE
	origin_tech = Tc_COMBAT + "=6" + Tc_SYNDICATE + "=6"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/event_key

/obj/item/weapon/bloodlust/update_wield(mob/user)
	..()
	icon_state = "bloodlust[wielded ? 1 : 0]"
	item_state = icon_state
	force = wielded ? 34 : initial(force)
	sharpness_flags = wielded ? SHARP_BLADE | SERRATED_BLADE | HOT_EDGE : initial(sharpness_flags)
	sharpness = wielded ? 2 : initial(sharpness)
	to_chat(user, wielded ? "<span class='warning'> [src] starts vibrating.</span>" : "<span class='notice'> [src] stops vibrating.</span>")
	playsound(user, wielded ? 'sound/weapons/hfmachete1.ogg' : 'sound/weapons/hfmachete0.ogg', 40, 0 )
	if(user)
		user.update_inv_hands()
	if(wielded)
		event_key = user.on_moved.Add(src, "mob_moved")
	else
		user.on_moved.Remove(event_key)
		event_key = null

/obj/item/weapon/bloodlust/attack(target as mob, mob/living/user)
	if(isliving(target))
		playsound(target, get_sfx("machete_hit"),50, 0)
	if(clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>Son of a bitch... You... got yourself.</span>")
		playsound(target, get_sfx("machete_hit"),50, 0)
		user.take_organ_damage(wielded ? 34 : 17)
		return
	..()

/obj/item/weapon/bloodlust/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(iscarbon(holder) && wielded)
		for(var/obj/effect/plantsegment/P in range(holder,0))
			qdel(P)

/obj/item/weapon/bloodlust/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/bloodlust/pickup(mob/user)
	playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You attach [src] to your arm.</span>")
	cant_drop = 1

/obj/item/weapon/bloodlust/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/weapon/screwdriver) && user.is_holding_item(src))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You detach [src] from your arm.</span>")
		user.drop_item(src, force_drop=1)

/obj/item/weapon/bloodlust/suicide_act(mob/user)
	. = (OXYLOSS)
	user.visible_message("<span class='danger'>[user] is putting \his neck between \the [src]s blades! It looks like \he's trying to commit suicide.</span>")
	spawn(2 SECONDS) //Adds drama.
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.organs_by_name)
			var/datum/organ/external/head/H = U.get_organ(LIMB_HEAD)
			if(istype(H) && ~H.status & ORGAN_DESTROYED)
				H.droplimb(1)
				playsound(U, get_sfx("machete_hit"),50, 0)
				blood_splatter(get_turf(user),U,1)
	return .
