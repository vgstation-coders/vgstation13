//
// Abstract Class
//

/mob/living/simple_animal/hostile/mannequin
	name = "human marble mannequin"
	desc = "Jesus Christ, it DID come alive after all."
	icon = 'icons/mob/mannequin.dmi'
	icon_state = "mannequin_marble_human"
	icon_living = "mannequin_marble_human"

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 1
	maxHealth = 90
	health = 90

	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/weapons/genhit1.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	mob_property_flags = MOB_CONSTRUCT
	faction = "mannequin"

	var/obj/item/equipped_melee_weapon = null
	var/obj/item/equipped_ranged_weapon = null
	var/list/clothing = list()

	var/timer = 80 //in seconds
	var/mob/living/captured_mob
	var/intialTox = 0
	var/intialFire = 0
	var/intialBrute = 0
	var/intialOxy = 0
	var/dissolving = FALSE

	var/additional_damage = 0//tracking how much damage we took

	blooded = FALSE


/mob/living/simple_animal/hostile/mannequin/New()
	..()
	clothing = list(
		SLOT_MANNEQUIN_ICLOTHING,
		SLOT_MANNEQUIN_FEET,
		SLOT_MANNEQUIN_GLOVES,
		SLOT_MANNEQUIN_EARS,
		SLOT_MANNEQUIN_OCLOTHING,
		SLOT_MANNEQUIN_EYES,
		SLOT_MANNEQUIN_BELT,
		SLOT_MANNEQUIN_MASK,
		SLOT_MANNEQUIN_HEAD,
		SLOT_MANNEQUIN_BACK,
		SLOT_MANNEQUIN_ID,
		)

/mob/living/simple_animal/hostile/mannequin/Destroy()
	equipped_melee_weapon = null
	equipped_ranged_weapon = null
	held_items.len = 0
	clothing.len = 0
	..()

/mob/living/simple_animal/hostile/mannequin/Life()
	. = ..()
	if (.)
		if (dissolving || (timer < 0))
			return
		timer--
		if (captured_mob)
			captured_mob.setToxLoss(intialTox)
			captured_mob.adjustFireLoss(intialFire - captured_mob.getFireLoss())
			captured_mob.adjustBruteLoss(intialBrute - captured_mob.getBruteLoss())
			captured_mob.setOxyLoss(intialOxy)
			if (timer >= 5)
				captured_mob.Paralyse(2)
		if (timer <= 0)
			freeCaptive()
			qdel(src)

/mob/living/simple_animal/hostile/mannequin/proc/dissolve()
	if(dissolving)
		return

	visible_message("<span class='notice'>The statue's surface begins cracking and dissolving!</span>")

	dissolving = TRUE

	spawn(10)
		for(var/i=1 to 5)
			for(var/mob/living/L in contents)
				L.adjustBruteLoss(10)
				if (L.health <= 0)
					L.mutations |= M_NOCLONE

					if(ishuman(L) && !(M_HUSK in L.mutations))
						var/mob/living/carbon/human/H = L
						H.ChangeToHusk()
				sleep(10)

		breakDown()
		qdel(src)


/mob/living/simple_animal/hostile/mannequin/death(var/gibbed = FALSE)
	..(TRUE)
	breakDown()
	qdel(src)

////////////////////////////////////////////////////START - MANNEQUIN DEFENSE////////////////////////////////////////////

/mob/living/simple_animal/hostile/mannequin/bullet_act(var/obj/item/projectile/P, var/def_zone)
	//ablative armor
	for (var/obj/item/clothing/suit/armor/laserproof/ablative in clothing)
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
			var/reflectchance = ablative.basereflectchance - round(P.damage/3)
			if(!(def_zone in list(LIMB_CHEST, LIMB_GROIN)))
				reflectchance /= 2
			if(prob(reflectchance))
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s [ablative.name]!</span>")

				if(!istype(P, /obj/item/projectile/beam)) //beam has its own rebound-call-logic
					P.reflected = 1
					P.rebound(src)

				return PROJECTILE_COLLISION_REBOUND // complete projectile permutation

	//shield
	for(var/obj/item/I in clothing)
		if(I.IsShield() && I.on_block(P.damage, P))
			P.on_hit(src, 100)
			return PROJECTILE_COLLISION_BLOCKED

	var/absorb = run_armor_check(def_zone, P.flag, armor_penetration = P.armor_penetration)
	if(absorb >= 100)
		P.on_hit(src,2)
		return PROJECTILE_COLLISION_BLOCKED
	if(!P.nodamage)
		var/damage = run_armor_absorb(def_zone, P.flag, P.damage)
		apply_damage(damage, P.damage_type, def_zone, absorb, P.is_sharp(), used_weapon = P)
	P.on_hit(src, absorb)
	return PROJECTILE_COLLISION_DEFAULT

/mob/living/simple_animal/hostile/mannequin/proc/checkarmor(var/def_zone, var/type)
	if(!type)
		return 0
	var/protection = 0
	var/list/body_parts = list(
		clothing[SLOT_MANNEQUIN_HEAD],
		clothing[SLOT_MANNEQUIN_MASK],
		clothing[SLOT_MANNEQUIN_OCLOTHING],
		clothing[SLOT_MANNEQUIN_ICLOTHING],
		clothing[SLOT_MANNEQUIN_GLOVES],
		clothing[SLOT_MANNEQUIN_FEET]
		)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & limb_define_to_part_define(def_zone))
				protection += C.get_armor(type)
			for(var/obj/item/clothing/accessory/A in C.accessories)
				if(A.body_parts_covered & limb_define_to_part_define(def_zone))
					protection += A.get_armor(type)
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		protection += M.rad_protection
	return protection

/mob/living/simple_animal/hostile/mannequin/getarmor(var/def_zone, var/type)
	if(def_zone)
		return checkarmor(ran_zone(def_zone), type)

	var/armorval = 0
	var/limbnum = 0
	for(var/slot in clothing)
		armorval += checkarmor(slot, type)
		limbnum++
	return (armorval/max(limbnum, 1))

/mob/living/simple_animal/hostile/mannequin/getarmorabsorb(var/def_zone, var/type)
	if(def_zone)
		return checkarmorabsorb(ran_zone(def_zone), type)

	var/armorval = 0
	var/limbnum = 0
	for(var/slot in clothing)
		armorval += checkarmorabsorb(slot, type)
		limbnum++
	return (armorval/max(limbnum, 1))

/mob/living/simple_animal/hostile/mannequin/proc/checkarmorabsorb(var/def_zone, var/type)
	if(!type)
		return 0
	var/protection = 0
	var/list/body_parts = list(
		clothing[SLOT_MANNEQUIN_HEAD],
		clothing[SLOT_MANNEQUIN_MASK],
		clothing[SLOT_MANNEQUIN_OCLOTHING],
		clothing[SLOT_MANNEQUIN_ICLOTHING],
		clothing[SLOT_MANNEQUIN_GLOVES],
		clothing[SLOT_MANNEQUIN_FEET]
		)
	for(var/bp in body_parts)
		if(istype(bp, /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & limb_define_to_part_define(def_zone))
				protection += C.get_armor_absorb(type)
			for(var/obj/item/clothing/accessory/A in C.accessories)
				if(A.body_parts_covered & limb_define_to_part_define(def_zone))
					protection += A.get_armor_absorb(type)
	return protection

////////////////////////////////////////////////////END - MANNEQUIN DEFENSE////////////////////////////////////////////


/mob/living/simple_animal/hostile/mannequin/proc/freeCaptive()
	if (!captured_mob)
		return
	captured_mob.timestopped = 0
	captured_mob.forceMove(loc)
	for(var/cloth in clothing)
		var/obj/O = clothing[cloth]
		if (O)
			switch(cloth)
				if(SLOT_MANNEQUIN_ICLOTHING)
					captured_mob.equip_to_slot_or_drop(O, slot_w_uniform)
				if(SLOT_MANNEQUIN_FEET)
					captured_mob.equip_to_slot_or_drop(O, slot_shoes)
				if(SLOT_MANNEQUIN_GLOVES)
					captured_mob.equip_to_slot_or_drop(O, slot_gloves)
				if(SLOT_MANNEQUIN_EARS)
					captured_mob.equip_to_slot_or_drop(O, slot_ears)
				if(SLOT_MANNEQUIN_OCLOTHING)
					captured_mob.equip_to_slot_or_drop(O, slot_wear_suit)
				if(SLOT_MANNEQUIN_EYES)
					captured_mob.equip_to_slot_or_drop(O, slot_glasses)
				if(SLOT_MANNEQUIN_BELT)
					captured_mob.equip_to_slot_or_drop(O, slot_belt)
				if(SLOT_MANNEQUIN_MASK)
					captured_mob.equip_to_slot_or_drop(O, slot_wear_mask)
				if(SLOT_MANNEQUIN_HEAD)
					if (iscorgi(captured_mob))
						var/mob/living/simple_animal/corgi/corgi = captured_mob
						O.forceMove(captured_mob)
						corgi.inventory_back = O
						corgi.regenerate_icons()
					else
						captured_mob.equip_to_slot_or_drop(O, slot_head)
				if(SLOT_MANNEQUIN_BACK)
					if (iscorgi(captured_mob))
						var/mob/living/simple_animal/corgi/corgi = captured_mob
						corgi.place_on_head(O)
					else
						captured_mob.equip_to_slot_or_drop(O, slot_back)
				if(SLOT_MANNEQUIN_ID)
					captured_mob.equip_to_slot_or_drop(O, slot_wear_id)
	clothing.len = 0

	for(var/index = 1 to held_items.len)
		var/obj/item/tool = held_items[index]
		if (!tool)
			continue
		captured_mob.put_in_hands(tool)
	held_items.len = 0

	captured_mob.dir = dir
	captured_mob.apply_damage(additional_damage)

/mob/living/simple_animal/hostile/mannequin/proc/breakDown()
	visible_message("<span class='warning'><b>[src]</b> collapses!</span>")
	new /obj/effect/decal/cleanable/dirt(loc)
	playsound(loc, 'sound/effects/stone_crumble.ogg', 100, 1)
	if (captured_mob)
		if (dissolving)
			freeCaptive()
			return
		else
			captured_mob.gib()
	for(var/cloth in clothing)
		if(clothing[cloth])
			var/obj/item/cloth_to_drop = clothing[cloth]
			cloth_to_drop.mannequin_unequip(src)
			cloth_to_drop.forceMove(loc)
			clothing[cloth] = null
	for(var/obj/item/item_to_drop in held_items)
		item_to_drop.mannequin_unequip(src)
		item_to_drop.forceMove(loc)
		held_items -= item_to_drop


//If we're holding a gun, we can shoot it forever. Screw coding actual ammo management here, this is already complex enough.
/mob/living/simple_animal/hostile/mannequin/proc/equipGun(var/obj/item/weapon/gun/gun)
	if (istype(gun, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/energy_gun = gun
		projectiletype = energy_gun.projectile_type
	else if (istype(gun, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/projectile_gun = gun
		if (projectile_gun.ammo_type)
			var/obj/item/ammo_casing/ac = new projectile_gun.ammo_type()
			projectiletype = ac.projectile_type
			casingtype = projectile_gun.ammo_type
			qdel(ac)
	if (projectiletype)
		ranged = 1
		ranged_cooldown_cap = 2
		retreat_distance = 3
		minimum_distance = 3
		projectilesound = gun.fire_sound
		equipped_ranged_weapon = gun

/mob/living/simple_animal/hostile/mannequin/proc/ChangeOwner(var/mob/owner)
	LoseTarget()
	faction = "\ref[owner]"

/mob/living/simple_animal/hostile/mannequin/wood
	name = "human wooden mannequin"
	icon_state = "mannequin_wooden_human"
	icon_living = "mannequin_wooden_human"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	maxHealth = 30
	health = 30

/mob/living/simple_animal/hostile/mannequin/wood/breakDown()
	visible_message("<span class='warning'><b>[src]</b> collapses!</span>")
	playsound(loc, 'sound/effects/woodcutting.ogg', 100, 1)
	new /obj/item/stack/sheet/wood(loc, 5)
	for(var/obj/cloth in clothing)
		cloth.forceMove(loc)
		clothing -= cloth
	new /obj/effect/decal/cleanable/dirt(loc)

/mob/living/simple_animal/hostile/mannequin/cyber
	name = "human cyber mannequin"
	icon_state = "mannequin_cyber_human"
	icon_living = "mannequin_cyber_human"
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 10
	maxHealth = 150
	health = 150

/mob/living/simple_animal/hostile/mannequin/cyber/breakDown()
	visible_message("<span class='warning'><b>[src]</b> explodes!</span>")
	explosion(loc,0,0,2)
	playsound(loc, 'sound/effects/sparks4.ogg', 100, 1)
	new /obj/item/stack/sheet/metal(loc, 5)
	var/parts_list = list(
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/r_leg,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/l_arm,
		)
	for(var/part in parts_list)
		if(prob(40))
			new part(loc)
	for(var/obj/cloth in clothing)
		cloth.forceMove(loc)
		clothing -= cloth
	new /obj/effect/decal/cleanable/dirt(loc)

/mob/living/simple_animal/hostile/mannequin/cultify()
	var/mob/living/simple_animal/hostile/mannequin/cult/C = new(loc)
	C.dir = dir
	C.anchored = anchored
	C.overlays |= overlays
	for(var/obj/cloth in clothing)
		cloth.forceMove(C)
		clothing -= cloth
		C.clothing += cloth
	qdel(src)

/mob/living/simple_animal/hostile/mannequin/cult
	name = "cult mannequin"
	icon_state = "mannequin_cult"
	icon_living = "mannequin_cult"
	faction = "cult"
	supernatural = 1
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")

/mob/living/simple_animal/hostile/mannequin/cult/breakDown()
	new /obj/item/weapon/ectoplasm(loc)
	..()

/mob/living/simple_animal/hostile/mannequin/cult/CanAttack(var/atom/the_target)
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/mannequin/cult/New()
	..()
	add_language(LANGUAGE_CULT)
	default_language = all_languages[LANGUAGE_CULT]
	init_language = default_language

/mob/living/simple_animal/hostile/mannequin/cult/cultify()
	return
