/obj/item/weapon/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/electronics.dmi', "right_hand" = 'icons/mob/in-hand/right/electronics.dmi')
	opacity = 0
	flags = FPRINT
	siemens_coefficient = 1 //Not quite as conductive as working with cables themselves
	force = 5.0 //Plastic is soft
	throwforce = 5.0
	throw_speed = 1
	throw_range = 10
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_MATERIALS + "=4"
	var/max_amount = 90
	var/active = 0
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null
	var/targetMoveKey = null

/obj/item/weapon/rcl/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		if(!loaded)
			if(user.drop_item(W,src))
				loaded = W
				loaded.max_amount = max_amount //We store a lot.
		else
			loaded.preattack(W,user,1)
		update_icon()
		to_chat(user, "<span class='notice'>You add the cables to the [src]. It now contains [loaded.amount].</span>")
	else if(W.is_screwdriver(user))
		if(!loaded)
			return
		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		while(loaded.amount>30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				getFromPool(/obj/item/stack/cable_coil,user.loc,diff)
			else
				loaded.use(30)
				getFromPool(/obj/item/stack/cable_coil,user.loc,30)
		loaded.max_amount = initial(loaded.max_amount)
		loaded.forceMove(user.loc)
		user.put_in_hands(loaded)
		loaded = null
		update_icon()
	else
		..()

/obj/item/weapon/rcl/examine(mob/user)
	..()
	if(loaded)
		to_chat(user, "<span class='info'>It contains [loaded.amount]/90 cables.</span>")

/obj/item/weapon/rcl/Destroy()
	qdel(loaded)
	loaded = null
	last = null
	active = 0
	set_move_event()
	..()

/obj/item/weapon/rcl/update_icon()
	if(!loaded)
		icon_state = "rcl-0"
		item_state = "rcl-0"
		return
	switch(loaded.amount)
		if(61 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(31 to 60)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 30)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"

/obj/item/weapon/rcl/proc/is_empty(mob/user)
	update_icon()
	if(loaded && !loaded.amount)
		to_chat(user, "<span class='notice'>The last of the cables unreel from \the [src].</span>")
		returnToPool(loaded)
		loaded = null
		active = 0
		return 1
	return 0

/obj/item/weapon/rcl/dropped(mob/wearer as mob)
	..()
	active = 0
	set_move_event(wearer)

/obj/item/weapon/rcl/proc/set_move_event(mob/user)
	if(user)
		if(active)
			trigger(user)
			targetMoveKey = user.on_moved.Add(src, "holder_moved")
			return
		user.on_moved.Remove(targetMoveKey)
	targetMoveKey = null

/obj/item/weapon/rcl/attack_self(mob/user as mob)
	active = !active
	to_chat(user, "<span class='notice'>You turn \the [src] [active ? "on" : "off"].<span>")
	set_move_event(user)

/obj/item/weapon/rcl/proc/holder_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:holder_moved")
		return
	if(active)
		trigger(E.holder)

/obj/item/weapon/rcl/proc/trigger(mob/user as mob)
	if(!loaded)
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return
	if(last)
		if(get_dist(last, user) == 0) //hacky, but it works
			last = null
		else if(get_dist(last, user) == 1)
			if(get_dir(last, user)==last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last,user)
			if(is_empty(user))
				return //If we've run out, display message and exit
		else
			last = null
	last = loaded.turf_place(get_turf(src.loc),user,turn(user.dir,180))
	is_empty(user) //If we've run out, display message

/obj/item/weapon/rcl/pre_loaded/New() //Comes preloaded with cable, for testing stuff
	..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon()
