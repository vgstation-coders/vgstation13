/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	reagent = COLORFUL_REAGENT
	persistence_type = null //todo

/obj/effect/decal/cleanable/crayon/New(loc,age,icon_state,color,dir,pixel_x,pixel_y,main = "#FFFFFF",shade = "#000000",var/type = "rune")
	..()

	name = type
	desc = "A [type] drawn in crayon."

	switch(type) //For generics
		if("rune")
			type = "rune[rand(1,6)]"
		if("graffiti")
			type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","heart","borgsrogue","shitcurity","catbeast","voxpox","security","hieroglyphs[rand(1,3)]","nanotrasen","lie","syndicate[rand(1,2)]","lambda","50bless","chaos")

	var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]",2.1)
	var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]s",2.1)

	mainOverlay.Blend(main,ICON_ADD)
	shadeOverlay.Blend(shade,ICON_ADD)

	overlays += mainOverlay
	overlays += shadeOverlay

	add_hiddenprint(usr)

//This decal is a big green "fuck you" intended to be hidden behind doors built on walls

/obj/effect/decal/cleanable/crayon/fuckyou
	icon_state = "fuckyou"

/obj/effect/decal/cleanable/crayon/fuckyou/New()
	..(main = "#007F0E", shade = "#02560B", type = "fuckyou")
