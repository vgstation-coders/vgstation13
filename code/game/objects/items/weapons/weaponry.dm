/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	flags = FPRINT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	attack_verb = list("bans")


/obj/item/weapon/banhammer/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS|SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = W_CLASS_MEDIUM
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")


/obj/item/weapon/sord/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	user.adjustBruteLoss(0.5)
	return ..()

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "claymore"
	item_state = null
	hitsound = 'sound/weapons/bloodyslice.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	sharpness = 1.2
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")


/obj/item/weapon/claymore/IsShield()
	return 1

/obj/item/weapon/claymore/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/claymore/cultify()
	new /obj/item/weapon/melee/legacy_cultblade(loc)
	..()

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "katana"
	item_state = null
	hitsound = 'sound/weapons/bloodyslice.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	sharpness = 1.2
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/katana/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/katana/IsShield()
	return 1

//Special weeb katana in ninja.dm

/obj/item/weapon/katana/magic
	name = "moonlight-enchanted sword"
	desc = "Capable of cutting through anything except the things it can't cut through."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "enchanted"
	item_state = "enchanted"
	w_class = W_CLASS_GIANT//don't want it stored anywhere"

/obj/item/weapon/katana/magic/dropped(mob/user)
	..()
	qdel(src)

/obj/item/weapon/katana/magic/Destroy()
	var/turf/T = get_turf(src)
	if (T)
		anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "empdisable")
	..()

/obj/item/weapon/harpoon
	name = "harpoon"
	sharpness = 1.2
	sharpness_flags = SHARP_TIP
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	throwforce = 15
	w_class = W_CLASS_MEDIUM
	attack_verb = list("jabs","stabs","rips")

obj/item/weapon/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = FPRINT
	siemens_coefficient = 1
	force = 9
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 1875)
	w_type = RECYK_METAL
	attack_verb = list("hits", "bludgeons", "whacks", "bonks")


obj/item/weapon/wirerod/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/weapon/shard))
		user.visible_message("<span class='notice'>[user] starts securing \the [I] to the top of \the [src].</span>",\
		"<span class='info'>You attempt to create a spear by securing \the [I] to \the [src].</span>")

		if(do_after(user, get_turf(src), 5 SECONDS))
			if(!I || !src)
				return

			if(!user.drop_item(I))
				to_chat(user, "<span class='warning'>You can't let go of \the [I]! You quickly unsecure it from \the [src].</span>")
				return

			user.drop_item(src, force_drop = 1)

			var/obj/item/weapon/spear/S = new /obj/item/weapon/spear

			S.base_force = 5 + I.force
			S.force = S.base_force

			var/prefix = ""
			switch(S.force)
				if(-INFINITY to 5)
					prefix = "useless"
				if(5 to 9)
					prefix = "dull"
				if(11 to 19)
					prefix = "sharp"
				if(20 to 27)
					prefix = "exceptional"
				if(29 to INFINITY)
					prefix = "legendary"

			if(prefix)
				S.name = "[prefix] [S.name]"

			user.put_in_hands(S)
			user.visible_message("<span class='danger'>[user] creates a spear with \a [I] and \a [src]!</span>",\
			"<span class='notice'>You fasten \the [I] to the top of \the [src], creating \a [S].</span>")

			qdel(I)
			I = null
			qdel(src)

	else if(iswirecutter(I))
		var/obj/item/weapon/melee/baton/cattleprod/P = new /obj/item/weapon/melee/baton/cattleprod

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>")
		qdel(I)
		I =  null
		qdel(src)

	else if(istype(I, /obj/item/stack/rods))
		to_chat(user, "You fasten the metal rods together.")
		var/obj/item/stack/rods/R = I
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/rail_assembly/Q = new (get_turf(user))
			user.put_in_hands(Q)
		else
			new /obj/item/weapon/rail_assembly(get_turf(src.loc))
		R.use(1)
		qdel(src)

/obj/item/weapon/kitchen/utensil/knife/tactical
	name = "tactical knife"
	desc = "It makes you run faster."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "tacknife"
	item_state = "knife"
	force = 10
	flags = FPRINT | SLOWDOWN_WHEN_CARRIED
	slowdown = 0.999

/obj/item/weapon/kitchen/utensil/knife/tactical/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		slowdown = 0.8

/obj/item/weapon/kitchen/utensil/knife/skinning
	name = "skinning knife"
	desc = "Stalwart Goliath butchering edge. This, my friend, is a tool with a purpose."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "skinningknife"
	item_state = "skinningknife"
	force = 10

obj/item/weapon/banhammer/admin
	desc = "A banhammer specifically reserved for admins. Legends tell of a weapon that destroys the target to the utmost capacity."
	throwforce = 999
	force = 999

/obj/item/weapon/melee/bone_hammer
	name = "bone hammer"
	desc = "A large growth that appears to be made of solid bone. It looks heavy."
	icon_state = "bone_hammer"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	hitsound = 'sound/weapons/heavysmash.ogg'
	flags = FPRINT
	siemens_coefficient = 0
	slot_flags = null
	force = 25
	throwforce = 0
	w_class = 5
	sharpness = 0
	sharpness_flags = 0
	attack_verb = list("bludgeons", "smashes", "pummels", "crushes", "slams")
	mech_flags = MECH_SCAN_ILLEGAL
	cant_drop = 1
	var/mob/living/simple_animal/borer/parent_borer = null

/obj/item/weapon/melee/bone_hammer/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is smashing his face with \the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/melee/bone_hammer/afterattack(null, mob/living/user as mob|obj, null, null, null)
	user.delayNextAttack(50) //five times the regular attack delay

/obj/item/weapon/melee/bone_hammer/New(atom/A, var/p_borer = null)
	..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		qdel(src)
	else
		processing_objects.Add(src)

/obj/item/weapon/melee/bone_hammer/Destroy()
	if(parent_borer)
		if(parent_borer.channeling_bone_hammer)
			parent_borer.channeling_bone_hammer = 0
		if(parent_borer.channeling)
			parent_borer.channeling = 0
		parent_borer = null
	processing_objects.Remove(src)
	..()

/obj/item/weapon/melee/bone_hammer/process()
	set waitfor = 0
	if(!parent_borer)
		return
	if(!parent_borer.channeling_bone_hammer) //the borer has stopped sustaining the hammer
		qdel(src)
	if(parent_borer.chemicals < 10) //the parent borer no longer has the chemicals required to sustain the hammer
		qdel(src)
	else
		parent_borer.chemicals -= 10
		sleep(10)

/obj/item/weapon/bullwhip
	name = "bullwhip"
	desc = "An archaeologist's best friend."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "bullwhip"
	item_state = null
	hitsound = "sound/weapons/whip_crack.ogg"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 15
	var/whipitgood_bonus = 5 //energy dome bonus
	throwforce = 0
	w_class = W_CLASS_MEDIUM
	attack_verb = list("whips", "lashes", "thrashes", "flagellates", "flogs")

/obj/item/weapon/bullwhip/afterattack(atom/A, mob/living/user)
	if(user.Adjacent(A))
		user.delayNextAttack(10)
		return
	var/obj/item/projectile/beam/bullwhip/projectile = new(get_turf(user), get_dir(user, A), src, user)
	var/targeting = "chest"
	if(user.zone_sel)
		targeting = user.zone_sel.selecting
	projectile.launch_at(A,tar_zone = targeting,from = user)

/obj/item/weapon/bullwhip/attack(mob/M, mob/user)//mob/living/carbon/human/user
	var/force_original = 15
	sharpness = 1.2 //a whip can only cut things when it is actually whipping
	var/obj/item/clothing/head/energy_dome/ED
	if(user.is_wearing_item(ED))
		force += whipitgood_bonus
		visible_message("<span class='warning'>[user] whips it good!</span>")
	..()
	sharpness = 0
	force = force_original//return force back to normal

/obj/item/weapon/macuahuitl
	name = "wooden paddle"
	desc = "This doesn't look like it's capable of much damage."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "macuahuitl"
	item_state = "macuahuitl"
	hitsound = "sound/weapons/smash.ogg"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 2
	sharpness = 0
	siemens_coefficient = 1
	w_class = W_CLASS_MEDIUM
	attack_verb = list("smacks")
	var/list/blades = list(
		"blade_1" = null,
		"blade_2" = null,
		"blade_3" = null,
		"blade_4" = null,
		"blade_5" = null,
		"blade_6" = null,
		"blade_7" = null,
		"blade_8" = null,
		"blade_9" = null,
		"blade_10" = null)
	var/image/base_overlay		//This is a workaround for underlays somehow not showing up when the item is on the UI

/obj/item/weapon/macuahuitl/New()
	..()
	base_overlay = new
	base_overlay.appearance = appearance
	base_overlay.plane = FLOAT_PLANE
	overlays += base_overlay

/obj/item/weapon/macuahuitl/Destroy()
	if(blades.len)
		for(var/i in blades)
			var/blade = blades[i]
			blades.Remove(i)
			qdel(blade)
			blade = null
	..()

/obj/item/weapon/macuahuitl/proc/get_current_blade_count()
	var/blades_left = 0
	for(var/i in blades)
		if(blades[i])
			blades_left++
	return blades_left

/obj/item/weapon/macuahuitl/examine(mob/user)
	..()
	var/blades_left = get_current_blade_count()
	if(blades_left)
		to_chat(user, "<span class='info'>It has [blades_left] blade\s left.</span>")

/obj/item/weapon/macuahuitl/proc/update_blades()
	var/blades_left = get_current_blade_count()
	if(blades_left)
		name = "macuahuitl"
		desc = "Though the blades are sharp, they are also fragile."
		hitsound = "sound/weapons/bloodyslice.ogg"
		force = blades_left * 2
		sharpness = 2
		attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cleaves")
		sharpness_flags = SHARP_BLADE | INSULATED_EDGE
	else
		name = initial(name)
		desc = initial(desc)
		hitsound = initial(hitsound)
		force = initial(force)
		sharpness = initial(sharpness)
		attack_verb = list("smacks")
		sharpness_flags = 0

/obj/item/weapon/macuahuitl/attack(mob/M, mob/user)
	..()
	if(blades.len)
		for(var/i in blades)
			var/obj/item/weapon/shard/S = blades[i]
			var/break_chance = 15
			if(istype(S, /obj/item/weapon/shard/plasma))
				break_chance = round(break_chance * 0.66)
			if(prob(break_chance))
				break_shard(S, i)
	update_blades()

/obj/item/weapon/macuahuitl/proc/break_shard(var/obj/item/weapon/shard/to_break, var/slot_index)
	if(!to_break || !slot_index)
		return
	blades[slot_index] = null
	underlays -= to_break.appearance
	visible_message("<span class='warning'>One of \the [src]'s blades shatters!</span>")
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
	qdel(to_break)

/obj/item/weapon/macuahuitl/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/shard))
		var/slot_index
		for(var/i in blades)
			if(!blades[i])
				slot_index = i
				break
		if(!slot_index)
			to_chat(user, "<span class='notice'>You can't seem to fit another [W.name] into \the [src].</span>")
			return
		if(user.drop_item(W, src))
			to_chat(user, "You press \the [W] into the side of \the [src].")
			add_shard(W, slot_index)

/obj/item/weapon/macuahuitl/proc/add_shard(var/obj/item/weapon/shard/to_add, var/slot_index)
	if(!to_add || !slot_index)
		return
	blades[slot_index] = to_add
	playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
	update_blades()
	to_add.transform *= 0.5
	to_add.pixel_x += 5 * PIXEL_MULTIPLIER
	to_add.pixel_y -= 5 * PIXEL_MULTIPLIER
	switch(slot_index)
		if("blade_1")
			to_add.pixel_x -= 5 * PIXEL_MULTIPLIER
		if("blade_2")
			to_add.pixel_y += 5 * PIXEL_MULTIPLIER
		if("blade_3")
			to_add.pixel_x -= 8 * PIXEL_MULTIPLIER
			to_add.pixel_y += 3 * PIXEL_MULTIPLIER
		if("blade_4")
			to_add.pixel_y += 8 * PIXEL_MULTIPLIER
			to_add.pixel_x -= 3 * PIXEL_MULTIPLIER
		if("blade_5")
			to_add.pixel_x -= 11 * PIXEL_MULTIPLIER
			to_add.pixel_y += 6 * PIXEL_MULTIPLIER
		if("blade_6")
			to_add.pixel_y += 11 * PIXEL_MULTIPLIER
			to_add.pixel_x -= 6 * PIXEL_MULTIPLIER
		if("blade_7")
			to_add.pixel_x -= 14 * PIXEL_MULTIPLIER
			to_add.pixel_y += 9 * PIXEL_MULTIPLIER
		if("blade_8")
			to_add.pixel_y += 14 * PIXEL_MULTIPLIER
			to_add.pixel_x -= 9 * PIXEL_MULTIPLIER
		if("blade_9")
			to_add.pixel_x -= 17 * PIXEL_MULTIPLIER
			to_add.pixel_y += 12 * PIXEL_MULTIPLIER
		else
			to_add.pixel_y += 17 * PIXEL_MULTIPLIER
			to_add.pixel_x -= 12 * PIXEL_MULTIPLIER
	to_add.plane = FLOAT_PLANE
	underlays += to_add.appearance

//	if(!base_overlay)
//		base_overlay = new
//		base_overlay.appearance = appearance
//		base_overlay.plane = FLOAT_PLANE
//		overlays += base_overlay


/obj/item/weapon/hammer
	name = "smithing hammer"
	desc = "for those with a predeliction for applying concussive maintenance"
	icon_state = "hammer"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	force = 8
	hitsound = 'sound/weapons/toolbox.ogg'
