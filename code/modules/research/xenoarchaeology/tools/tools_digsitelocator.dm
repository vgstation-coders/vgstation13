/obj/item/device/xenoarch_scanner
	name = "xenoarchaeological digsite locator"
	desc = "A scanner that scans the surrounding area for potential xenoarch digsites, highlighting them temporarily in a colour associated with their responsive reagent. Requires mesons for optimal use."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "digsitelocator"
	item_state  = "analyzer"
	w_class = W_CLASS_SMALL
	flags = 0
	slot_flags = SLOT_BELT
	origin_tech = Tc_ANOMALY+"=1"
	var/cooldown = 0
	var/adv = FALSE
	toolsounds = list('sound/items/detscan.ogg')

/obj/item/device/xenoarch_scanner/adv
	name = "advanced xenoarchaeological digsite locator"
	icon_state = "digsitelocator_adv"
	desc = "A scanner that scans the surrounding area for potential xenoarch digsites, highlighting them temporarily in a colour associated with their responsive reagent, along with a flashing red circle mark for larger artifacts. Requires mesons for optimal use."
	adv = TRUE

/obj/item/device/xenoarch_scanner/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>It has a list of colour codes:</span>")
	for(var/i in color_from_find_reagent)
		to_chat(user, "[i] = <span style = 'color:[color_from_find_reagent[i]];'>this colour</span>")

/obj/item/device/xenoarch_scanner/attack_self(mob/user)
	if(world.time > cooldown + 4 SECONDS)
		var/client/C = user.client
		if(!C)
			return
		cooldown = world.time
		playtoolsound(src, 50)
		for(var/turf/unsimulated/mineral/M in range(7, user))
			if(M.finds.len)
				var/n = 0
				var/list/image/IS = list()
				var/totalfinds = M.finds.len
				for(var/datum/find/F in M.finds)
					n++
					var/image/I = image('icons/turf/mine_overlays.dmi', loc = M, icon_state = "find_overlay[rand(1,3)]", layer = UNDER_HUD_LAYER)
					IS.Add(I)
					I.color = color_from_find_reagent[F.responsive_reagent]
					I.plane = HUD_PLANE
					if(n > 1)
						var/matrix/TR = matrix()
						TR.Scale(((totalfinds + 1) - n) / totalfinds, ((totalfinds + 1) - n) / totalfinds)
						I.transform = TR
						var/list/col = rgb2num(I.color)
						I.filters = filter(type="outline",color=rgb(255-col[1],255-col[2],255-col[3]))
					C.images += I
				spawn(1 SECONDS)
					for(var/image/I in IS)
						animate(I, alpha = 0, time = 4 SECONDS)
				spawn(5 SECONDS)
					for(var/image/I in IS)
						if(C)
							C.images -= I
			if (adv && M.artifact_find)
				var/image/I = image('icons/turf/mine_overlays.dmi', loc = M, icon_state = "artifact_overlay", layer = UNDER_HUD_LAYER)
				I.plane = HUD_PLANE
				C.images += I
				spawn(1 SECONDS)
					animate(I, alpha = 0, time = 4 SECONDS)
				spawn(5 SECONDS)
					if(C)
						C.images -= I
