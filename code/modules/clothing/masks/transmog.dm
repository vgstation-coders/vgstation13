/obj/item/clothing/mask/morphing
	name = "curious mask"
	desc = "It doesn't really resemble anything, though it gives you an eerie and intense feeling nonetheless."
	icon_state = "morphing_mask"
	item_state = "chapmask"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = W_CLASS_SMALL
	mech_flags = MECH_SCAN_ILLEGAL
	var/target_type = null
	var/cursed = FALSE
	var/revert_spell_type //The path of the revert spell to use if not cursed, in case extra checks are necessary, etc. Leave undefined for the universal default.
	var/list/skin_to_mask = list(
		/obj/item/asteroid/goliath_hide         =   /obj/item/clothing/mask/morphing/goliath,
		/obj/item/clothing/head/bearpelt/real   =   /obj/item/clothing/mask/morphing/bear,
		/obj/item/stack/sheet/animalhide/corgi  =   /obj/item/clothing/mask/morphing/corgi,
		/obj/item/stack/sheet/animalhide/cat    =   /obj/item/clothing/mask/morphing/cat,
		/obj/item/stack/sheet/animalhide/monkey =   /obj/item/clothing/mask/morphing/monkey,
		/obj/item/stack/sheet/animalhide/lizard =   /obj/item/clothing/mask/morphing/lizard,
		/obj/item/stack/sheet/animalhide/xeno   =   /obj/item/clothing/mask/morphing/xeno,
		/obj/item/stack/sheet/animalhide/human  =   /obj/item/clothing/mask/morphing/human,
		/obj/item/weapon/ectoplasm              =   /obj/item/clothing/mask/morphing/ghost)

/obj/item/clothing/mask/morphing/New()
	..()
	if(cursed)
		name = "cursed [name]"

/obj/item/clothing/mask/morphing/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!M.client)
		return CANNOT_EQUIP
	if(slot == slot_wear_mask)
		if(!do_after(M, src, 5 SECONDS))
			return CANNOT_EQUIP
	return ..()

/obj/item/clothing/mask/morphing/equipped(mob/living/carbon/C, wear_mask)
	if(target_type && istype(C))
		if(C.get_item_by_slot(slot_wear_mask) == src)
			if(target_type != C.type)
				C.visible_message("<span class='danger'>As [C] puts on \the [src], \his body begins to shift and contort!</span>","<span class='danger'>As you put on \the [src], your body begins to shift and contort!</span>")
				var/turf/T = get_turf(C)
				var/location = T ? "[T.x], [T.y], [T.z]" : "nullspace"
				src.investigation_log(I_ARTIFACT, "|| [key_name(C)] has used a [cursed ? "cursed" : ""] mask of morphing ([src]) to transform into a [target_type]. (@[location])")
				message_admins("[key_name(C)] has used a[cursed ? " cursed" : ""] mask of morphing ([src]) to transform into a [target_type]. (@[formatJumpTo(C, "JMP")])")
				if(cursed)
					C.transmogrify(target_type)
				else
					C.transmogrify(target_type, revert_spell_type || TRUE)

/obj/item/clothing/mask/morphing/attackby(obj/item/weapon/W, mob/user)
	if(!target_type)
		var/obj/item/clothing/mask/morphing/T
		for(var/i in skin_to_mask)
			if(istype(W, i))
				var/chosen_type = skin_to_mask[i]
				T = new chosen_type(get_turf(src))
		if(T)
			to_chat(user, "<span class='notice'>You wrap \the [W] around \the [src].</span>")
			if(istype(W, /obj/item/stack/sheet/animalhide))
				var/obj/item/stack/sheet/animalhide/A = W
				A.use(1)
			else
				qdel(W)
			if(loc == user)
				user.drop_item(src, force_drop = 1)
				user.put_in_hands(T)
			qdel(src)

/obj/item/clothing/mask/morphing/proc/toggle_cursed()
	cursed = !cursed
	if(cursed)
		name = "cursed [initial(name)]"
	else
		name = initial(name)

/obj/item/clothing/mask/morphing/spider
	name = "mask of the spider"
	desc = "It appears to be modeled after a giant spider."
	target_type = /mob/living/simple_animal/hostile/giant_spider
	icon_state = "spider_mask"

/obj/item/clothing/mask/morphing/goliath
	name = "mask of the goliath"
	desc = "It appears to be modeled after a goliath."
	target_type = /mob/living/simple_animal/hostile/asteroid/goliath
	icon_state = "goliath_mask"

/obj/item/clothing/mask/morphing/bear
	name = "mask of the bear"
	desc = "It appears to be modeled after a space bear."
	target_type = /mob/living/simple_animal/hostile/bear
	icon_state = "bear_mask"

/obj/item/clothing/mask/morphing/corgi
	name = "mask of the corgi"
	desc = "It appears to be modeled after a corgi."
	target_type = /mob/living/simple_animal/corgi
	icon_state = "corgi_mask"

/obj/item/clothing/mask/morphing/cat
	name = "mask of the cat"
	desc = "It appears to be modeled after a cat."
	target_type = /mob/living/simple_animal/cat
	icon_state = "cat_mask"

/obj/item/clothing/mask/morphing/monkey
	name = "mask of the monkey"
	desc = "It appears to be modeled after a monkey."
	target_type = /mob/living/carbon/monkey
	icon_state = "monkey_mask"

/obj/item/clothing/mask/morphing/lizard
	name = "mask of the lizard"
	desc = "It appears to be modeled after a lizard."
	target_type = /mob/living/simple_animal/hostile/lizard
	icon_state = "lizard_mask"

/obj/item/clothing/mask/morphing/xeno
	name = "mask of the xenomorph"
	desc = "It appears to be modeled after a xenomorph."
	target_type = /mob/living/carbon/alien/humanoid/hunter
	icon_state = "xeno_mask"

/obj/item/clothing/mask/morphing/human
	name = "mask of the human"
	desc = "It appears to be modeled after a human."
	target_type = /mob/living/carbon/human
	icon_state = "human_mask"

/obj/item/clothing/mask/morphing/goat
	name = "mask of the goat"
	desc = "It appears to be modeled after a goat."
	target_type = /mob/living/simple_animal/hostile/retaliate/goat
	icon_state = "goat_mask"

/obj/item/clothing/mask/morphing/amorphous
	name = "amorphous mask"
	desc = "You can't really tell what this is supposed to be modeled after."
	icon_state = "amorphous_mask"

/obj/item/clothing/mask/morphing/amorphous/New()
	..()
	color = rgb(rand(0,255),rand(0,255),rand(0,255))
	//Remove cockatrices because they're somewhat OP when player controlled
	target_type = pick(existing_typesof(/mob/living/simple_animal) - (existing_typesof_list(blacklisted_mobs) + existing_typesof_list(boss_mobs) + /mob/living/simple_animal/scp_173 + existing_typesof(/mob/living/component) + /mob/living/simple_animal/pollywog))
/obj/item/clothing/mask/morphing/ghost
	name = "mask of the phantom"
	desc = "It appears to be modeled after a ghost. It looks as though it might disappear at any moment."
	target_type = /mob/dead/observer/deafmute
	icon_state = "ghost_mask"
	revert_spell_type = /spell/aoe_turf/revert_form/no_z2 //Don't

/obj/item/clothing/mask/morphing/ghost/equipped(mob/living/carbon/C, wear_mask)
	if(target_type && istype(C))
		if(C.get_item_by_slot(wear_mask) == src)
			if(target_type != C.type)
				C.visible_message("<span class='danger'>As [C] puts on \the [src], \his body begins to shift and contort!</span>","<span class='danger'>As you put on \the [src], your body begins to shift and contort!</span>")
				var/mob/M
				var/turf/T = get_turf(C)
				var/location = T ? "[T.x], [T.y], [T.z]" : "nullspace"
				src.investigation_log(I_ARTIFACT, "|| [key_name(C)] has used a [cursed ? "cursed" : ""] mask of morphing ([src]) to transform into a [target_type]. (@[location])")
				message_admins("[key_name(C)] has used a[cursed ? " cursed" : ""] mask of morphing ([src]) to transform into a [target_type]. (@[formatJumpTo(C, "JMP")])")
				if(cursed)
					M = C.transmogrify(target_type)
				else
					M = C.transmogrify(target_type, revert_spell_type || TRUE)
				M.forceMove(T)
				to_chat(M, "<span class='warning'>\The [src] dissipates into thin air!</span>")
				qdel(src)

/obj/item/clothing/mask/morphing/skelegiant //potential loot from defeating the skeleton surgeon mini-boss
	name = "mask of the skeleton"
	desc = "It appears to be modeled after a large skeleton."
	target_type = /mob/living/simple_animal/hostile/humanoid/surgeon/skeleton/morph
	icon_state = "skeleton_mask"