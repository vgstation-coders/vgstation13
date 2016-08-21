/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "It's some non-descript, slightly suspicious looking, civilian clothing."
	icon_state = "syndicate"
	item_state = "bl_suit"
	_color = "syndicate"
	species_fit = list(VOX_SHAPED)
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

//We want our sensors to be off, sensors are not tactical
/obj/item/clothing/under/syndicate/New()
	..()
	sensor_mode = 0

/obj/item/clothing/under/syndicate/combat
	name = "combat turtleneck"

/obj/item/clothing/under/syndicate/tacticool
	name = "\improper Tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	_color = "tactifool"
	species_fit = list(VOX_SHAPED)
	siemens_coefficient = 1

//not syndie technically but oh well
var/list/deathsquad_uniforms = list()

/obj/item/clothing/under/deathsquad
	name = "deathsquad holosuit"
	desc = "A state-of-the-art suit featuring an holographic map of the station, to help the squad coordinate their efforts."
	icon_state = "green"
	item_state = "g_suit"
	_color = "green"
	flags = FPRINT  | ONESIZEFITSALL
	action_button_name = "Toggle Holomap"
	var/mob/living/carbon/human/activator = null
	var/holomap_activated = 0
	var/list/holomap_helmets = list()

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
	if(src.holomap_activated)
		holomap_activated = 0
		activator.hud_used.holomap_obj.icon = null
		activator.hud_used.holomap_obj.alpha = 0
		activator.client.screen -= activator.hud_used.holomap_obj
		activator = null
		processing_objects.Remove(src)
		to_chat(usr, "You disable the holomap.")
	else
		holomap_activated = 1
		activator = usr
		processing_objects.Add(src)
		activator.client.screen += activator.hud_used.holomap_obj
		activator.hud_used.holomap_obj.icon = station_minimap
		activator.hud_used.holomap_obj.alpha = 255
		var/turf/T = get_turf(src)
		activator.hud_used.holomap_obj.screen_loc = "CENTER:[-1*(T.x)+145],CENTER:[-1*(T.y)+146]"
		to_chat(usr, "You enable the holomap.")

/obj/item/clothing/under/deathsquad/process()
	var/turf/T = get_turf(src)
	if((loc != activator) || (T.z != map.zMainStation))
		activator.hud_used.holomap_obj.icon = null
		activator.hud_used.holomap_obj.alpha = 0
		activator = null
		holomap_activated = 0
		processing_objects.Remove(src)
		return
	activator.hud_used.holomap_obj.screen_loc = "CENTER:[-1*(T.x)+145],CENTER:[-1*(T.y)+146]"

	activator.client.images -= holomap_helmets

	holomap_helmets.len = 0

	for(var/obj/item/clothing/under/deathsquad/D)
		var/mob_indicator = -1
		var/turf/TD = get_turf(D)
		if(D == src)
			mob_indicator = 1
		else if((TD.z == map.zMainStation) && istype(D.loc,/mob/living/carbon/human))
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
			I.pixel_x = TD.x - T.x + 10
			I.pixel_y = TD.y - T.y + 12
			I.plane = HUD_PLANE
			I.layer = 2
			I.loc = activator
			holomap_helmets += I

	activator.client.images |= holomap_helmets

/obj/item/clothing/under/deathsquad/ui_action_click()
	togglemap()
