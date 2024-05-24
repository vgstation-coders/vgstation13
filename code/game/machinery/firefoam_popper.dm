/obj/item/firefoam_popper
	name = "Firefoam Popper"
	desc = "A deployable firefoam popper which deploys foam if it catches on fire."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "popper_mini"
	item_state = "popper_mini"
	origin_tech = Tc_ENGINEERING + "=2"
	flags = FPRINT
	w_type = RECYK_ELECTRONIC
	w_class = W_CLASS_LARGE
	flammable = FALSE
	var/ceiling_mounting = FALSE
	var/deployed = /obj/machinery/firefoam_popper
	var/deployed_ceiling = /obj/machinery/firefoam_popper/ceiling
	var/list/contained_parts = list()

/obj/item/firefoam_popper/New()
	contained_parts = newlist(
		/obj/item/weapon/circuitboard/firefoam_popper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
		)

/obj/item/firefoam_popper/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = 1
	if(!proximity_flag)
		return
	if(!isturf(target))
		return ..()
	var/turf/T = target
	if(install(user,T))
		user.drop_item(src, force_drop = 1)
		qdel(src)

/obj/item/firefoam_popper/proc/install(mob/user,turf/targ)
	if(locate(deployed) in targ)
		to_chat(user, "<span class='warning'>There is already a firefoam popper here!</span>")
		return 0
	if(targ.density)
		to_chat(user, "<span class='warning'>You can't deploy it there!</span>")
		return 0
	var/obj/machinery/firefoam_popper/F
	if(ceiling_mounting)
		F = new deployed_ceiling(targ)
	else
		F = new deployed(targ)
	to_chat(user, "<span class='notice'>You install the [src][ceiling_mounting?" to the ceiling":""].</span>")
	F.component_parts = contained_parts
	F.RefreshParts()
	return 1

/obj/item/firefoam_popper/attack_self(mob/user)
	ceiling_mount(user)

/obj/item/firefoam_popper/proc/ceiling_mount(mob/user)
	ceiling_mounting = !ceiling_mounting
	to_chat(user, "<span class='notice'>You will [ceiling_mounting?"now":"no longer"] attempt to mount the [src] to the ceiling.</span>")

/obj/item/firefoam_popper/examine(mob/user)
	..()
	if(ceiling_mounting)
		to_chat(user, "<span class = 'notice'>It will be mounted on the ceiling when deployed.</span>")

/obj/item/firefoam_popper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(iswrench(W))
		if(loc == user)
			var/turf/T = get_turf(user)
			preattack(T,user,1)
		else
			if(install(user,loc))
				qdel(src)

/obj/machinery/firefoam_popper
	name = "firefoam popper"
	desc = "A firefoam popper which deploys foam if it catches on fire."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "popper"
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE

	flammable = TRUE
	thermal_mass = ARBITRARILY_LARGE_NUMBER // needs to catch on fire to trigger if not upgraded
	w_type = RECYK_ELECTRONIC

	var/scanning = FALSE //it has been upgraded and is scanning for fires
	var/scan_range = 0 //how far does it scan for fires
	var/covered_range = 2 //how far does it throw foam
	var/active = FALSE //is it currently firing

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/firefoam_popper/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/firefoam_popper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/firefoam_popper/RefreshParts()
	var/scanningcount
	var/manipcount
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scanningcount += SP.rating-1
		else if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipcount += SP.rating
	scan_range = initial(scan_range) + (scanningcount * 2) //default 0
	if(scan_range)
		scanning = TRUE
	covered_range = round(initial(covered_range) + manipcount) //default 4
	if(scanning)
		machines |= src
	else
		machines -= src
	..()

/obj/machinery/firefoam_popper/process()
	..()
	if(scanning && !active)
		var/turf/T = get_turf(src)
		for(var/obj/effect/fire in range(scan_range,T))
			trigger()
			return

/obj/machinery/firefoam_popper/update_icon()
	if(active)
		icon_state = "popper_active"
		set_light(2,2)
		return 1

/obj/machinery/firefoam_popper/ignite()
	if(active)
		return
	trigger()
	..()

/obj/machinery/firefoam_popper/proc/trigger()
	active = TRUE
	machines -= src
	icon_state = "popper_firing"
	playsound(src,'sound/effects/hiss.ogg',30,0,-1)
	sleep(3 SECONDS)
	var/turf/epicenter = get_turf(src)
	for(var/turf/T in dview(covered_range, epicenter, INVISIBILITY_MAXIMUM))
		if(cheap_pythag(T.x - epicenter.x,T.y - epicenter.y) <= covered_range + 0.5)
			if(test_reach(epicenter,T,PASSTABLE|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER|PASSRAILING))
				var/datum/reagents/R = new/datum/reagents(5)
				R.my_atom = T
				R.add_reagent(WATER, 5)
				var/obj/effect/foam/fire/F = new /obj/effect/foam/fire(T,R)
				var/turf/F_turf = get_turf(F)
				F.reagents.reaction(F_turf, TOUCH)
				for(var/atom/atm in F_turf)
					if(!F || !F.reagents)
						continue
					F.reagents.reaction(atm, TOUCH)
					if(F.reagents.has_reagent(WATER))
						if(isliving(atm))
							var/mob/living/M = atm
							M.ExtinguishMob()
						if(atm.on_fire)
							atm.extinguish()
	explosion(get_turf(src),0,0,0)
	qdel(src)

/obj/machinery/firefoam_popper/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firefoam_popper/attack_hand(mob/user as mob)
	if(scanning)
		to_chat(user, "<span class='notice'>\The [src] will activate when a fire is detected within [scan_range] tiles.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] will activate when it catches on fire.</span>")
	to_chat(user, "<span class='notice'>\The [src] will extinguish fires within [covered_range] tiles.</span>")

/obj/machinery/firefoam_popper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(iswrench(W))
		to_chat(user, "<span class='notice'>You uninstall \the [src].</span>")
		var/turf/T = get_turf(user)
		var/obj/item/firefoam_popper/undeployed = new(T)
		undeployed.contained_parts = component_parts
		transfer_fingerprints(src,undeployed)
		user.put_in_hands(undeployed)
		qdel(src)

/obj/machinery/firefoam_popper/ceiling
	density = 0
	alpha = 0
	pixel_y = 4

/obj/machinery/firefoam_popper/ceiling/New()
	..()
	src.transform = turn(src.transform, 180)

/obj/machinery/firefoam_popper/ceiling/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>It is mounted on the ceiling.</span>")

/obj/machinery/firefoam_popper/ceiling/update_icon()
	if(..())
		src.transform = turn(src.transform, 180)
		alpha = 0
		pixel_y = 4

/obj/item/weapon/circuitboard/firefoam_popper
	name = "Circuit Board (Firefoam Popper)"
	desc = "A circuit board used to run a firefoam popper."
	build_path = /obj/machinery/firefoam_popper
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;"
	req_components = list (
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2)
