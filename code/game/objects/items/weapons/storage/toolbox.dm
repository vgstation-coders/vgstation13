/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "toolbox_grey"
	item_state = "toolbox_grey"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toolbox_ihl.dmi', "right_hand" = 'icons/mob/in-hand/right/toolbox_ihr.dmi')
	flags = FPRINT
	siemens_coefficient = 1
	force = 15
	hitsound = 'sound/weapons/toolbox.ogg'
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	starting_materials = list(MAT_IRON = 5000)
	w_type = RECYK_METAL
	w_class = W_CLASS_LARGE
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_COMBAT + "=1"
	attack_verb = list("robusts", "batters", "staves in")
	fits_max_w_class = W_CLASS_MEDIUM
	storage_slots = 14
	max_combined_w_class = 28
	/*fits_ignoring_w_class = list(
		"/obj/item/weldingtool/hugetank",
		"/obj/item/device/rcd/matter/engineering",
		"/obj/item/device/rcd/rpd",
		"/obj/item/device/rcd/tile_painter",
		"/obj/item/blueprints",
		"/obj/item/device/lightreplacer",
		"/obj/item/rcl",
		"/obj/item/cell",
		"/obj/item/stack/rods",
		"/obj/item/stack/tile",
		"/obj/item/stack/sheet/metal",
		"/obj/item/stack/sheet/glass",
		"/obj/item/stack/sheet/mineral",
		"/obj/item/stack/sheet/wood"
		)*/


//see /obj/item/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob) override in floorbot.dm

/obj/item/storage/toolbox/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is [pick("staving","robusting")] \his head in with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)


/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "toolbox_red"
	item_state = "toolbox_red"

/obj/item/storage/toolbox/emergency/New()
	..()
	new /obj/item/crowbar/red(src)
	new /obj/item/extinguisher/mini(src)
	var/lighting = pick( //emergency lighting yay
		20;/obj/item/device/flashlight,
		30;/obj/item/storage/fancy/flares,
		50;/obj/item/device/flashlight/flare)
	new lighting(src)
	new /obj/item/device/radio(src)
	if(prob(5))
		new /obj/item/airbag(src)
	if(prob(15))
		new /obj/item/clothing/accessory/rad_patch(src)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "toolbox_blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/New()
	..()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "toolbox_yellow"
	item_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/stack/cable_coil(src,30,color)
	if(prob(5))
		new /obj/item/clothing/gloves/yellow(src)
	else
		new /obj/item/stack/cable_coil(src,30,color)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "toolbox_syndi"
	item_state = "toolbox_syndi"
	origin_tech = Tc_COMBAT + "=1;" + Tc_SYNDICATE + "=1"
	force = 20

/obj/item/storage/toolbox/syndicate/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/wirecutters(src)
	new /obj/item/device/multitool(src)

/obj/item/storage/toolbox/robotics
	name = "robotics toolbox"

/obj/item/storage/toolbox/robotics/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/device/robotanalyzer(src)
	new /obj/item/crowbar(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,color)
