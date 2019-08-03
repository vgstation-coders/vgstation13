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

	var/list/clothing = list()

/mob/living/simple_animal/hostile/mannequin/death(var/gibbed = FALSE)
	..(TRUE)
	breakDown()
	qdel(src)

/mob/living/simple_animal/hostile/mannequin/proc/breakDown()
	visible_message("<span class='warning'><b>[src]</b> collapses!</span>")
	playsound(loc, 'sound/items/egg_squash.ogg', 100, 1)
	for(var/obj/cloth in clothing)
		cloth.forceMove(loc)
		clothing -= cloth
	getFromPool(/obj/effect/decal/cleanable/dirt,loc)

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
	getFromPool(/obj/item/stack/sheet/wood, loc, 5)
	for(var/obj/cloth in clothing)
		cloth.forceMove(loc)
		clothing -= cloth
	getFromPool(/obj/effect/decal/cleanable/dirt,loc)

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
	getFromPool(/obj/item/stack/sheet/metal, loc, 5)
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
	getFromPool(/obj/effect/decal/cleanable/dirt,loc)

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

/mob/living/simple_animal/hostile/mannequin/cult/cultify()
	return
