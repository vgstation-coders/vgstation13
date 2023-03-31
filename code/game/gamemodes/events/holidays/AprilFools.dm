//placeholder for holiday stuff

/obj/machinery/proc/movethatgearup()
	var/obj/item/dispenser/undeployed = new /obj/item/dispenser(src.loc)
	undeployed.name			= "undeployed "+src.name
	undeployed.desc			= "gotta move that gear up!"
	undeployed.icon			= src.icon
	undeployed.icon_state	= src.icon_state
	undeployed.machine		= src
	src.forceMove(undeployed)
	
	transfer_fingerprints_to(undeployed)
	visible_message("<span class='notice'>\The [src] undeploys!</span>")
	animate(undeployed, transform = matrix()*0.5, time = 10)

/obj/item/dispenser
	name = "unconfigured dispenser"
	desc = "this one doesn't do anything."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	var/obj/machinery/machine = null
	var/wrenching_progress = 0.5 	//0.5 to 1, in 0.1 increments
	
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND | SLOWDOWN_WHEN_CARRIED
	slowdown = 2
	w_class = W_CLASS_LARGE
	throw_range = 0
	
/obj/item/dispenser/can_be_pulled()
	return FALSE

/obj/item/dispenser/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tool/wrench))
		if(!anchored)
			anchored = TRUE
		user.delayNextAttack(10)
		playsound(user.loc, "sound/weapons/wrench_hit_build_success2.wav", 25, 0)
		wrenching_progress += 0.1
		var/matrix/M = matrix()
		M.Scale(wrenching_progress,wrenching_progress)
		animate(src, transform = M, time = 5)
		if(wrenching_progress >= 1)
			if(!machine)
				visible_message("<span class='notice'>\The [src] vanishes into nothingness</span>")
				qdel(src)
				return
			machine.forceMove(get_turf(src))
			playsound(user.loc, "sound/weapons/dispenser_generate_metal.wav", 25, 0)
			qdel(src)
	..()
	
/obj/item/dispenser/SlipDropped(mob/user)
	if(machine)
		machine.forceMove(user.loc)
		machine.spillContents()
		qdel(machine)
		new /obj/item/stack/sheet/metal(get_turf(src), 2)
		new /obj/effect/decal/cleanable/blood/gibs/robot(get_turf(src))
	message_admins("dispenser down!")
	playsound(user.loc, "sound/weapons/dispenser_explode.wav", 25, 0)
	qdel(src)