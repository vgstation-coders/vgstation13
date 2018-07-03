/mob/living/simple_animal/hostile/humanoid
	name = "human"

	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 1
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 7
	attacktext = "punches"
	a_intent = I_HURT

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15

	status_flags = CANPUSH

	var/obj/effect/landmark/corpse/corpse = /obj/effect/landmark/corpse
	var/list/items_to_drop = list()

	//A list with icons associated with icon states
	//The icons are shown on top of the mob, in the order of the list
	//Example: list('icons/mob/in-hand/right/items_righthand.dmi' = "cultblade")
	//
	//Intended for animated items that aren't so easy to add to the base sprite
	var/list/visible_items = list()
	var/needs_to_reload = FALSE
	var/bullets_remaining = 0
	var/reload_sound = 'sound/weapons/magdrop_1.ogg'
	var/drop_on_reload = null
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/mob/living/simple_animal/hostile/humanoid/New()
	..()

	for(var/I in visible_items)
		var/image/new_img = image(I, icon_state = visible_items[I], layer = MOB_LAYER)
		new_img.plane = MOB_PLANE
		overlays.Add(new_img)

/mob/living/simple_animal/hostile/humanoid/getarmor(var/def_zone, var/type)
	return armor[type]

/mob/living/simple_animal/hostile/humanoid/death(var/gibbed = FALSE)
	..(gibbed)
	if(corpse)
		new corpse(loc)

	if(items_to_drop.len)

		for(var/object in items_to_drop)

			if(ispath(object))
				new object (get_turf(src))
			else if(istype(object, /atom/movable))
				var/atom/movable/A = object
				A.forceMove(get_turf(src))

	qdel(src)

/mob/living/simple_animal/hostile/humanoid/Shoot()
	if(!needs_to_reload)
		..()
		return
	if(bullets_remaining > 0)
		bullets_remaining--
		..()
		return
	if(canmove)
		visible_message("<span class = 'warning'>\The [src] stops to reload!</span>")
		playsound(src, reload_sound, 100, 1)
		if(drop_on_reload)
			new drop_on_reload(src.loc)
		canmove = FALSE
		spawn(rand(initial(bullets_remaining)/2 SECONDS,initial(bullets_remaining)*2 SECONDS))
			visible_message("<span class = 'warning'>\The [src] reloads!</span>")
			canmove = TRUE
			bullets_remaining = initial(bullets_remaining)
	..()
