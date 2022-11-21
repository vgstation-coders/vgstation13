#define CRAYON_MAX_LETTERS 10
#define CRAYON_MIN_FONTSIZE 8
#define CRAYON_MAX_FONTSIZE 16

/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	reagent = COLORFUL_REAGENT
	persistence_type = null //todo
	var/mainColour = "#FFFFFF"
	var/shadeColour = "#000000"

/obj/effect/decal/cleanable/crayon/New(loc,age,icon_state,color = "#FFFFFF",dir,pixel_x,pixel_y,shade = "#000000",var/type = "rune")
	..()

	src.mainColour = color
	src.shadeColour = shade
	name = type

	add_hiddenprint(usr)
	update_icon()

	if(isturf(loc))
		var/turf/target = loc
		if(type != "rune" && src.pixel_x != 0 && src.pixel_y != 0 && target.Adjacent(usr))
			var/desired_density = 0
			var/x_offset = 0
			var/y_offset = 0
			if(target.density && (src.loc != get_turf(usr))) //Drawn on a wall (while standing on a floor)
				desired_density = !desired_density
				src.forceMove(get_turf(usr))
				var/angle = dir2angle_t(get_dir(src, target))
				x_offset = WORLD_ICON_SIZE * cos(angle)
				y_offset = WORLD_ICON_SIZE * sin(angle) //Offset the graffiti to make it appear on the wall
				src.on_wall = target

			for(var/direction in alldirs)
				var/turf/current_turf = get_step(target,direction)
				if(current_turf.density != desired_density)
					switch(direction)
						if(WEST)
							src.pixel_x = max(src.pixel_x, 0)
						if(SOUTH, SOUTHEAST, SOUTHWEST)
							src.pixel_y = max(src.pixel_y, 0)
						if(EAST)
							if(istype(src,/obj/effect/decal/cleanable/crayon/text))
								var/obj/effect/decal/cleanable/crayon/text/CT = src
								src.name = copytext(CT.name, 1, (CRAYON_MAX_LETTERS/(CT.fontsize/(CRAYON_MIN_FONTSIZE/2))))
								src.maptext_width = 32
								src.update_icon()
							src.pixel_x = min(src.pixel_x, 0)
						if(NORTH, NORTHEAST, NORTHWEST)
							if(istype(src,/obj/effect/decal/cleanable/crayon/text))
								var/obj/effect/decal/cleanable/crayon/text/CT2 = src
								src.pixel_y = min(src.pixel_y, max(0,src.maptext_height - (CT2.fontsize*1.5)))
							else
								src.pixel_y = min(src.pixel_y, type == 0)
			src.pixel_x += x_offset
			src.pixel_y += y_offset

/obj/effect/decal/cleanable/crayon/update_icon()
	overlays.Cut()

	switch(name) //For generics
		if("rune")
			name = "rune[rand(1,6)]"
		if("graffiti")
			name = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","heart","borgsrogue","shitcurity","catbeast","voxpox","security","hieroglyphs[rand(1,3)]","nanotrasen","lie","syndicate[rand(1,2)]","lambda","50bless","chaos")

	desc = "\A [name] drawn in crayon."

	var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[name]",2.1)
	var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[name]s",2.1)

	mainOverlay.Blend(mainColour,ICON_ADD)
	shadeOverlay.Blend(shadeColour,ICON_ADD)

	overlays += mainOverlay
	overlays += shadeOverlay

//This decal is a big green "fuck you" intended to be hidden behind doors built on walls

/obj/effect/decal/cleanable/crayon/fuckyou
	icon_state = "fuckyou"

/obj/effect/decal/cleanable/crayon/fuckyou/New()
	..(color = "#007F0E", shade = "#02560B", type = "fuckyou")

/obj/effect/decal/cleanable/crayon/text
	name = "written text"
	desc = "Text written in crayon."
	gender = NEUTER
	maptext_height = 32
	maptext_width = 64
	maptext_y = -2
	var/fontsize = 6
	var/font = "Comic Sans MS"

/obj/effect/decal/cleanable/crayon/text/New(loc,age,icon_state,color = "#FFFFFF",dir,pixel_x,pixel_y,shade = "#000000",var/type = "Sample Text",size = 6,fontname = "DK Cool Crayon")
	fontsize = size
	font = fontname
	..()

/obj/effect/decal/cleanable/crayon/text/update_icon()
	desc = "\"[name]\", written in crayon."
	maptext = {"<span style="color:[mainColour];font-size:[fontsize]pt;font-family:'[font]';">[name]</span>"}
