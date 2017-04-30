/*CONTENTS
Buildable pipes
Buildable meters
*/

//Gas piping numbers - do NOT hardcode these, use the defines
#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_HE_STRAIGHT		2
#define PIPE_HE_BENT			3
#define PIPE_CONNECTOR			4
#define PIPE_MANIFOLD			5
#define PIPE_JUNCTION			6
#define PIPE_UVENT				7
#define PIPE_MVALVE				8
#define PIPE_PUMP				9
#define PIPE_SCRUBBER			10
#define PIPE_INSULATED_STRAIGHT	11
#define PIPE_INSULATED_BENT		12
#define PIPE_GAS_FILTER			13
#define PIPE_GAS_MIXER			14
#define PIPE_PASSIVE_GATE       15
#define PIPE_VOLUME_PUMP        16
#define PIPE_HEAT_EXCHANGE      17
#define PIPE_DVALVE             18
#define PIPE_MTVALVE			19
#define PIPE_MANIFOLD4W			20
#define PIPE_CAP				21
#define PIPE_THERMAL_PLATE		22
#define PIPE_INJECTOR    		23
#define PIPE_DP_VENT    		24
#define PIPE_PASV_VENT    		25
#define PIPE_DTVALVE			26
#define PIPE_INSUL_MANIFOLD		27
#define PIPE_INSUL_MANIFOLD4W	28
#define PIPE_LAYER_MANIFOLD		29
#define PIPE_LAYER_ADAPTER      30

//Disposal piping numbers - do NOT hardcode these, use the defines
#define DISP_PIPE_STRAIGHT		0
#define DISP_PIPE_BENT			1
#define DISP_JUNCTION			2
#define DISP_YJUNCTION			3
#define DISP_END_TRUNK			4
#define DISP_END_BIN			5
#define DISP_END_OUTLET			6
#define DISP_END_CHUTE			7
#define DISP_SORT_JUNCTION		8
#define DISP_SORT_WRAP_JUNCTION	9

var/global/list/unstackable_pipes = list(
	PIPE_LAYER_MANIFOLD,
	PIPE_UVENT,
	PIPE_SCRUBBER,
	PIPE_HEAT_EXCHANGE,
	PIPE_THERMAL_PLATE,
	PIPE_INJECTOR,
	PIPE_DP_VENT,
	PIPE_PASV_VENT,
	PIPE_JUNCTION,
	PIPE_HE_BENT,
	PIPE_HE_STRAIGHT,
	PIPE_GAS_FILTER,
	PIPE_GAS_MIXER
)
var/global/list/heat_pipes = list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)

/obj/item/pipe_spawner
	name = "Pipe Spawner"
	desc = "Used for placing piping parts on the map."

	var/pipe_type = 0
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	level = 2

/obj/item/pipe_spawner/New()
	..()
	var/obj/item/pipe/P = getFromPool(/obj/item/pipe,loc)
	P.New(src.loc, pipe_type=src.pipe_type, dir=src.dir)
	P.update()
	qdel(src)

/obj/item/pipe_spawner/mvalve
	icon_state="mvalve"
	pipe_type=PIPE_MVALVE

/obj/item/pipe_spawner/volumepump
	icon_state="volumepump"
	pipe_type=PIPE_VOLUME_PUMP

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	//var/pipe_dir = 0
	var/pipename
	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	level = 2

	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe/ex_act(severity)
	switch(severity)
		if(1)
			returnToPool(src)
		if(2)
			if(prob(40))
				returnToPool(src)
		if(3)
			if(prob(10))
				returnToPool(src)

/obj/item/pipe/dropped()
	..()
	if(loc)
		setPipingLayer(piping_layer) //realign us, captain!

/obj/item/pipe/blob_act()
	returnToPool(src)

/obj/item/pipe/singularity_act()
	returnToPool(src)
	return 2
var/list/bent_dirs = list(NORTH|SOUTH, WEST|EAST)
/obj/item/pipe/New(var/loc, var/pipe_type as num, var/dir as num, var/obj/machinery/atmospherics/make_from = null)
	..()
	if (make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		var/is_bent
		if  (make_from.initialize_directions in bent_dirs)
			is_bent = 0
		else
			is_bent = 1
		if     (istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			src.pipe_type = PIPE_JUNCTION
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			src.pipe_type = PIPE_HE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/insulated))
			src.pipe_type = PIPE_INSULATED_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/unary/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/insulated))
				src.pipe_type = PIPE_INSUL_MANIFOLD
			else
				src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/layer_manifold))
			src.pipe_type = PIPE_LAYER_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			src.pipe_type = PIPE_UVENT
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve/digital))
			src.pipe_type = PIPE_DVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			src.pipe_type = PIPE_GAS_FILTER
			if(istype(make_from, /obj/machinery/atmospherics/trinary/filter/mirrored))
				src.dir = turn(src.dir, 45) //adjust it to have the proper icon
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			src.pipe_type = PIPE_GAS_MIXER
			if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer/mirrored))
				src.dir = turn(src.dir, 45)
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			src.pipe_type = PIPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			src.pipe_type = PIPE_PASSIVE_GATE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/volume_pump))
			src.pipe_type = PIPE_VOLUME_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			src.pipe_type = PIPE_HEAT_EXCHANGE
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve))
			if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve/digital))
				src.pipe_type = PIPE_DTVALVE
			else
				src.pipe_type = PIPE_MTVALVE
			if(istype(make_from, /obj/machinery/atmospherics/trinary/tvalve/mirrored) || istype(make_from, /obj/machinery/atmospherics/trinary/tvalve/digital/mirrored))
				src.dir = turn(src.dir, 45) //sets the angle and icon correctly
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w))
			if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/insulated))
				src.pipe_type = PIPE_INSUL_MANIFOLD4W
			else
				src.pipe_type = PIPE_MANIFOLD4W
		else if(istype(make_from, /obj/machinery/atmospherics/unary/cap))
			src.pipe_type = PIPE_CAP
		else if(istype(make_from, /obj/machinery/atmospherics/unary/thermal_plate))
			src.pipe_type = PIPE_THERMAL_PLATE
		else if(istype(make_from, /obj/machinery/atmospherics/unary/outlet_injector))
			src.pipe_type = PIPE_INJECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/binary/dp_vent_pump))
			src.pipe_type = PIPE_DP_VENT
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent))
			src.pipe_type = PIPE_PASV_VENT
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/layer_adapter))
			src.pipe_type = PIPE_LAYER_ADAPTER
		setPipingLayer(make_from.piping_layer)

	else
		src.pipe_type = pipe_type
		src.dir = dir
	//src.pipe_dir = get_pipe_dir()
	update()
//	src.pixel_x = rand(-5, 5)
//	src.pixel_y = rand(-5, 5)

/obj/item/pipe/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	if(pipe_type != PIPE_LAYER_MANIFOLD && pipe_type != PIPE_LAYER_ADAPTER)
		pixel_x = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
		pixel_y = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
		layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

//update the name and icon of the pipe item depending on the type

var/global/list/pipeID2State = list(
	"simple",
	"simple",
	"he",
	"he",
	"connector",
	"manifold",
	"junction",
	"uvent",
	"mvalve",
	"pump",
	"scrubber",
	"insulated",
	"insulated",
	"filter",
	"mixer",
	"passivegate",
	"volumepump",
	"heunary",
	"dvalve",
	"mtvalve",
	"manifold4w",
	"cap",
	"thermalplate",
	"injector",
	"dual-port vent",
	"passive vent",
	"dtvalve",
	"insulated_manifold",
	"insulated_manifold4w",
	"manifoldlayer",
	"layeradapter",
)
var/global/list/nlist = list( \
	"pipe", \
	"bent pipe", \
	"h/e pipe", \
	"bent h/e pipe", \
	"connector", \
	"manifold", \
	"junction", \
	"uvent", \
	"manual valve", \
	"pump", \
	"scrubber", \
	"insulated pipe", \
	"bent insulated pipe", \
	"gas filter", \
	"gas mixer", \
	"passive gate", \
	"volume pump", \
	"heat exchanger", \
	"digital valve", \
	"t-valve", \
	"4-way manifold", \
	"pipe cap", \
	"thermal plate", \
	"injector", \
	"dual-port vent", \
	"passive vent", \
	"digital t-valve", \
	"insulated manifold", \
	"insulated 4-way manifold", \
	"pipe alignment converter", \
	"pipe alignment adapter",
)
/obj/item/pipe/proc/update()


	name = nlist[pipe_type+1] + " fitting"
	if(pipe_type == PIPE_LAYER_ADAPTER)
		icon_state="adapter_[piping_layer]"
		icon = 'icons/obj/atmospherics/pipe_adapter.dmi'
	else
		icon = 'icons/obj/pipe-item.dmi'
		icon_state = pipeID2State[pipe_type + 1]

//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise
var/list/straight_pipes = list(PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE)
var/list/bent_pipes = list(PIPE_SIMPLE_BENT, PIPE_HE_BENT, PIPE_INSULATED_BENT)
var/list/manifold_pipes = list(PIPE_MANIFOLD4W, PIPE_INSUL_MANIFOLD4W)
/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained())
		return

	src.dir = turn(src.dir, -90)

	if (pipe_type in straight_pipes)
		dir=rotate_pipe_straight(dir)
	else if (pipe_type in manifold_pipes)
		dir = 2
	//src.pipe_dir = get_pipe_dir()
	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in bent_pipes) \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if (pipe_type in straight_pipes)
		dir=rotate_pipe_straight(dir)
	return

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0
	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_INSULATED_STRAIGHT, \
			PIPE_HE_STRAIGHT, \
			PIPE_JUNCTION ,\
			PIPE_PUMP ,\
			PIPE_VOLUME_PUMP ,\
			PIPE_PASSIVE_GATE ,\
			PIPE_MVALVE, \
			PIPE_DVALVE, \
			PIPE_DP_VENT, \
			PIPE_LAYER_MANIFOLD, \
			PIPE_LAYER_ADAPTER
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT, PIPE_INSULATED_BENT, PIPE_HE_BENT)
			return dir //dir|acw
		if(PIPE_CONNECTOR,PIPE_UVENT,PIPE_PASV_VENT,PIPE_SCRUBBER,PIPE_HEAT_EXCHANGE,PIPE_THERMAL_PLATE,PIPE_INJECTOR)
			return dir
		if(PIPE_MANIFOLD4W, PIPE_INSUL_MANIFOLD4W)
			return dir|flip|cw|acw
		if(PIPE_MANIFOLD, PIPE_INSUL_MANIFOLD)
			return flip|cw|acw
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER,PIPE_MTVALVE,PIPE_DTVALVE)
			return dir|flip|cw
		if(PIPE_CAP)
			return flip
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes


	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

	if (!(pipe_type in heat_pipes))
		return get_pipe_dir()
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0
		if(PIPE_JUNCTION)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/pipe/proc/get_hdir() //endpoints for h/e pipes

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	//*
	if (!iswrench(W))
		return ..()
	if (!isturf(src.loc))
		return 1
	if (pipe_type in straight_pipes)
		dir=rotate_pipe_straight(dir)
	else if (pipe_type in manifold_pipes)
		dir = 2
	var/pipe_dir = get_pipe_dir()
	var/unstackable=(pipe_type in unstackable_pipes)
	var/uses_he=(pipe_type in heat_pipes)
	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M.piping_layer != src.piping_layer && !unstackable && !(M.pipe_flags & ALL_LAYER))
			continue
		if(M.has_initialize_direction(pipe_dir, PIPE_TYPE_STANDARD) || (uses_he && M.has_initialize_direction(pipe_dir, PIPE_TYPE_HE)))
			to_chat(user, "<span class='warning'>There is already a pipe connection in that direction.</span>")
			return 1
	// no conflicts found

	var/obj/machinery/atmospherics/P
	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			P=new/obj/machinery/atmospherics/pipe/simple(loc)

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			P=new/obj/machinery/atmospherics/pipe/simple/heat_exchanging(loc)

		if(PIPE_CONNECTOR)		// connector
			P=new/obj/machinery/atmospherics/unary/portables_connector(loc)

		if(PIPE_MANIFOLD)		//manifold
			P=new /obj/machinery/atmospherics/pipe/manifold(loc)

		if(PIPE_MANIFOLD4W)		//4-way manifold
			P=new /obj/machinery/atmospherics/pipe/manifold4w(loc)

		if(PIPE_JUNCTION)
			P=new /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction( src.loc )

		if(PIPE_UVENT)		//unary vent
			P=new /obj/machinery/atmospherics/unary/vent_pump( src.loc )

		if(PIPE_MVALVE)		//manual valve
			P=new /obj/machinery/atmospherics/binary/valve( src.loc )

		if(PIPE_DVALVE)		//digital valve
			P=new /obj/machinery/atmospherics/binary/valve/digital( src.loc )

		if(PIPE_PUMP)		//gas pump
			P=new /obj/machinery/atmospherics/binary/pump( src.loc )

		if(PIPE_GAS_FILTER)		//gas filter
			P=new /obj/machinery/atmospherics/trinary/filter( src.loc )

		if(PIPE_GAS_MIXER)		//gas mixer
			P=new /obj/machinery/atmospherics/trinary/mixer( src.loc )

		if(PIPE_SCRUBBER)		//scrubber
			P=new /obj/machinery/atmospherics/unary/vent_scrubber( src.loc )

		if(PIPE_INSULATED_STRAIGHT, PIPE_INSULATED_BENT)
			P=new /obj/machinery/atmospherics/pipe/simple/insulated( src.loc )

		if(PIPE_MTVALVE)		//manual t-valve
			P=new /obj/machinery/atmospherics/trinary/tvalve(src.loc)

		if(PIPE_CAP)
			P=new /obj/machinery/atmospherics/unary/cap(src.loc)

		if(PIPE_PASSIVE_GATE)		//passive gate
			P=new /obj/machinery/atmospherics/binary/passive_gate(src.loc)

		if(PIPE_VOLUME_PUMP)		//volume pump
			P=new /obj/machinery/atmospherics/binary/volume_pump(src.loc)

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			P=new /obj/machinery/atmospherics/unary/heat_exchanger( src.loc )

		if(PIPE_THERMAL_PLATE)		//unary vent
			P=new /obj/machinery/atmospherics/unary/thermal_plate( src.loc )

		if(PIPE_INJECTOR)		//unary vent
			P=new /obj/machinery/atmospherics/unary/outlet_injector( src.loc )

		if(PIPE_DP_VENT)		//volume pump
			P=new /obj/machinery/atmospherics/binary/dp_vent_pump(src.loc)

		if(PIPE_PASV_VENT)
			P=new /obj/machinery/atmospherics/unary/vent(src.loc)

		if(PIPE_DTVALVE)
			P=new /obj/machinery/atmospherics/trinary/tvalve/digital(src.loc)

		if(PIPE_INSUL_MANIFOLD)
			P=new /obj/machinery/atmospherics/pipe/manifold/insulated(src.loc)

		if(PIPE_INSUL_MANIFOLD4W)
			P=new /obj/machinery/atmospherics/pipe/manifold4w/insulated(src.loc)

		if(PIPE_LAYER_MANIFOLD)
			P =new /obj/machinery/atmospherics/pipe/layer_manifold(src.loc)

		if(PIPE_LAYER_ADAPTER)
			P =new /obj/machinery/atmospherics/pipe/layer_adapter(src.loc)

	P.setPipingLayer(src.piping_layer)
	if(P.buildFrom(usr,src))
		investigation_log(I_ATMOS,"was created by [user]/([user.ckey]) at [formatJumpTo(loc)].")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message( \
			"[user] fastens \the [src].", \
			"<span class='notice'>You have fastened \the [src].</span>", \
			"You hear a ratchet.")
		returnToPool(src)	// remove the pipe item
		return 0
	else
		// If the pipe's still around, nuke it.
		if(P)
			qdel(P)
			P = null
	return 1
	 //TODO: DEFERRED


/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	flags = FPRINT
	w_class = W_CLASS_LARGE

	var/layer_to_make = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()

	if (!iswrench(W))
		return ..()
	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in src.loc)
		if(P.piping_layer == layer_to_make)
			pipe = P
			break
	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe.</span>")
		return 1
	new/obj/machinery/meter(src.loc, pipe)
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have fastened the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/dropped()
	..()
	if(loc)
		setAttachLayer(layer_to_make)

/obj/item/pipe_meter/proc/setAttachLayer(var/new_layer = PIPING_LAYER_DEFAULT)
	layer_to_make = new_layer
	src.pixel_x = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	src.pixel_y = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

/obj/item/pipe_gsensor
	name = "gas sensor"
	desc = "A sensor that can be hooked to a computer."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	item_state = "buildpipe"
	flags = FPRINT
	w_class = W_CLASS_LARGE

/obj/item/pipe_gsensor/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	if (!iswrench(W))
		return ..()
	new/obj/machinery/air_sensor( src.loc )
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have fastened the gas sensor.</span>")
	qdel(src)
