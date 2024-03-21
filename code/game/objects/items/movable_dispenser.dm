/obj/item/movable_machinery
	name = "undeployed ERROR"
	desc = "something went wrong."
	w_class = W_CLASS_LARGE
	throw_range = 0
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND | SLOWDOWN_WHEN_CARRIED
	slowdown = MAGBOOTS_SLOWDOWN_HIGH
	var/obj/machinery/machine = null
	var/deploy_progress = 0
	
/obj/item/movable_machinery/can_be_pulled()
	return FALSE
	
/obj/item/movable_machinery/proc/deploy()
	if(!machine)
		visible_message("\the [src] vanishes into thin air. contact an administrator.")
		qdel(src)
		return
	machine.forceMove(get_turf(src))
	machine.transform = null
	playsound(src, 'sound/items/dispenser_generate_metal.wav', vol=100, vary=0)
	qdel(src)
	
/obj/item/movable_machinery/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!iswrench(W))
		return ..()
	if(!isturf(loc))
		to_chat(user,"<span class='warning'>\The [src] needs to be on the floor to be deployed!</span>")
		return
	anchored = TRUE
	playsound(src, 'sound/items/wrench_hit_build_success2.wav', vol=100, vary=0)
	user.delayNextAttack(1 SECONDS)
	animate(src, transform = transform*1.2, time = 0.5 SECONDS)
	deploy_progress +=1
	if(deploy_progress >= 4)
		deploy()
	
/obj/item/movable_machinery/SlipDropped(var/mob/living/user, var/slip_dir, var/slipperiness = TURF_WET_WATER)
//if this ever applies to more than just dispensers, make sure you check for living occupants and shit so they don't get deleted
	..()
	if(!machine)
		visible_message("\the [src] vanishes into thin air. contact an administrator.")
		qdel(src)
		return
	machine.forceMove(get_turf(src))
	machine.spillContents(destroy_chance = 0)
	qdel(machine)
	new /obj/item/stack/sheet/metal (get_turf(src))
	playsound(src, 'sound/items/dispenser_explode.wav', vol=100, vary=0)
	qdel(src)
	
	
	
/obj/machinery/proc/move_that_gear_up(var/t = 2 SECONDS)
	animate(src, transform = matrix()*0.5, time = t)
	sleep(t)
	var/obj/item/movable_machinery/dispenser = new /obj/item/movable_machinery (loc)
	dispenser.transform = transform
	dispenser.name = "undeployed [name]"
	dispenser.desc = "[desc]. Use a wrench to deploy."
	dispenser.icon = icon
	dispenser.icon_state = icon_state
	dispenser.machine = src
	forceMove(dispenser)