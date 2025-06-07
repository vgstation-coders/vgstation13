/datum/visioneffect/nullrod
	name = "nullrod sight"
	priority = 1
	var/list/image/cached_images = list()

/datum/visioneffect/nullrod/process_hud(var/mob/V)
	..()
	if(!V.client)
		return
	var/i = 1
	for (var/image/I in cached_images)
		I.loc = null
		V.client.images -= I
	for (var/mob/living/carbon/C in view(7,V))
		var/obj/item/weapon/nullrod/N = locate(/obj/item/weapon/nullrod) in get_contents_in_object(C)
		if (N)
			if (i > cached_images.len)
				var/image/I = image('icons/mob/mob.dmi', loc = C, icon_state = "vampnullrod")
				I.plane = ABOVE_LIGHTING_PLANE
				cached_images += I
				V.client.images += I
			else
				cached_images[i].loc = C
				V.client.images += cached_images[i]
			i++

/datum/visioneffect/nullrod/on_remove(var/mob/V)
	..()
	for (var/image/I in cached_images)
		I.loc = null
		V.client.images -= I
