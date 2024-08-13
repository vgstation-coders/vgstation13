/*
IN THIS FILE:
objects that make up the exterior (shell) of the reactor.
included:
	reactor casing
	coolant port
	controller computer
*/



/obj/machinery/atmospherics/unary/fissionreactor_coolantport
	name="fission reactor coolant port"
	var/datum/fission_reactor_holder/associated_reactor=null
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/atmospherics/unary/fissionreactor_coolantport/proc/transfer_reactor() //transfer coolant from/to the reactor
	if(!associated_reactor)
		return
	var/pressure_coolant=air_contents.pressure
	var/pressure_reactor=associated_reactor.coolant.pressure
	
	var/pdiff=pressure_reactor-pressure_coolant
	if (pdiff<0) //flowing external->reactor
		pdiff*=-1 
		var/molestotransfer=  pdiff*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
		var/datum/gas_mixture/nu_mix=air_contents.remove(molestotransfer *0.5) //we multiply by 1/2 because if we transfer the whole difference, then it'll just swap between the 2 bodies forever.
		associated_reactor.coolant.merge(nu_mix) 
	else //flowing reactor->external
		var/molestotransfer=  pdiff*associated_reactor.coolant.volume/(R_IDEAL_GAS_EQUATION*associated_reactor.coolant.temperature)
		var/datum/gas_mixture/nu_mix=associated_reactor.coolant.remove(molestotransfer *0.5)
		air_contents.merge(nu_mix)
		


	
	


/obj/machinery/computer/fissioncontroller
	name="fission reactor controller"
	idle_power_usage = 500
	active_power_usage = 500
	circuit=/obj/item/weapon/circuitboard/fisson_reactor
	var/can_autoscram=TRUE //automatic safeties if it gets too hot or power is cut.
	var/datum/fission_reactor_holder/associated_reactor=null
	
	
/obj/machinery/computer/fissioncontroller/process()
	if(!associated_reactor) //no reactor? no processing to be done.
		return
	if(!associated_reactor.fuel) //no fuel? no reactions to be done.
		return
	if(associated_reactor.fuel.life<=0) //fuel depleted? no reactions to be done.
		return

	associated_reactor.fissioncycle()
//SS_WAIT_MACHINERY







/obj/structure/fission_reactor_case
	var/datum/fission_reactor_holder/associated_reactor=null
	name="fission reactor casing"


/obj/structure/girder/reactor
	material=/obj/item/stack/sheet/plasteel
	construction_length=60
	var/pipeadded=FALSE
	
/obj/structure/girder/reactor/attackby(obj/item/W as obj, mob/user as mob) //this proc uses a lot of weird checks that will probably break with the multiple construction steps, so lets just use our own override. (it's also just messy in general and hard to follow)
	switch(state)
		if(0) // fresh built frame
			if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/rods/R = W
				if(R.amount < 4)
					to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
					return
				user.visible_message("<span class='notice'>[user] starts inserting internal support struts into \the [src].</span>", "<span class='notice'>You start inserting internal support struts into \the [src].</span>")
				if(do_after(user, src,construction_length))
					var/obj/item/stack/rods/O = W
					if(O.amount < 4)
						to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
					O.use(4)
					user.visible_message("<span class='notice'>[user] inserts internal support struts into \the [src].</span>", "<span class='notice'>You insert internal support struts into \the [src].</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					state++
				return
			if(W.is_wrench(user))
				W.playtoolsound(src, 100)
				user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", "<span class='notice'>You start disassembling \the [src].</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", "<span class='notice'>You dissasemble \the [src].</span>")
					new material(get_turf(src), 2)
					qdel(src)
				return
			to_chat(user, "<span class='notice'>You can't find a use for \the [W]</span>")
			return
					
		if(1) // added rods
			if(W.is_screwdriver(user)) //fasten the rods
				W.playtoolsound(src, 100)
				user.visible_message("<span class='notice'>[user] starts securing \the [src]'s internal support struts.</span>", "<span class='notice'>You start securing \the [src]'s internal support struts.</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='notice'>[user] secures \the [src]'s internal support struts.</span>", "<span class='notice'>You secure \the [src]'s internal support struts.</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					state++
				return
			if(W.is_wirecutter(user)) //remove the rods
				W.playtoolsound(src, 100)
				user.visible_message("<span class='warning'>[user] starts removing \the [src]'s internal support struts.</span>", "<span class='notice'>You start removing \the [src]'s internal support struts.</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='warning'>[user] removes \the [src]'s internal support struts.</span>", "<span class='notice'>You remove \the [src]'s internal support struts.</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					new /obj/item/stack/rods(get_turf(src), 4)
					state--
				return
			to_chat(user, "<span class='notice'>You can't find a use for \the [W]</span>")
			return
		if(2) // secured rods
			if(W.is_screwdriver(user))
				W.playtoolsound(src, 100)
				user.visible_message("<span class='warning'>[user] starts unsecuring \the [src]'s internal support struts.</span>", "<span class='notice'>You start unsecuring \the [src]'s internal support struts.</span>")
				if(do_after(user, src, construction_length))
					user.visible_message("<span class='warning'>[user] unsecures \the [src]'s internal support struts.</span>", "<span class='notice'>You unsecure \the [src]'s internal support struts.</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					state--
				return
			if(istype(W, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/R = W
				if(R.amount < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to finish the outer plating.</span>")
					return
				user.visible_message("<span class='notice'>[user] starts placing external plating into \the [src].</span>", "<span class='notice'>You start placing external plating into \the [src].</span>")
				if(do_after(user, src,construction_length))
					var/obj/item/stack/sheet/plasteel/O = W
					if(O.amount < 2)
						to_chat(user, "<span class='warning'>You need more sheets to finish the outer plating.</span>")
					O.use(2)
					user.visible_message("<span class='notice'>[user] places external plating into \the [src].</span>", "<span class='notice'>You place external plating into \the [src].</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					state++
				return
			to_chat(user, "<span class='notice'>You can't find a use for \the [W]</span>")	
			return
		if(3) // plating added
			if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] starts welding the external plating to \the [src]'s frame.</span>", "<span class='notice'>You start welding the external plating to \the [src]'s frame.</span>")
				if(WT.do_weld(user,src,construction_length,0))
					user.visible_message("<span class='notice'>[user] welds the external plating to \the [src]'s frame.</span>", "<span class='notice'>You weld the external plating to \the [src]'s frame.</span>")
					
					if(pipeadded)
						var/obj/structure/fission_reactor_case/newcase= new /obj/structure/fission_reactor_case
						newcase.loc=src.loc
					else
						var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/newcase= new /obj/machinery/atmospherics/unary/fissionreactor_coolantport
						newcase.loc=src.loc
					qdel(src)

				return
			if(iscrowbar(W))
				W.playtoolsound(src, 100)
				user.visible_message("<span class='warning'>[user] starts prying external plating off \the [src].</span>", "<span class='notice'>You start prying the external plating off \the [src].</span>")
				if(do_after(user, src, construction_length*0.5 ))
					user.visible_message("<span class='warning'>[user] pries the external plating off \the [src].</span>", "<span class='notice'>You pry the external plating off the \the [src].</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					new material(get_turf(src), 2)
					state--
			to_chat(user, "<span class='notice'>You can't find a use for \the [W]</span>")
			return
	..()

