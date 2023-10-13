#define AIRBORNE_TIME 8
#define ROTATION 360

/obj/structure/blob_volcano
	name = "blob volcano"

	icon = 'icons/mob/blob/blob.dmi'
	icon_state = "blob_factory_2"
	anchored = FALSE

	var/obj/item/weapon/reagent_containers/glass/beaker/large/internal_storage = new()
	var/list/food_items = list()
	var/max_items = 30
	var/processing_liquids = FALSE

	var/explosion_sound = 'sound/effects/Explosion_Small1.ogg'
	var/explosion_range = 3

/obj/structure/blob_volcano/New()
	..()
	for (var/i = 1 to src.max_items)
		food_items += new /obj/item/weapon/reagent_containers/food/snacks/meat/blob
	src.internal_storage.name = "blob volcano"

/obj/structure/blob_volcano/proc/explode()
	playsound(src.loc, explosion_sound, 100, 1)
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
	const/var/vertex_height = 64

	I.pixel_x = random_offset_x
	I.pixel_y = random_offset_y

	animate(
		I,
		pixel_y = pixel_y + distance_y / 2 + vertex_height,
		pixel_x = pixel_x + distance_x / 2,
		transform = turn(matrix() * 2, rotation / 2),
		time = AIRBORNE_TIME / 2,
		loop = 1,
		easing = LINEAR_EASING
		)

	testing("[I.pixel_y]")
	animate(
		pixel_y = pixel_y + distance_y + random_offset_y,
		pixel_x = pixel_x + distance_x + random_offset_x,
		transform = turn(matrix(), rotation),
		time = AIRBORNE_TIME / 2,
		loop = 1,
		easing = LINEAR_EASING
		)
	testing("[I.pixel_y]")
	spawn(AIRBORNE_TIME)
		I.forceMove(T, glide_size_override = 100)
		I.pixel_x = random_offset_x
		I.pixel_y = random_offset_y

/obj/structure/blob_volcano/kick_act(mob/living/carbon/human/H)
	var/msg = ""
	playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
	if (src.food_items.len < 1)
		msg = ", but nothing happens."
	else
		msg = ", causing the volcano to erupt!"
		spawn(5)
			src.explode()
	H.visible_message("<span class='danger'>[H] kicks \the [src][msg].</span>", "<span class='danger'>You kick \the [src][msg]</span>")

/obj/structure/blob_volcano/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/reagent_containers/food))
		if (src.food_items.len >= src.max_items)
			to_chat(user, "<span class='notice'>[src] is already filled to the brim!</span>")
			return TRUE
		user.drop_item(W, src)
		src.food_items.Add(W)
		to_chat(user, "<span class='notice'>You drop \the [W] into \the [src]'s gaping maw.</span>")
		return TRUE

	if (istype(W, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/C = W
		if (C.transfer(src.internal_storage, user, can_receive = FALSE, splashable_units = 0) && !src.processing_liquids)
			src.processing_liquids = TRUE
			spawn(30)
				src.process_internal_storage()
		return TRUE

	to_chat(user, "<span class='notice'>The [src]'s maw closes shut as you approach it with \the [W].</span>")

/obj/structure/blob_volcano/proc/process_internal_storage()
	if (src.internal_storage.is_empty())
		src.processing_liquids = FALSE
		return
	for (var/datum/reagent/nutriment/N in src.internal_storage.reagents.reagent_list)
		if (N.volume < 10)
			break
		if (src.food_items.len >= src.max_items)
			return
		var/obj/item/weapon/reagent_containers/food/snacks/meat/blob/B = new()
		src.food_items.Add(B)
		src.internal_storage.reagents.remove_reagent(NUTRIMENT, 10, TRUE)
		visible_message("[src] squirms!")
		spawn(100)
			src.process_internal_storage()
		return
	internal_storage.reagents.remove_any(10)
	visible_message("[src] churns...")
	spawn(100)
		src.process_internal_storage()

#undef ROTATION
#undef AIRBORNE_TIME
