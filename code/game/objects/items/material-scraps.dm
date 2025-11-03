/obj/item/trash/scrap
	name = "metal scraps"
	desc = "Leftover metal in small quantities."
	icon = 'icons/obj/stacks_sheets.dmi'
	icon_state = "scrap"
	w_type = RECYK_METAL
	flammable = FALSE
	var/sheet_material = MAT_IRON

/obj/item/trash/scrap/New(loc, age, icon_state, color, dir, pixel_x, pixel_y, obj/item/source, material_amount = CC_PER_SHEET_DEFAULT, material_type)
	if(material_type)
		sheet_material = material_type
	starting_materials = list("[sheet_material]" = material_amount)
	. = ..()
	var/datum/material/mat = materials.getMaterial(sheet_material)
	sheet_type = mat.sheettype
	var/material_name = lowertext(mat.name)
	name = "[material_name] scraps"
	desc = "Leftover [material_name] in small quantities."

/obj/item/trash/scrap/examine(mob/user, size, show_name)
	. = ..()
	var/datum/material/mat = materials.getMaterial(sheet_material)
	var/sheet_number = floor(materials.getAmount(sheet_material)/mat.cc_per_sheet)
	to_chat(user,"<span class='notice'>It holds [materials.getAmount(sheet_material)] cm<sup>3</sup> of [lowertext(mat.name)]\
	[sheet_number > 0 ? ", enough for [sheet_number] sheet[sheet_number > 1 ? "s" : ""]" : ""].</span>")

/obj/item/trash/scrap/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		var/datum/material/mat = materials.getMaterial(sheet_material)
		if(materials.getAmount(sheet_material) >= mat.cc_per_sheet && WT.remove_fuel(1,user))
			to_chat(user, "<span class='notice'>You weld \the [src] into sheets of [lowertext(mat.name)]</span>")
			materials.makeSheets(get_turf(src),TRUE)
			if(materials.getAmount(sheet_material) <= 0)
				qdel(src)
				return
	if(istype(W, src.type))
		merge(W)

/obj/item/trash/scrap/Crossed(obj/o)
	if(src != o && istype(o, src.type) && !o.throwing)
		merge(o)
	return ..()

/obj/item/trash/scrap/proc/merge(obj/item/trash/scrap/S) //Merge src into S, as much as possible
	if(src == S || sheet_material != S.sheet_material)
		return
	S.materials.addAmount(S.sheet_material,materials.getAmount(sheet_material))
	if(pulledby)
		pulledby.start_pulling(S)
	src.blood_DNA = S.blood_DNA
	src.fingerprints  = S.fingerprints
	src.fingerprintshidden  = S.fingerprintshidden
	src.fingerprintslast  = S.fingerprintslast
	qdel(src)
