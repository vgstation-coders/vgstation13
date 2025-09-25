/obj/item/scrap
	name = "metal scraps"
	desc = "Leftover metal in small quantities, not enough to make a full sheet out of."
	icon = 'icon/obj/stacks_sheets.dmi'
	icon_state = "scrap"
	var/material_name = "metal"
	var/sheet_material = MAT_IRON
	var/min_required_for_sheet = CC_PER_SHEET_METAL

/obj/item/scrap/New()
	starting_materials = list(sheet_material = min_required_for_sheet)
	. = ..()
	var/datum/material/mat = materials.getMaterial(sheet_material)
	sheet_type = mat.sheettype
	material_name = lowertext(mat.name)
	name = "[material_name] scraps"
	desc = "Leftover [material_name] in small quantities, not enough to make a full sheet out of."

/obj/item/scrap/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(materials.getValueByMaterial(sheet_material) >= min_required_for_sheet && iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(1,user))
			user.create_in_hands(src, sheet_type, WT, 1, "<span class='notice'>You weld \the [src] into a sheet of [material_name]</span>")

/obj/item/scrap/glass
	name = "glass scraps"
	desc = "Leftover glass in small quantities, not enough to make a full sheet out of."
	sheet_material = MAT_GLASS
	min_required_for_sheet = CC_PER_SHEET_GLASS
