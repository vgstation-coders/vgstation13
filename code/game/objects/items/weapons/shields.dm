/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the shield's wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	force = 5
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_LARGE
	starting_materials = list(MAT_IRON = 1000, MAT_GLASS = 7500)
	melt_temperature = MELTPOINT_GLASS
	origin_tech = Tc_MATERIALS + "=2"
	attack_verb = list("shoves", "bashes")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is smashing \his face into the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/shield/riot/IsShield()
	return 1

/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/melee/baton) || istype(W, /obj/item/weapon/melee/telebaton) || istype(W, /obj/item/weapon/melee/classic_baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/riot/buckler
	name = "buckler"
	desc = "A small wooden shield. Its surface area is small, but it's still somewhat effective."
	icon_state = "buckler"
	w_class = W_CLASS_MEDIUM
	slot_flags = 0
	starting_materials = list()

/obj/item/weapon/shield/riot/buckler/IsShield()
	return prob(33) //Only attempt to block 1/3 of attacks

/obj/item/weapon/shield/riot/buckler/on_block(damage, attack_text = "the_attack")
	if(damage > 10)
		if(prob(min(10*(damage-10), 75))) //Bucklers are prone to breaking apart
			var/turf/T = get_turf(src)
			T.visible_message("<span class='danger'>\The [src] breaks apart!</span>")
			var/mob/living/L = loc

			if(istype(L))
				L.drop_item(src, force_drop = 1)

			qdel(src)
			return

	return ..()

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"

/obj/item/weapon/shield/riot/roman/IsShield()
	return 1

/obj/item/weapon/shield/riot/roman/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()



/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shields.dmi', "right_hand" = 'icons/mob/in-hand/right/shields.dmi')
	flags = FPRINT
	siemens_coefficient = 1
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=4;" + Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	attack_verb = list("shoves", "bashes")
	var/active = 0

/obj/item/weapon/shield/energy/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the [src.name] to their head and activating it! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/shield/energy/IsShield()
	if(active)
		return 1
	else
		return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user as mob)
	if (clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_organ_damage(5)
	active = !active
	if (active)
		force = 10
		w_class = W_CLASS_LARGE
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		w_class = W_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	icon_state = "eshield[active]"
	item_state = "eshield[active]"
	user.regenerate_icons()
	add_fingerprint(user)
	return


/obj/item/weapon/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT
	siemens_coefficient = 1
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = W_CLASS_SMALL
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"


/obj/item/weapon/cloaking_device/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The cloaking device is now active.</span>")
		src.icon_state = "shield1"
	else
		to_chat(user, "<span class='notice'>The cloaking device is now inactive.</span>")
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/emp_act(severity)
	active = 0
	icon_state = "shield0"
	if(ismob(loc))
		loc:update_icons()
	..()

/obj/item/weapon/shield/riot/proto
	name = "Prototype Shield"
	desc = "Doubles as a sled!"
	icon_state = "protoshield"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shields.dmi', "right_hand" = 'icons/mob/in-hand/right/shields.dmi')

/obj/item/weapon/shield/riot/proto/IsShield()
	return 1

/obj/item/weapon/shield/riot/proto/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()


/obj/item/weapon/shield/riot/joe
	name = "Sniper Shield"
	desc = "Very useful for close-quarters sniping, regardless of how stupid that idea is."
	icon_state = "joeshield"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shields.dmi', "right_hand" = 'icons/mob/in-hand/right/shields.dmi')

/obj/item/weapon/shield/riot/joe/IsShield()
	return 1

/obj/item/weapon/shield/riot/joe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/riot/bone
	name = "bone shield"
	desc = "A somewhat gruesome shield that appears to be made of solid bone."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bone_shield"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shields.dmi', "right_hand" = 'icons/mob/in-hand/right/shields.dmi')
	siemens_coefficient = 0
	slot_flags = null
	force = 15
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	w_class = 5
	mech_flags = MECH_SCAN_ILLEGAL
	cant_drop = 1
	var/mob/living/simple_animal/borer/parent_borer = null

/obj/item/weapon/shield/riot/bone/New(atom/A, var/p_borer = null)
	..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		qdel(src)
	else
		processing_objects.Add(src)

/obj/item/weapon/shield/riot/bone/Destroy()
	if(parent_borer)
		if(parent_borer.channeling_bone_shield)
			parent_borer.channeling_bone_shield = 0
		if(parent_borer.channeling)
			parent_borer.channeling = 0
		parent_borer = null
	processing_objects.Remove(src)
	..()

/obj/item/weapon/shield/riot/bone/process()
	set waitfor = 0
	if(!parent_borer)
		return
	if(!parent_borer.channeling_bone_shield) //the borer has stopped sustaining the sword
		qdel(src)
	if(parent_borer.chemicals < 3) //the parent borer no longer has the chemicals required to sustain the shield
		qdel(src)
	else
		parent_borer.chemicals -= 3
