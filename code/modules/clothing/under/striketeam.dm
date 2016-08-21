var/list/deathsquad_uniforms = list()

/obj/item/clothing/under/deathsquad
	name = "deathsquad holosuit"
	desc = "A state-of-the-art suit featuring an holographic map of the area, to help the squad coordinate their efforts."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/altsuits.dmi', "right_hand" = 'icons/mob/in-hand/right/altsuits.dmi')
	icon_state = "deathsquad"
	item_state = "deathsquad"
	_color = "deathsquad"
	flags = FPRINT  | ONESIZEFITSALL
	action_button_name = "Toggle Holomap"
	var/mob/living/carbon/human/activator = null
	var/holomap_activated = 0
	var/list/holomap_images = list()

/obj/item/clothing/under/deathsquad/New()
	..()
	deathsquad_uniforms += src

/obj/item/clothing/under/deathsquad/Destroy()
	deathsquad_uniforms -= src
	..()

/obj/item/clothing/under/deathsquad/verb/togglemap()
	set name = "Toggle Holomap"
	set category = "Object"
	set src in usr
	if(usr.isUnconscious())
		return

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>Only humanoids can wear this suit</span>")
		return

	var/mob/living/carbon/human/H = usr

	if(H.w_uniform != src)
		to_chat(usr, "<span class='warning'>You need to wear the suit first</span>")
		return

	if(src.holomap_activated)
		holomap_activated = 0
		activator.client.images -= holomap_images
		activator = null
		holomap_images.len = 0
		processing_objects.Remove(src)
		to_chat(usr, "<span class='notice'>You disable the holomap.</span>")
	else
		holomap_activated = 1
		activator = usr
		processing_objects.Add(src)
		process()
		to_chat(usr, "<span class='notice'>You enable the holomap.</span>")

/obj/item/clothing/under/deathsquad/process()
	var/turf/T = get_turf(src)
	if((activator.w_uniform != src) || (!activator.client) || (holominimaps[T.z] == null))
		activator = null
		holomap_activated = 0
		processing_objects.Remove(src)
		return

	activator.client.images -= holomap_images

	holomap_images.len = 0

	var/image/bgmap = image(holominimaps[T.z])
	bgmap.pixel_x = -1*T.x + 240
	bgmap.pixel_y = -1*T.y + 241
	bgmap.plane = HUD_PLANE
	bgmap.layer = 1
	bgmap.color = "#0B74B4"
	bgmap.loc = activator.hud_used.holomap_obj
	holomap_images += bgmap

	for(var/obj/item/clothing/under/deathsquad/D)
		var/mob_indicator = -1
		var/turf/TD = get_turf(D)
		if(D == src)
			mob_indicator = 1
		else if((TD.z == T.z) && ishuman(D.loc))
			var/mob/living/carbon/human/H = D.loc
			if(H.w_uniform == D)
				if(H.stat == DEAD)
					mob_indicator = 2
				else
					mob_indicator = 0
			else
				continue
		if(mob_indicator != -1)
			var/image/I = image('icons/12x12.dmi',"ds[mob_indicator]")
			I.pixel_x = TD.x - T.x + 232
			I.pixel_y = TD.y - T.y + 233
			I.plane = HUD_PLANE
			if(mob_indicator == 1)
				I.layer = 3
			else
				I.layer = 2
			I.loc = activator.hud_used.holomap_obj
			animate(I,alpha = 255, time = 13, loop = -1, easing = SINE_EASING)
			animate(alpha = 0, time = 5, easing = SINE_EASING)
			animate(alpha = 255, time = 2, easing = SINE_EASING)
			holomap_images += I

	activator.client.images |= holomap_images

/obj/item/clothing/under/deathsquad/ui_action_click()
	togglemap()
