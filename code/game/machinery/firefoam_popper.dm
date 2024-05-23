/obj/item/firefoam_popper
	name = "Firefoam Popper"
	desc = "A deployable firefoam popper which deploys foam if it catches on fire."
	icon = 'icons/obj/items.dmi'
	icon_state = "popper"
	item_state = "popper"
	origin_tech = Tc_ENGINEERING + "=1"
	flags = FPRINT
	w_type = RECYK_ELECTRONIC
	w_class = W_CLASS_LARGE
	flammable = FALSE
	var/ceiling_mounting = FALSE
	var/deployed = /obj/machinery/firefoam_popper
	var/deployed_ceiling = /obj/machinery/firefoam_popper/ceiling

/obj/item/firefoam_popper/attack_self(mob/user)
	preattack(get_turf(user), user, 1)

/obj/item/firefoam_popper/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = 1
	if(!proximity_flag)
		return
	if(!isturf(target))
		return ..()
	var/turf/T = target
	if(locate(deployed) in T)
		to_chat(user, "<span class='warning'>There is already a firefoam popper here!</span>")
		return
	if(T.density)
		to_chat(user, "<span class='warning'>You can't deploy it there!</span>")
		return
	new deployed(T)
	if(ceiling_mounting)
		T.ceiling_mounted = TRUE
	user.drop_item(src, force_drop = 1)
	qdel(src)

/obj/item/firefoam_popper/verb/ceiling_mount()
	set name = "Toggle ceiling mounting"
	set category = "Object"
	ceiling_mounting = !ceiling_mounting
	to_chat(user, "<span class='notice'>You will [ceiling_mounting?"now":"no longer"] attempt to mount the [src] to the ceiling.</span>")

/obj/item/firefoam_popper/examine()
	if(ceiling_mounted)
		desc += " It will be mounted on the ceiling when deployed."

/obj/machinery/firefoam_popper
	name = "firefoam popper"
	desc = "A firefoam popper which deploys foam if it catches on fire."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "popper"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE

	flammable = TRUE
	thermal_mass = ARBITRARILY_LARGE_NUMBER // will only catch on fire while in the active state and will extinguish itself
	w_type = RECYK_ELECTRONIC

	var/obj/item/firefoam_popper/undeployed
	var/active = 1 //0 off; 1 armed; 2 firing
	var/powercost = 5
	var/max_water = 100

	var/scanning = FALSE //has this been upgraded and is scanning for fires
	var/scan_range = 0 //how far does it scan for fires
	var/covered_range = 5 //how far does it throw foam
	var/in_proximity = FALSE
	var/resettable = FALSE

	machine_flags = WRENCHMOVE


/obj/machinery/firefoam_popper/update_icon()
	if(ceiling_mounted)
		src.transform = turn(src.tranform, 180)
		if(anchored)
			alpha = 0
		else
			alpha = 128
		return
	else
		src.transform = initial(src.transform)
		update_liquid_overlays()

/obj/machinery/firefoam_popper/update_liquid_overlays()
	overlays.len = 0
	underlays.len = 0
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]5")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 99)
				filling.icon_state = "[icon_state]75"
			else
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/machinery/firefoam_popper/process()
	..()
	if(!anchored)
		return
	if(active == 1)
		if(on_fire)
			trigger()
	else
		machines -= src

/obj/machinery/firefoam_popper/ignite()
	if(!anchored || active != 1)
		return
	..()

/obj/firefoam_popper/proc/trigger()
	active = 2
	machines -= src
	var/turf/mainloc = get_turf(src)
	//animated sparks stolen from rimworld
	//play rimworld sound
	//spread foam to covered_range
	//use all reagents
	explosion(get_turf(src),0,0,0)
	if(!resettable)
		qdel(src)

/obj/machinery/firefoam_popper/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firefoam_popper/attack_hand(mob/user as mob)
	var/obj/item/

/obj/machinery/firefoam_popper/attack_ghost(var/mob/dead/observer/ghost)
	if(!can_spook())
		return FALSE
	if(!ghost.can_poltergeist())
		to_chat(ghost, "Your poltergeist abilities are still cooling down.")
		return FALSE
	investigation_log(I_GHOST, "|| was switched [on ? "off" : "on"] by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return ..()

/obj/machinery/firefoam_popper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
				return
			else
				if(user.drop_item(W, src))
					cell = W
					user.visible_message("<span class='notice'>[user] inserts \the [W] into \the [src].</span>", \
					"<span class='notice'>You insert \the [W] into \the [src].</span>")
					update_icon()

/obj/machinery/firefoam_popper/ceiling
	density = 0
	machine_flags = 0
	alpha = 0
	pixel_y = 4

/obj/machinery/firefoam_popper/ceiling/New()
	src.transform = turn(src.tranform, 180)

/obj/machinery/firefoam_popper/ceiling/examine()
	desc += " It is mounted on the ceiling."

/obj/machinery/firefoam_popper/advanced
	name = "advanced firefoam popper"
	desc = "A fully-resettable firefoam popper which deploys foam if a fire is within its scanning range."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "adv_popper"
	density = 1
	flammable = FALSE

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 5
	active_power_usage = 100

	scanning = TRUE
	scan_range = 2
	covered_range = 5
	in_proximity = FALSE
	resettable = TRUE

	var/max_water = 100

/obj/machinery/firefoam_popper/advanced/New()
	. = ..()
	create_reagents(max_water)
	reagents.add_reagent(WATER, max_water)

	component_parts = newlist(
		/obj/item/weapon/circuitboard/firefoam_popper,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/capacitor
	)

	RefreshParts()

/obj/machinery/firefoam_popper/advanced/process()
	..()
	var/turf/mainloc = get_turf(src)
	for(var/obj/effect/fire/F in range(scan_range,mainloc))
		in_proximity = TRUE
		trigger()
		break
