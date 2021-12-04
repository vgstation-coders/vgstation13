
////////////////////////////////////////////////////////////////////
//																  //
//					   SOULBLADE (BLOOD GAUGE)					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/soulblade
	uniqueID = "Soulblade"
	x = "LEFT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/blood_gauge,
		/obj/abstract/mind_ui_element/blood_count,
		)

/datum/mind_ui/soulblade/Valid()
	var/mob/M = mind.current
	if (isshade(M) && istype(M.loc, /obj/item/weapon/melee/soulblade))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blood_gauge
	name = "Blood"
	icon = 'icons/ui/soulblade/21x246.dmi'
	icon_state = "blood_gauge_background"
	layer = MIND_UI_BACK
	offset_y = -119

/obj/abstract/mind_ui_element/blood_gauge/UpdateIcon()
	var/mob/living/simple_animal/shade/M = GetUser()
	if(!istype(M) || !istype(M.loc, /obj/item/weapon/melee/soulblade))
		return
	var/obj/item/weapon/melee/soulblade/SB = M.loc
	overlays.len = 0

	var/image/gauge = image('icons/ui/soulblade/18x200.dmi', src, "blood")
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,SB.blood/SB.maxblood)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	gauge.pixel_y = round(-77 + 100 * (SB.blood/SB.maxblood))
	overlays += gauge

	var/image/cover = image(icon, src, "blood_gauge_cover")
	cover.layer = MIND_UI_FRONT
	overlays += cover

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blood_count
	icon = 'icons/ui/soulblade/21x246.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	mouse_opacity = 0

/obj/abstract/mind_ui_element/blood_count/UpdateIcon()
	var/mob/living/simple_animal/shade/M = GetUser()
	if(!istype(M) || !istype(M.loc, /obj/item/weapon/melee/soulblade))
		return
	var/obj/item/weapon/melee/soulblade/SB = M.loc
	overlays.len = 0
	overlays += String2Image("[SB.blood]")
	if(SB.blood >= 100)
		offset_x = 0
	else if(SB.blood >= 10)
		offset_x = 3
	else
		offset_x = 6
	UpdateUIScreenLoc()

//------------------------------------------------------------
