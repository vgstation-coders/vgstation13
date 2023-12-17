/obj/item/weapon/storage/toolbox
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
		"/obj/item/tool/weldingtool/hugetank",
		"/obj/item/device/rcd/matter/engineering",
		"/obj/item/device/rcd/rpd",
		"/obj/item/device/rcd/tile_painter",
		"/obj/item/blueprints",
		"/obj/item/device/lightreplacer",
		"/obj/item/weapon/rcl",
		"/obj/item/weapon/cell",
		"/obj/item/stack/rods",
		"/obj/item/stack/tile",
		"/obj/item/stack/sheet/metal",
		"/obj/item/stack/sheet/glass",
		"/obj/item/stack/sheet/mineral",
		"/obj/item/stack/sheet/wood"
		)*/


//see /obj/item/weapon/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/metal/T, mob/user as mob) override in floorbot.dm

/obj/item/weapon/storage/toolbox/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is [pick("staving","robusting")] \his head in with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/storage/toolbox/arcane_act(mob/user)
	..()
	force = 0
	throwforce = 0
	return "R'B'STO!"

/obj/item/weapon/storage/toolbox/bless()
	..()
	force = initial(force)
	throwforce = initial(throwforce)

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "toolbox_red"
	item_state = "toolbox_red"
	items_to_spawn = list(
		/obj/item/tool/crowbar/red,
		/obj/item/weapon/extinguisher/mini,
	)

/obj/item/weapon/storage/toolbox/emergency/New()
	..()
	var/lighting = pick( //emergency lighting yay
		20;/obj/item/device/flashlight,
		30;/obj/item/weapon/storage/fancy/flares,
		50;/obj/item/device/flashlight/flare)
	new lighting(src)
	new /obj/item/device/radio(src)
	if(prob(5))
		new /obj/item/airbag(src)
	if(prob(15))
		new /obj/item/clothing/accessory/rad_patch(src)

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "toolbox_blue"
	item_state = "toolbox_blue"
	items_to_spawn = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/device/analyzer,
		/obj/item/tool/wirecutters,
	)

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "toolbox_yellow"
	item_state = "toolbox_yellow"
	items_to_spawn = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/device/t_scanner,
		/obj/item/tool/crowbar,
	)

/obj/item/weapon/storage/toolbox/electrical/New()
	..()
	var/color = pick("#FF0000","#FFED00","#0B8400","#005C84","#CA00B6","#CA6900","#00B5CA","#D0D0D0")
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/stack/cable_coil(src,30,color)
	if(prob(5))
		new /obj/item/clothing/gloves/yellow(src)
	else
		new /obj/item/stack/cable_coil(src,30,color)

/obj/item/weapon/storage/toolbox/electrical/arcane_act(mob/user)
	for(var/atom/A in contents)
		qdel(A)
		new /obj/item/clothing/gloves/fyellow(src)
	return ..()

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "toolbox_syndi"
	item_state = "toolbox_syndi"
	origin_tech = Tc_COMBAT + "=1;" + Tc_SYNDICATE + "=1"
	force = 20
	items_to_spawn = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/device/multitool,
	)

/obj/item/weapon/storage/toolbox/syndicate/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/stack/cable_coil(src,30,color)

/obj/item/weapon/storage/toolbox/robotics
	name = "robotics toolbox"
	items_to_spawn = list(
		/obj/item/device/robotanalyzer,
		/obj/item/tool/crowbar,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
	)

/obj/item/weapon/storage/toolbox/robotics/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/stack/cable_coil(src,30,color)

/obj/item/weapon/storage/toolbox/paint
	name = "painter's toolbox"
	desc = "Contains an assortment of paints for the artistic spacefarer."
	icon_state = "toolbox_paint"
	item_state = "toolbox_paint"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')
	attack_verb = list("daubs", "decorates", "slathers")
	max_combined_w_class = 42
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/red,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/vermilion,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/orange,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/amber,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/yellow,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/chartreuse,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/green,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/turquoise,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/blue,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/indigo,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/violet,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/magenta,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/black,
		/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/white,
	)
