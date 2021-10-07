

/obj/item/stack/sheet
	name = "sheet"
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	force = 5
	throwforce = 5
	max_amount = MAX_SHEET_STACK_AMOUNT
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "smashes")
	perunit=3750
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/sheets_n_ores.dmi', "right_hand" = 'icons/mob/in-hand/right/sheets_n_ores.dmi')
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/mat_type //What material this is. e.g. MAT_GLASS, MAT_DIAMOND, etc.
	mech_flags = MECH_SCAN_FAIL

/obj/item/stack/sheet/New(var/newloc, var/amount = null)
	pixel_x = (rand(0,4)-4) * PIXEL_MULTIPLIER
	pixel_y = (rand(0,4)-4) * PIXEL_MULTIPLIER
	..()


// Since the sheetsnatcher was consolidated into weapon/storage/bag we now use
// item/attackby() properly, making this unnecessary

/*/obj/item/stack/sheet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/storage/bag/sheetsnatcher))
		var/obj/item/weapon/storage/bag/sheetsnatcher/S = W
		if(!S.mode)
			S.add(src,user)
		else
			for (var/obj/item/stack/sheet/stack in locate(src.x,src.y,src.z))
				S.add(stack,user)
	..()*/
