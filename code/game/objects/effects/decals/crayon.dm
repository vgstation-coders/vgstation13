/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	reagent = COLORFUL_REAGENT
	persistence_type = null //todo
	var/mainColour = "#FFFFFF"
	var/shadeColour = "#000000"

/obj/effect/decal/cleanable/crayon/New(loc,age,icon_state,color,dir,pixel_x,pixel_y,main = "#FFFFFF",shade = "#000000",var/type = "rune")
	..()

	src.mainColour = main
	src.shadeColour = shade
	name = type

	add_hiddenprint(usr)
	update_icon()

/obj/effect/decal/cleanable/crayon/update_icon()
	overlays.Cut()
	desc = "A [name] drawn in crayon."

	switch(name) //For generics
		if("rune")
			name = "rune[rand(1,6)]"
		if("graffiti")
			name = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","heart","borgsrogue","shitcurity","catbeast","voxpox","security","hieroglyphs[rand(1,3)]","nanotrasen","lie","syndicate[rand(1,2)]","lambda","50bless","chaos")

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
	..(main = "#007F0E", shade = "#02560B", type = "fuckyou")

/obj/effect/decal/cleanable/crayon/text
	name = "written text"
	desc = "Text written in crayon."
	gender = NEUTER
	maptext_height = 31
	maptext_width = 64
	var/fontsize = 6
	var/font = "Comic Sans MS"

/obj/effect/decal/cleanable/crayon/text/New(loc,age,icon_state,color,dir,pixel_x,pixel_y,main = "#FFFFFF",shade = "#000000",var/type = "Sample Text",size = 6,fontname = "Comic Sans MS")
	fontsize = size
	font = fontname
	..()

/obj/effect/decal/cleanable/crayon/text/update_icon()
	desc = "\"[name]\", written in crayon."
	maptext = {"<span style="color:[mainColour];font-size:[fontsize]pt;font-family:'[font]';">[name]</span>"}
