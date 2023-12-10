/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	plane = ABOVE_OBJ_PLANE
	layer = BLANKIES_LAYER
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheetwhite"
	item_state = "bedsheet"
	slot_flags = SLOT_BACK
	clothing_flags = COLORS_OVERLAY
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = W_CLASS_TINY
	_color = "white"
	restraint_resist_time = 20 SECONDS
	toolsounds = list("rustle")
	species_fit = list(VOX_SHAPED)
	autoignition_temperature = AUTOIGNITION_FABRIC
	w_type = RECYK_FABRIC
	starting_materials = list(MAT_FABRIC = 1250)

//cutting the bedsheet into rags and other things
/obj/item/weapon/bedsheet/attackby(var/obj/item/I, var/mob/user)
	if (istype(I, /obj/item/knitting_needles))
		playsound(get_turf(src), 'sound/machines/dial_reset.ogg', 50, 1)
		to_chat(user, "You begin altering the patterns of the bedsheet.")
		if (do_after(user, get_turf(src), 3 SECONDS) && loc)
			var/result = plaid_convert()
			switch (result)
				if (PLAIDPATTERN_INCOMPATIBLE)
					to_chat(user, "<span class='warning'>Try as you might, this bedsheet cannot be altered into having a plaid pattern.</span>")
				if (PLAIDPATTERN_TO_PLAID)
					to_chat(user, "<span class='notice'>You add a plaid pattern to the bedsheet.</span>")
				if (PLAIDPATTERN_TO_NOT_PLAID)
					to_chat(user, "<span class='notice'>You remove the bedsheet's plaid pattern.</span>")
		return
	var/cut_time=0
	if(I.is_sharp())
		cut_time = 60 / I.sharpness
	if(cut_time)
		to_chat(user, "<span  class='notice'>You begin cutting up \the [src].</span>")
		if(do_after(user, src, cut_time))
			if(!src)
				return

			if(user.zone_sel.selecting == TARGET_EYES)
				to_chat(user, "<span  class='notice'>You finish cutting eye holes into \the [src].</span>")
				user.put_in_hands(new /obj/item/clothing/suit/bedsheet_ghost())

			else
				to_chat(user, "<span  class='notice'>You finish cutting \the [src] into rags.</span>")
				var/turf/location = get_turf(src)
				for(var/x=0; x<=8; x++)
					var/obj/item/weapon/reagent_containers/glass/rag/S = new/obj/item/weapon/reagent_containers/glass/rag/(location)
					S.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
					S.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

			qdel(src)

//todo: hold one if possible?
//todo: coloring and molotov coloring?
//todo: finger prints?
//todo: more cutting tools?
//todo: sharp thing code/game/objects/objs.dm

/obj/item/weapon/bedsheet/linen
	//crafted from cloth.
	icon_state = "sheetdyeable"
	color = COLOR_LINEN
	_color = "linen"

/obj/item/weapon/bedsheet/linen/New()
	..()
	var/image/I = image(icon, src, "sheetdyeable-overlay")
	I.appearance_flags = RESET_COLOR
	overlays += I

/obj/item/weapon/bedsheet/plaid
	icon_state = "plaidsheetwhite"
	_color = "plaidwhite"

/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"
	_color = "blue"

/obj/item/weapon/bedsheet/blue/plaid
	icon_state = "plaidsheetblue"
	_color = "plaidblue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"
	_color = "green"

/obj/item/weapon/bedsheet/green/plaid
	icon_state = "plaidsheetgreen"
	_color = "plaidgreen"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"
	_color = "orange"

/obj/item/weapon/bedsheet/orange/plaid
	icon_state = "plaidsheetorange"
	_color = "plaidorange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"
	_color = "purple"

/obj/item/weapon/bedsheet/purple/plaid
	icon_state = "plaidsheetpurple"
	_color = "plaidpurple"

/obj/item/weapon/bedsheet/rainbow
	icon_state = "sheetrainbow"
	_color = "rainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"
	_color = "red"

/obj/item/weapon/bedsheet/red/plaid
	icon_state = "plaidsheetred"
	_color = "plaidred"

/obj/item/weapon/bedsheet/red/redcoat
	_color = "redcoat" //for denied stamp

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"
	_color = "yellow"

/obj/item/weapon/bedsheet/yellow/plaid
	icon_state = "plaidsheetyellow"
	_color = "plaidyellow"

/obj/item/weapon/bedsheet/mime
	icon_state = "sheetmime"
	_color = "mime"

/obj/item/weapon/bedsheet/clown
	icon_state = "sheetclown"
	_color = "clown"

/obj/item/weapon/bedsheet/black
	icon_state = "sheetblack"
	_color = "black"

/obj/item/weapon/bedsheet/captain
	icon_state = "sheetcaptain"
	_color = "captain"

/obj/item/weapon/bedsheet/rd
	icon_state = "sheetrd"
	_color = "director"

/obj/item/weapon/bedsheet/medical
	icon_state = "sheetmedical"
	_color = "medical"

/obj/item/weapon/bedsheet/hos
	icon_state = "sheethos"
	_color = "hosred"

/obj/item/weapon/bedsheet/hop
	icon_state = "sheethop"
	_color = "hop"

/obj/item/weapon/bedsheet/ce
	icon_state = "sheetce"
	_color = "chief"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"
	_color = "brown"

/obj/item/weapon/bedsheet/brown/cargo
	_color = "cargo"		//exists for washing machines, is not different from brown bedsheet in any way

/obj/item/weapon/bedsheet/dye_act(var/obj/structure/reagent_dispensers/cauldron/cauldron, var/mob/user)
	to_chat(user, "<span class='notice'>You begin dyeing \the [src].</span>")
	playsound(cauldron.loc, 'sound/effects/slosh.ogg', 25, 1)
	if (do_after(user, cauldron, 30))
		var/mixed_color = mix_color_from_reagents(cauldron.reagents.reagent_list, TRUE)
		var/mixed_alpha = mix_alpha_from_reagents(cauldron.reagents.reagent_list)
		if (copytext(icon_state, 1, 6) == "plaid")
			icon_state = "plaidsheetdyeable"
			color = BlendRGB(color, mixed_color, mixed_alpha/255)
		else
			overlays.len = 0
			icon_state = "sheetdyeable"
			color = BlendRGB(color, mixed_color, mixed_alpha/255)
			var/image/I = image(icon, src, "sheet-overlay")
			I.appearance_flags = RESET_COLOR
			overlays += I
			update_blood_overlay()
		user.update_inv_hands()
	return TRUE

/obj/item/weapon/bedsheet/proc/plaid_convert()
	var/list/plaid_sheet_colors = list(
		"sheetwhite",
		"sheetblue",
		"sheetorange",
		"sheetred",
		"sheetpurple",
		"sheetgreen",
		"sheetyellow",
		"sheetdyeable",
		)

	if (icon_state in plaid_sheet_colors)
		icon_state = "plaid[icon_state]"
		overlays.len = 0
		update_blood_overlay()
		return PLAIDPATTERN_TO_PLAID
	else if  (copytext(icon_state, 1, 6) == "plaid")
		icon_state = copytext(icon_state, 6)
		var/image/I = image(icon, src, "sheet-overlay")
		I.appearance_flags = RESET_COLOR
		overlays += I
		return PLAIDPATTERN_TO_NOT_PLAID
	return PLAIDPATTERN_INCOMPATIBLE

/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = 1
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden = null

/obj/structure/bedsheetbin/Destroy()
	for(var/sheet in sheets)
		qdel(sheet)
	sheets.Cut()
	if(hidden)
		QDEL_NULL(hidden)
	..()


/obj/structure/bedsheetbin/examine(mob/user)
	..()
	if(amount == 0)
		to_chat(user, "<span class='info'>There are no bed sheets in \the [src].</span>")
	else if(amount == 1)
		to_chat(user, "<span class='info'>There is one bed sheet in \the [src].</span>")
	else
		to_chat(user, "<span class='info'>There are [amount] bed sheets in \the [src].</span>")


/obj/structure/bedsheetbin/update_icon()
	if(amount == 0)
		icon_state = "linenbin-empty"
	else if(amount <= initial(amount) / 2)
		icon_state = "linenbin-half"
	else
		icon_state = "linenbin-full"


/obj/structure/bedsheetbin/attackby(obj/item/I as obj, mob/user as mob)
	if(I.is_wrench(user))
		wrenchAnchor(user, I, time_to_wrench = 2 SECONDS)
		return
	if(iswelder(I))
		if(anchored)
			to_chat(user, "<span class='warning'>\The [src] is still secured to whatever surface it is on. Unsecure it first!</span>")
			return
		var/obj/item/tool/weldingtool/W = I
		if(W.remove_fuel(2,user))
			to_chat(user, "<span class='notice'>You break \the [src] down into a pile of rods.</span>")
			new /obj/item/stack/rods(get_turf(src),rand(3,5))
			for(var/obj/sheet in sheets)
				sheet.forceMove(loc)
				amount--
			sheets.Cut()
			while(amount > 0)
				new /obj/item/weapon/bedsheet(loc)
				amount--
			if(hidden)
				to_chat(user, "<span class='notice'>\The [hidden] falls out of \the [src]!</span>")
				hidden.forceMove(loc)
				hidden = null
			qdel(src)
			return
	if(istype(I, /obj/item/weapon/bedsheet))
		if(user.drop_item(I, src))
			sheets.Add(I)
			amount++
			to_chat(user, "<span class='notice'>You put \the [I] in \the [src].</span>")
	else if(amount && !hidden && I.w_class < W_CLASS_LARGE)	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		if(user.drop_item(I, src))
			hidden = I
			to_chat(user, "<span class='notice'>You hide [I] among the sheets.</span>")


/obj/structure/bedsheetbin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.forceMove(user.loc)
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You take [B] out of [src].</span>")

		if(hidden)
			hidden.forceMove(user.loc)
			to_chat(user, "<span class='notice'>[hidden] falls out of [B]!</span>")
			hidden = null


	add_fingerprint(user)

/obj/structure/bedsheetbin/attack_tk(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove [B] from [src].</span>")
		update_icon()

		if(hidden)
			hidden.forceMove(loc)
			hidden = null


	add_fingerprint(user)
