/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	hitsound = "sound/weapons/whip.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_COMBAT + "=4"
	attack_verb = list("flogs", "whips", "lashes", "disciplines")

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/melee/morningstar
	name = "morningstar"
	desc = "A long mace with a round, spiky end. Very heavy."
	icon_state = "morningstar"
	item_state = "morningstar"
	hitsound = 'sound/weapons/heavysmash.ogg'
	w_class = W_CLASS_LARGE
	origin_tech = Tc_COMBAT + "=4"
	attack_verb = list("bashes", "smashes", "pulverizes")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')

	throwforce = 5
	force = 20

//BUTTERFLY KNIVES//
//Ported from HIPPIESTATION (with their knowledge)
/obj/item/weapon/melee/butterfly_knife
	name = "Butterfly Knife"
	desc = "A rather tricky weapon to use that is easy to conceal. Ideal for backstabbing."
	force = 2
	icon_state = "butterflyknife0"
	hitsound = 'sound/weapons/knife-hit.ogg'
	miss_sound = 'sound/weapons/miss.ogg'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_TINY
	var/folded = 1 //Used for toggle_fold and to check if you can backstab with it
	var/backstab_force = 70
	var/backstab_sound = 'sound/weapons/crit.ogg'

/obj/item/weapon/melee/butterfly_knife/attack_self(mob/living/user)
	if(clumsy_check(user) && prob(90))
		to_chat(user, "span class='danger'>You fiddle with the knife but cut your hand on it!</span>")
		user.take_organ_damage(5)
		return
	toggle_fold(user)
	..()

/obj/item/weapon/melee/butterfly_knife/proc/toggle_fold(var/mob/user)
	if(!folded)
		force = 2
		sharpness = 0
		icon_state = "butterflyknife0"
		item_state = null
		w_class = W_CLASS_TINY
		folded = 1
	else
		force = 10
		sharpness = 1.0
		icon_state = "butterflyknife1"
		item_state = "butterflyknife"
		w_class = W_CLASS_MEDIUM
		folded = 0
	to_chat(user, "<span class='warning'>You [folded ? "fold" : "unfold"] the [src]</span>")
	update_icon()

/obj/item/weapon/melee/butterfly_knife/attack(mob/living/M, mob/living/user)
	if(!..())
		return
	if(M.dir == user.dir && !M.lying && !folded && !(M == user))
		if(backstab_force)
			return backstab(user, M)

/obj/item/weapon/melee/butterfly_knife/proc/backstab(var/mob/living/user, var/mob/living/target)
	if(backstab_sound)
		playsound(src, backstab_sound, 100)
	if(ishuman(target)) //Only humans have chests, backstab the chest
		var/mob/living/carbon/human/H = target
		H.apply_damage(backstab_force, BRUTE, LIMB_CHEST)
	else //Deal conventional backstab damage to a non-human
		target.apply_damage(backstab_force, BRUTE)

///obj/item/weapon/melee/butterfly_knife/admin/backstab
