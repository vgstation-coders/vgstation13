/*
CONTAINS:
RPD
*/

#define PAINT_MODE -2
#define EATING_MODE -1
#define ATMOS_MODE 0
#define DISPOSALS_MODE 1
#define TRANSIT_MODE 2


GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Pipe",				/obj/machinery/atmospherics/pipe/simple),
		new /datum/pipe_info/pipe("Manifold",			/obj/machinery/atmospherics/pipe/manifold),
		new /datum/pipe_info/pipe("Manual Valve",		/obj/machinery/atmospherics/components/binary/valve),
		new /datum/pipe_info/pipe("Digital Valve",		/obj/machinery/atmospherics/components/binary/valve/digital),
		new /datum/pipe_info/pipe("4-Way Manifold",		/obj/machinery/atmospherics/pipe/manifold4w),
		new /datum/pipe_info/pipe("Layer Manifold",		/obj/machinery/atmospherics/pipe/layer_manifold),
	),
	"Devices" = list(
		new /datum/pipe_info/pipe("Connector",			/obj/machinery/atmospherics/components/unary/portables_connector),
		new /datum/pipe_info/pipe("Unary Vent",			/obj/machinery/atmospherics/components/unary/vent_pump),
		new /datum/pipe_info/pipe("Gas Pump",			/obj/machinery/atmospherics/components/binary/pump),
		new /datum/pipe_info/pipe("Passive Gate",		/obj/machinery/atmospherics/components/binary/passive_gate),
		new /datum/pipe_info/pipe("Volume Pump",		/obj/machinery/atmospherics/components/binary/volume_pump),
		new /datum/pipe_info/pipe("Scrubber",			/obj/machinery/atmospherics/components/unary/vent_scrubber),
		new /datum/pipe_info/pipe("Injector",			/obj/machinery/atmospherics/components/unary/outlet_injector),
		new /datum/pipe_info/meter("Meter"),
		new /datum/pipe_info/pipe("Gas Filter",			/obj/machinery/atmospherics/components/trinary/filter),
		new /datum/pipe_info/pipe("Gas Mixer",			/obj/machinery/atmospherics/components/trinary/mixer),
	),
	"Heat Exchange" = list(
		new /datum/pipe_info/pipe("Pipe",				/obj/machinery/atmospherics/pipe/heat_exchanging/simple),
		new /datum/pipe_info/pipe("Manifold",			/obj/machinery/atmospherics/pipe/heat_exchanging/manifold),
		new /datum/pipe_info/pipe("4-Way Manifold",		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w),
		new /datum/pipe_info/pipe("Junction",			/obj/machinery/atmospherics/pipe/heat_exchanging/junction),
		new /datum/pipe_info/pipe("Heat Exchanger",		/obj/machinery/atmospherics/components/unary/heat_exchanger),
	)
))

GLOBAL_LIST_INIT(disposal_pipe_recipes, list(
	"Disposal Pipes" = list(
		new /datum/pipe_info/disposal("Pipe",			/obj/structure/disposalpipe/segment, PIPE_BENDABLE),
		new /datum/pipe_info/disposal("Junction",		/obj/structure/disposalpipe/junction, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Y-Junction",		/obj/structure/disposalpipe/junction/yjunction),
		new /datum/pipe_info/disposal("Sort Junction",	/obj/structure/disposalpipe/sorting/mail, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Trunk",			/obj/structure/disposalpipe/trunk),
		new /datum/pipe_info/disposal("Bin",			/obj/machinery/disposal/bin, PIPE_ONEDIR),
		new /datum/pipe_info/disposal("Outlet",			/obj/structure/disposaloutlet),
		new /datum/pipe_info/disposal("Chute",			/obj/machinery/disposal/deliveryChute),
	)
))

GLOBAL_LIST_INIT(transit_tube_recipes, list(
	"Transit Tubes" = list(
		new /datum/pipe_info/transit("Straight Tube",				/obj/structure/c_transit_tube, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Straight Tube with Crossing",	/obj/structure/c_transit_tube/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Curved Tube",					/obj/structure/c_transit_tube/curved, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Diagonal Tube",				/obj/structure/c_transit_tube/diagonal, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Diagonal Tube with Crossing",	/obj/structure/c_transit_tube/diagonal/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Junction",					/obj/structure/c_transit_tube/junction, PIPE_UNARY_FLIPPABLE),
	),
	"Station Equipment" = list(
		new /datum/pipe_info/transit("Through Tube Station",		/obj/structure/c_transit_tube/station, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Station",		/obj/structure/c_transit_tube/station/reverse, PIPE_UNARY),
		new /datum/pipe_info/transit("Transit Tube Pod",			/obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))


/datum/pipe_info
	var/name
	var/icon_state
	var/id = -1
	var/dirtype = PIPE_BENDABLE

/datum/pipe_info/proc/Render(dispenser)
	var/dat = "<li><a href='?src=[REF(dispenser)]&[Params()]'>[name]</a></li>"

	// Stationary pipe dispensers don't allow you to pre-select pipe directions.
	// This makes it impossble to spawn bent versions of bendable pipes.
	// We add a "Bent" pipe type with a preset diagonal direction to work around it.
	if(istype(dispenser, /obj/machinery/pipedispenser) && (dirtype == PIPE_BENDABLE || dirtype == /obj/item/pipe/binary/bendable))
		dat += "<li><a href='?src=[REF(dispenser)]&[Params()]&dir=[NORTHEAST]'>Bent [name]</a></li>"

	return dat

/datum/pipe_info/proc/Params()
	return ""

/datum/pipe_info/proc/get_preview(selected_dir)
	var/list/dirs
	switch(dirtype)
		if(PIPE_STRAIGHT, PIPE_BENDABLE)
			dirs = list("[NORTH]" = "Vertical", "[EAST]" = "Horizontal")
			if(dirtype == PIPE_BENDABLE)
				dirs += list("[NORTHWEST]" = "West to North", "[NORTHEAST]" = "North to East",
							 "[SOUTHWEST]" = "South to West", "[SOUTHEAST]" = "East to South")
		if(PIPE_TRINARY, PIPE_TRIN_M)
			dirs = list("[NORTH]" = "West South East", "[EAST]" = "North West South",
						"[SOUTH]" = "East North West", "[WEST]" = "South East North")
			if(dirtype == PIPE_TRIN_M)
				dirs += list("[SOUTHEAST]" = "West South East", "[NORTHEAST]" = "North West South",
							 "[NORTHWEST]" = "East North West", "[SOUTHWEST]" = "South East North")
		if(PIPE_UNARY)
			dirs = list("[NORTH]" = "North", "[EAST]" = "East", "[SOUTH]" = "South", "[WEST]" = "West")
		if(PIPE_ONEDIR)
			dirs = list("[SOUTH]" = name)
		if(PIPE_UNARY_FLIPPABLE)
			dirs = list("[NORTH]" = "North", "[NORTHEAST]" = "North Flipped", "[EAST]" = "East", "[SOUTHEAST]" = "East Flipped",
						"[SOUTH]" = "South", "[SOUTHWEST]" = "South Flipped", "[WEST]" = "West", "[NORTHWEST]" = "West Flipped")


	var/list/rows = list()
	var/list/row = list("previews" = list())
	var/i = 0
	for(var/dir in dirs)
		var/numdir = text2num(dir)
		var/flipped = ((dirtype == PIPE_TRIN_M) || (dirtype == PIPE_UNARY_FLIPPABLE)) && (numdir in GLOB.diagonals)
		row["previews"] += list(list("selected" = (numdir == selected_dir), "dir" = dir2text(numdir), "dir_name" = dirs[dir], "icon_state" = icon_state, "flipped" = flipped))
		if(i++ || dirtype == PIPE_ONEDIR)
			rows += list(row)
			row = list("previews" = list())
			i = 0

	return rows

/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path)
	name = label
	id = path
	icon_state = initial(path.pipe_state)
	var/obj/item/pipe/c = initial(path.construction_type)
	dirtype = initial(c.RPD_type)

/datum/pipe_info/pipe/Params()
	return "makepipe=[id]&type=[dirtype]"

/datum/pipe_info/meter
	icon_state = "meterX"
	dirtype = PIPE_ONEDIR

/datum/pipe_info/meter/New(label)
	name = label

/datum/pipe_info/meter/Params()
	return "makemeter=[id]&type=[dirtype]"

/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path

	icon_state = initial(path.icon_state)
	if(ispath(path, /obj/structure/disposalpipe))
		icon_state = "con[icon_state]"

	dirtype = dt

/datum/pipe_info/disposal/Params()
	return "dmake=[id]&type=[dirtype]"

/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	dirtype = dt
	icon_state = initial(path.icon_state)
	if(dt == PIPE_UNARY_FLIPPABLE)
		icon_state = "[icon_state]_preview"

/obj/item/pipe_dispenser
	name = "Rapid Piping Device (RPD)"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=75000, MAT_GLASS=37500)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/working = 0
	var/mode = ATMOS_MODE
	var/p_dir = NORTH
	var/p_flipped = FALSE
	var/paint_color="Grey"
	var/screen = ATMOS_MODE //Starts on the atmos tab.
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/datum/pipe_info/recipe
	var/static/datum/pipe_info/first_atmos
	var/static/datum/pipe_info/first_disposal
	var/static/datum/pipe_info/first_transit

/obj/item/pipe_dispenser/New()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(!first_atmos)
		first_atmos = GLOB.atmos_pipe_recipes[GLOB.atmos_pipe_recipes[1]][1]
	if(!first_disposal)
		first_disposal = GLOB.disposal_pipe_recipes[GLOB.disposal_pipe_recipes[1]][1]
	if(!first_transit)
		first_transit = GLOB.transit_tube_recipes[GLOB.transit_tube_recipes[1]][1]

	recipe = first_atmos

/obj/item/pipe_dispenser/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/pipe_dispenser/attack_self(mob/user)
	ui_interact(user)

/obj/item/pipe_dispenser/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] points the end of the RPD down [user.p_their()] throat and presses a button! It looks like [user.p_theyre()] trying to commit suicide...</span>")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	playsound(get_turf(user), 'sound/items/deconstruct.ogg', 50, 1)
	return(BRUTELOSS)

/obj/item/pipe_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/icon_states/multiple_icons/pipes)
		assets.send(user)

		ui = new(user, src, ui_key, "rpd", name, 300, 550, master_ui, state)
		ui.open()

/obj/item/pipe_dispenser/ui_data(mob/user)
	var/list/data = list(
		"mode" = mode,
		"screen" = screen,
		"piping_layer" = piping_layer,
		"preview_rows" = recipe.get_preview(p_dir),
		"categories" = list(),
		"paint_colors" = list()
	)

	var/list/recipes
	switch(screen)
		if(ATMOS_MODE)
			recipes = GLOB.atmos_pipe_recipes
		if(DISPOSALS_MODE)
			recipes = GLOB.disposal_pipe_recipes
		if(TRANSIT_MODE)
			recipes = GLOB.transit_tube_recipes
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "selected" = (info == recipe)))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))

	data["paint_colors"] = list()
	for(var/c in GLOB.pipe_paint_colors)
		data["paint_colors"] += list(list("color_name" = c, "color_hex" = GLOB.pipe_paint_colors[c], "selected" = (c == paint_color)))

	return data

/obj/item/pipe_dispenser/ui_act(action, params)
	if(..())
		return
	if(!usr.canUseTopic(src))
		return
	var/playeffect = TRUE
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("mode")
			mode = text2num(params["mode"])
		if("screen")
			if(mode == screen)
				mode = text2num(params["screen"])
			screen = text2num(params["screen"])
			switch(screen)
				if(DISPOSALS_MODE)
					recipe = first_disposal
				if(ATMOS_MODE)
					recipe = first_atmos
				if(TRANSIT_MODE)
					recipe = first_transit
			p_dir = NORTH
			playeffect = FALSE
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
			playeffect = FALSE
		if("pipe_type")
			var/static/list/recipes
			if(!recipes)
				recipes = GLOB.disposal_pipe_recipes + GLOB.atmos_pipe_recipes + GLOB.transit_tube_recipes
			recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			p_dir = NORTH
		if("setdir")
			p_dir = text2dir(params["dir"])
			p_flipped = text2num(params["flipped"])
			playeffect = FALSE
	if(playeffect)
		spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)

/obj/item/pipe_dispenser/pre_attack(atom/A, mob/user)
	if(!user.IsAdvancedToolUser() || istype(A, /turf/open/space/transit))
		return ..()

	//So that changing the menu settings doesn't affect the pipes already being built.
	var/temp_piping_layer = piping_layer
	var/queued_p_type = recipe.id
	var/queued_p_dir = p_dir
	var/queued_p_flipped = p_flipped

	// clicking on an existing component puts the new one on the same layer
	if (mode == ATMOS_MODE && istype(A, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/AM = A
		temp_piping_layer = AM.piping_layer
		A = get_turf(user)

	//make sure what we're clicking is valid for the current mode
	var/static/list/make_pipe_whitelist
	if(!make_pipe_whitelist)
		make_pipe_whitelist = typecacheof(list(/obj/structure/lattice, /obj/structure/girder, /obj/item/pipe))
	var/can_make_pipe = (isturf(A) || is_type_in_typecache(A, make_pipe_whitelist))

	. = FALSE
	switch(mode) //if we've gotten this var, the target is valid
		if(PAINT_MODE) //Paint pipes
			if(!istype(A, /obj/machinery/atmospherics/pipe))
				return ..()
			var/obj/machinery/atmospherics/pipe/P = A
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			P.paint(GLOB.pipe_paint_colors[paint_color])
			user.visible_message("<span class='notice'>[user] paints \the [P] [paint_color].</span>","<span class='notice'>You paint \the [P] [paint_color].</span>")
			return

		if(EATING_MODE) //Eating pipes
			if(!(istype(A, /obj/item/pipe) || istype(A, /obj/item/pipe_meter) || istype(A, /obj/structure/disposalconstruct) || istype(A, /obj/structure/c_transit_tube) || istype(A, /obj/structure/c_transit_tube_pod)))
				return ..()
			to_chat(user, "<span class='notice'>You start destroying a pipe...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 2, target = A))
				activate()
				qdel(A)

		if(ATMOS_MODE) //Making pipes
			if(!can_make_pipe)
				return ..()
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if (recipe.type == /datum/pipe_info/meter)
				to_chat(user, "<span class='notice'>You start building a meter...</span>")
				if(do_after(user, 2, target = A))
					activate()
					var/obj/item/pipe_meter/PM = new /obj/item/pipe_meter(get_turf(A))
					PM.setAttachLayer(temp_piping_layer)
			else
				to_chat(user, "<span class='notice'>You start building a pipe...</span>")
				if(do_after(user, 2, target = A))
					activate()
					var/obj/machinery/atmospherics/path = queued_p_type
					var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
					var/obj/item/pipe/P = new pipe_item_type(get_turf(A), queued_p_type, queued_p_dir)

					if(queued_p_flipped && istype(P, /obj/item/pipe/trinary/flippable))
						var/obj/item/pipe/trinary/flippable/F = P
						F.flipped = queued_p_flipped

					P.update()
					P.add_fingerprint(usr)
					P.setPipingLayer(temp_piping_layer)
					P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
			
		if(DISPOSALS_MODE) //Making disposals pipes
			if(!can_make_pipe)
				return ..()
			A = get_turf(A)
			if(isclosedturf(A))
				to_chat(user, "<span class='warning'>[src]'s error light flickers; there's something in the way!</span>")
				return
			to_chat(user, "<span class='notice'>You start building a disposals pipe...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 4, target = A))
				var/obj/structure/disposalconstruct/C = new (A, queued_p_type, queued_p_dir, queued_p_flipped)

				if(!C.can_place())
					to_chat(user, "<span class='warning'>There's not enough room to build that here!</span>")
					qdel(C)
					return

				activate()

				C.add_fingerprint(usr)
				C.update_icon()
				return

		if(TRANSIT_MODE) //Making transit tubes
			if(!can_make_pipe)
				return ..()
			A = get_turf(A)
			if(isclosedturf(A))
				to_chat(user, "<span class='warning'>[src]'s error light flickers; there's something in the way!</span>")
				return
			to_chat(user, "<span class='notice'>You start building a transit tube...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 4, target = A))
				activate()
				if(queued_p_type == /obj/structure/c_transit_tube_pod)
					var/obj/structure/c_transit_tube_pod/pod = new /obj/structure/c_transit_tube_pod(A)
					pod.add_fingerprint(usr)
				else
					var/obj/structure/c_transit_tube/tube = new queued_p_type(A)
					tube.dir = queued_p_dir

					if(queued_p_flipped)
						tube.dir = turn(queued_p_dir, 45)
						tube.simple_rotate_flip()

					tube.add_fingerprint(usr)
				return

		else
			return ..()


/obj/item/pipe_dispenser/proc/activate()
	playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)

#undef PAINT_MODE
#undef EATING_MODE
#undef ATMOS_MODE
#undef DISPOSALS_MODE
