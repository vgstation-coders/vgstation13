/obj/structure/blob_volcano
	name = "bleb"
	desc = "A stunted blob entity that has been induced into an altered state through chemicals and microwave radiation. It reacts unexpectedly to certain reagents."

	icon = 'icons/obj/food.dmi'
	icon_state = "blob_volcano"
	anchored = FALSE

	var/obj/item/weapon/reagent_containers/glass/beaker/large/internal_storage = new()
	var/list/food_items = list()
	var/allow_any_item = FALSE
	var/max_items = 30
	var/processing_liquids = FALSE

	var/explosion_sound = 'sound/effects/Explosion_Small1.ogg'
	var/explosion_range = 3
	var/exploding = FALSE

	var/max_spores = 10
	var/list/spores = list()

/obj/structure/blob_volcano/New()
	..()
	for (var/i = 1 to src.max_items)
		food_items += new /obj/item/weapon/reagent_containers/food/snacks/meat/blob
	src.internal_storage.name = "blob volcano"
	src.exploding = TRUE
	spawn (30)
		src.explode()

/obj/structure/blob_volcano/proc/explode()
	spawn (5)
		var/matrix/transform = matrix()
		transform.Scale(4, 4)
		anim(target = src.loc, a_icon = src.icon, flick_anim = "blob_volcano_pulse", sleeptime = 15, lay = src.layer + 0.5, offX = 0, offY = 8, alph = 220, plane = BLOB_PLANE, trans = transform)
		playsound(src.loc, explosion_sound, 50, 1)
		src.toss_items()

/obj/structure/blob_volcano/proc/toss_items()
	var/list/target_turfs = list()

	for (var/turf/T in orange(explosion_range, src))
		if (T.density)
			continue
		target_turfs += T

	for (var/i = 1 to src.food_items.len)
		if (isemptylist(src.food_items))
			return

		var/T = pick(target_turfs)
		var/item = pick_n_take(food_items)
		src.toss_item(item, T)

/obj/structure/blob_volcano/proc/toss_item(obj/Item, turf/T)
	var/obj/I = Item
	I.forceMove(src.loc)
	var/random_offset_x = rand(-16, 16)
	var/random_offset_y = rand(-16, 16)
	var/distance_y = (T.y - I.y) * WORLD_ICON_SIZE
	var/distance_x = (T.x - I.x) * WORLD_ICON_SIZE
	var/rotation = rand(0, 360)
	var/const/vertex_height = 64
	var/const/airborne_time = 8

	I.pixel_x = random_offset_x
	I.pixel_y = random_offset_y

	animate(
		I,
		pixel_y = pixel_y + distance_y / 2 + vertex_height,
		pixel_x = pixel_x + distance_x / 2,
		transform = turn(matrix() * 2, rotation / 2),
		time = airborne_time / 2,
		loop = 1,
		easing = LINEAR_EASING
		)

	animate(
		pixel_y = pixel_y + distance_y + random_offset_y,
		pixel_x = pixel_x + distance_x + random_offset_x,
		transform = turn(matrix(), rotation),
		time = airborne_time / 2,
		loop = 1,
		easing = LINEAR_EASING
		)

	spawn(airborne_time)
		I.forceMove(T, glide_size_override = 100)
		I.pixel_x = random_offset_x
		I.pixel_y = random_offset_y

/obj/structure/blob_volcano/kick_act(mob/living/carbon/human/H)
	var/msg = ", but nothing happens."
	playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
	if (src.food_items.len >= 1 && prob((src.max_items / src.food_items.len) * 100))
		msg = ", causing an eruption!"
		spawn(5)
			src.explode()
	H.visible_message("<span class='danger'>[H] kicks \the [src][msg].</span>", "<span class='danger'>You kick \the [src][msg]</span>")

/obj/structure/blob_volcano/attackby(obj/item/W, mob/user)
	if (user.a_intent == I_HURT && istype(W, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/C = W
		if (C.transfer(src.internal_storage, user, can_receive = FALSE, splashable_units = 0) && !src.processing_liquids)
			src.processing_liquids = TRUE
			spawn(30)
				src.process_internal_storage()
		return TRUE

	if (istype(W, /obj/item/weapon/reagent_containers/food) || src.allow_any_item)
		if (src.food_items.len >= src.max_items)
			to_chat(user, "<span class='notice'>[src] is already filled to the brim!</span>")
			return TRUE
		user.drop_item(W, src)
		src.food_items.Add(W)
		to_chat(user, "<span class='notice'>You drop \the [W] into \the [src]'s gaping maw.</span>")
		return TRUE

	to_chat(user, "<span class='notice'>\The [src]'s maw closes shut as you approach it with \the [W].</span>")
	return TRUE

/obj/structure/blob_volcano/proc/process_internal_storage()
	if (src.internal_storage.is_empty())
		src.processing_liquids = FALSE
		visible_message("[src] calms down...")
		return

	for (var/datum/reagent/nutriment/N in src.internal_storage.reagents.reagent_list)
		if (N.volume < 10)
			break
		if (src.food_items.len >= src.max_items)
			break
		var/obj/item/weapon/reagent_containers/food/snacks/meat/blob/B = new()
		src.food_items.Add(B)
		src.internal_storage.reagents.remove_reagent(NUTRIMENT, 10, TRUE)
		visible_message("[src] squirms!")
		spawn(100)
			src.process_internal_storage()
		return

	for (var/datum/reagent/mutagen/M in src.internal_storage.reagents.reagent_list)
		if (M.volume < 5)
			break
		if (src.spores.len >= src.max_spores)
			break
		new/mob/living/simple_animal/hostile/blobspore/domesticated(src.loc, src)
		src.internal_storage.reagents.remove_reagent(MUTAGEN, 5, TRUE)
		visible_message("[src] hisses!")
		spawn(100)
			src.process_internal_storage()
		return

	internal_storage.reagents.remove_any(10)
	visible_message("[src] churns...")
	spawn(100)
		src.process_internal_storage()

// Blob spores as created by the cookable blob volcano
// This iteration of them will have them just be neutral pet critters
/mob/living/simple_animal/hostile/blobspore/domesticated
	name = "Blob Spore"
	desc = "A form of blob antibodies that have lost their overmind."
	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blobpodfriendly"
	icon_living = "blobpodfriendly"
	attacktext = "hits"
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/tap.ogg'
	faction = "neutral"
	turns_per_move = 3

	var/obj/structure/blob_volcano/parent = null

/mob/living/simple_animal/hostile/blobspore/domesticated/New(loc, var/obj/structure/blob_volcano/parent_volcano)
	if(istype(parent_volcano))
		src.parent = parent_volcano
		src.parent.spores += src
	..()

/mob/living/simple_animal/hostile/blobspore/domesticated/Destroy()
	if(src.parent)
		src.parent.spores -= src
	..()

/mob/living/simple_animal/hostile/blobspore/domesticated/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/pen/) || istype(W, /obj/item/toy/crayon))
		var/new_name = input(user, "Set a new name for your friend!", "Spore name change", src.name)
		src.name = new_name
	else
		..()
