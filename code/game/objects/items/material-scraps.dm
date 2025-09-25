/obj/item/scrap
	name = "metal scraps"
	desc = "Leftover metal in small quantities, not enough to make a full sheet out of."
	icon = 'icon/obj/stacks_sheets.dmi'
	icon_state = "scrap"
	var/sheet_material = MAT_IRON

/obj/item/scrap/New(location,material_amount = 0,material_type)
	if(material_type)
		sheet_material = material_type
	if(material_amount > 0)
		min_required_for_sheet = material_amount
	starting_materials = list(sheet_material = min_required_for_sheet)
	. = ..()
	var/datum/material/mat = materials.getMaterial(sheet_material)
	sheet_type = mat.sheettype
	var/material_name = lowertext(mat.name)
	name = "[material_name] scraps"
	desc = "Leftover [material_name] in small quantities, not enough to make a full sheet out of."

/obj/item/scrap/examine(mob/user, size, show_name)
	. = ..()
	var/datum/material/mat = materials.getMaterial(sheet_material)
	to_chat(user,"<span class='notice'>It holds [materials.getAmount(sheet_material)] units of [lowertext(mat.name)].\
	[materials.getValueByMaterial(sheet_material) >= min_required_for_sheet ? "It can make [materials.getAmount(sheet_material)/mat.cc_per_sheet] sheets." : ""]</span>")

/obj/item/scrap/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		var/datum/material/mat = materials.getMaterial(sheet_material)
		if(materials.getValueByMaterial(sheet_material) >= mat.cc_per_sheet && WT.remove_fuel(1,user))
			user.create_in_hands(src, sheet_type, WT, 1, "<span class='notice'>You weld \the [src] into a sheet of [lowertext(mat.name)]</span>")
	if(istype(W, src.type))
		merge(W)

/obj/item/scrap/Crossed(obj/o)
	if(src != o && istype(o, src.type) && !o.throwing)
		merge(o)
	return ..()

/obj/item/scrap/proc/merge(obj/item/scrap/S) //Merge src into S, as much as possible
	if(src == S) //We need to check this because items can cross themselves for some fucked up reason
		return
	//TODO: code here
