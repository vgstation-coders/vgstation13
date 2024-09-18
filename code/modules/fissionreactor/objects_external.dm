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
	icon='icons/obj/fissionreactor/reactorcase.dmi'
	icon_state="coolantcase"
	density =1
	anchored =1
	var/datum/fission_reactor_holder/associated_reactor=null
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	active_power_usage = 0
	var/pipename="fission reactor coolant port"
	//this is so that we can call a proc with ourselves that will use a proc that shouldn't belong to this. this is probably very fragile, but just don't touch it and it'll be fine, i swear
/obj/machinery/atmospherics/unary/fissionreactor_coolantport/proc/get_pipe_dir() //the atmos gods demand a sacrifice.
	return dir

/obj/machinery/atmospherics/unary/fissionreactor_coolantport/examine()
	..()
	if(associated_reactor && associated_reactor.considered_on())
		to_chat(usr,"the outer plating looks like it could be cut,<span class='danger'> but it seems like a <u>really</u> bad idea.</span>")
	else
		to_chat(usr,"the outer plating looks like it could be cut.")


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/attackby(var/obj/I,var/mob/user)
	if(iswelder(I))
		if(associated_reactor?.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
			var/obj/item/tool/weldingtool/WT = I
			user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
			if(WT.do_weld(user,src,60,0))
				var/obj/structure/girder/reactor/newcase= new /obj/structure/girder/reactor
				newcase.forceMove(loc)
				newcase.pipeadded=TRUE
				newcase.state=3
				qdel(src)


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/New()
	..()
	src.buildFrom(usr,src)

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
		//air_contents.update=1
		if(network)
			network.update=1
	else //flowing reactor->external
		var/molestotransfer=  pdiff*associated_reactor.coolant.volume/(R_IDEAL_GAS_EQUATION*associated_reactor.coolant.temperature)
		var/datum/gas_mixture/nu_mix=associated_reactor.coolant.remove(molestotransfer *0.5)
		air_contents.merge(nu_mix)
		if(network)
			network.update=1
		//air_contents.update=1
		


	
	


/obj/machinery/fissioncontroller
	name="fission reactor controller"
	icon='icons/obj/fissionreactor/controller.dmi'
	icon_state="control_noreactor"
	idle_power_usage = 500
	active_power_usage = 500
	density =1
	anchored =1
	//circuit=/obj/item/weapon/circuitboard/fission_reactor
	var/can_autoscram=TRUE //automatic safeties if it gets too hot or power is cut.
	var/datum/fission_reactor_holder/associated_reactor=null
	var/obj/item/weapon/fuelrod/currentfuelrod=null
	var/poweroutagemsg=FALSE
	var/fueldepletedmsg=TRUE
	var/lasttempnag=0 //ensures temp warning only occur if it is increasing. less chat spam.

/obj/machinery/fissioncontroller/Destroy()
	if(currentfuelrod)
		currentfuelrod.forceMove(loc)
		currentfuelrod=null
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	..()

/*/proc/playsound(var/atom/source, soundin, vol as num, vary = 0, extrarange as num, falloff, var/gas_modified = 1, var/channel = 0,var/wait = FALSE, var/frequency = 0)*/

/obj/machinery/fissioncontroller/attackby(var/obj/I,var/mob/user)
	if(istype(I,/obj/item/weapon/fuelrod))
		if(currentfuelrod)
			to_chat(user,"There's already a fuel rod inserted into \the [src].")
		else
			var/obj/item/weapon/fuelrod/newrod=I
			if(!user.drop_item(newrod))
				return
			to_chat(user,"You insert the fuel rod into \the [src].")
			newrod.loc=null
			currentfuelrod=newrod
			playsound(src,'sound/items/crowbar.ogg',50)
			associated_reactor?.fuel=newrod.fueldata
		return
	if(iscrowbar(I) && currentfuelrod)
		if(associated_reactor?.considered_on())
			if(user.a_intent==I_HELP) //spreading rads is in fact not very helpful
				to_chat(user,"<span class='notice'>You're not sure it's safe to remove the fuel rod.</span>")
				return
			user.visible_message("<span class='warning'>[user] starts prying the fuel rod out of \the [src], even though the reactor is active!</span>", "<span class='warning'>You start prying the fuel rod out of \the [src], even though the reactor is active!</span>")
			playsound(src,'sound/items/crowbar.ogg',50)
			if(do_after(user, src,30))
				currentfuelrod.forceMove(loc)
				currentfuelrod=null
				playsound(src,'sound/machines/door_unbolt.ogg',50)
				associated_reactor?.fuel=null
				//TODO: SPREAD RADS
			return
				
		user.visible_message("<span class='notice'>[user] starts prying the fuel rod out of \the [src].</span>", "<span class='notice'>You start prying the fuel rod out of \the [src].</span>")
		playsound(src,'sound/items/crowbar.ogg',50)
		if(do_after(user, src,20) && currentfuelrod)
			currentfuelrod.forceMove(loc)
			currentfuelrod=null
			playsound(src,'sound/machines/door_unbolt.ogg',50)
			if(associated_reactor)
				associated_reactor.fuel=null
		return

	
	if(iswelder(I))
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
		var/obj/item/tool/weldingtool/WT = I
		user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
		if(WT.do_weld(user,src,60,0))
			var/obj/machinery/constructable_frame/machine_frame/reinforced/newframe= new /obj/machinery/constructable_frame/machine_frame/reinforced
			newframe.forceMove(loc)
			newframe.build_state=3
			newframe.circuit=/obj/item/weapon/circuitboard/fission_reactor
			newframe.components+=/obj/item/stack/rods
			newframe.components+=/obj/item/stack/rods
			newframe.components+=/obj/item/weapon/stock_parts/console_screen
			newframe.components+=/obj/item/weapon/stock_parts/manipulator
			newframe.components+=/obj/item/weapon/stock_parts/matter_bin
			newframe.components+=/obj/item/weapon/stock_parts/scanning_module
			qdel(src)
		return
				
				
				
	if(associated_reactor && associated_reactor.considered_on())
		return

/obj/machinery/fissioncontroller/attack_hand(mob/user)
	if(..())
		return
	if(!associated_reactor)
		associated_reactor=new /datum/fission_reactor_holder
		var/constructionerror=associated_reactor.init_resize(src.loc)
		if(constructionerror)
			say("Failed to setup reactor: [constructionerror]", class = "binaryradio")
			associated_reactor=null
			return
		associated_reactor.init_parts()
		associated_reactor.controller=src
		if(currentfuelrod)
			associated_reactor.fuel=currentfuelrod.fueldata
		say("Reactor setup success.", class = "binaryradio")
		update_icon()
	

/obj/machinery/fissioncontroller/update_icon()
	icon_state="control"
	if(!powered())
		icon_state="control0"
	else if(stat & BROKEN)
		icon_state="controlb"
	else if(!associated_reactor)
		icon_state="control_noreactor"
	else if(!associated_reactor.fuel)
		icon_state="control_nofuel"
	else if(associated_reactor.fuel.life <=0)
		icon_state="control_depleted"
	else if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP)
		icon_state="control_danger"
	else if(!associated_reactor.considered_on())
		icon_state="control_idle"
	

/obj/machinery/fissioncontroller/examine()
	..()
	to_chat(usr, "It's held together tightly, you'll have to cut the metal to take it apart.")
	switch(icon_state)
		if("control0")
			to_chat(usr, "The power is off. You should plug it in. Soon.")
			return
		if("controlb")
			to_chat(usr, "The screen is broken. You should fix it soon.")
			return
		if("control_noreactor")
			to_chat(usr, "The readouts indicate there's no linked reactor.")
		if("control_nofuel")
			to_chat(usr, "The readouts indicate there's no fuel rod inserted.")
		if("control_depleted")
			to_chat(usr, "The readouts indicate that the fuel is depleted.")
		if("control")
			to_chat(usr, "The readouts indicate that the reactor is operating normally.")
		if("control_idle")
			to_chat(usr, "The readouts indicate that the reactor is shut down.")
		if("control_danger")
			to_chat(usr, "The readouts indicate that the reactor is overheated, and that you should cool it down.")
		
	to_chat(usr, "The temperature reads out [associated_reactor.temperature]K")
	if(associated_reactor.fuel)
		to_chat(usr, "The fuel reads out [floor(associated_reactor.fuel.life*100+0.5)]% life remaining")

/*
/obj/machinery/fissioncontroller/set_broken()
	if(can_autoscram)
		associated_reactor.SCRAM=TRUE
		say("Reactor controller electrical fault detected, engaging SCRAM.", class = "binaryradio")
		return TRUE
	return FALSE
*/

/obj/machinery/fissioncontroller/process()
	update_icon()
	if(!associated_reactor) //no reactor? no processing to be done.
		return	
		
	associated_reactor.update_all_icos()
	//associated_reactor.coolantcycle()
	if(!powered()) //with my last breath, i curse zoidberg!
		if(!poweroutagemsg)
			poweroutagemsg=TRUE
			if(can_autoscram)
				say("Reactor lost power, engaging SCRAM.", class = "binaryradio")
				associated_reactor.SCRAM=TRUE
	else
		poweroutagemsg=FALSE
	



	if(associated_reactor.fuel.life<=0)
		if(!fueldepletedmsg)
			say("Reactor fuel depleted.", class = "binaryradio")
		fueldepletedmsg=TRUE
	else
		fueldepletedmsg=FALSE
	
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP && associated_reactor.temperature>lasttempnag )
		if(associated_reactor.temperature>=FISSIONREACTOR_MELTDOWNTEMP)
			say("Reactor at critical temperature: [associated_reactor.temperature]K. Evacuate immediately.", class = "binaryradio")
			if(can_autoscram && !associated_reactor.SCRAM )
				say("critical temperature reached, engaging SCRAM.", class = "binaryradio")
				associated_reactor.SCRAM=TRUE
		else
			say("Reactor at dangerous temperature: [associated_reactor.temperature]K", class = "binaryradio")

	lasttempnag=associated_reactor.temperature
	
	if(associated_reactor.fuel?.life<=0) //no fuel or depleated? no reactions to be done.
		return
	

	
//SS_WAIT_MACHINERY







/obj/structure/fission_reactor_case
	var/datum/fission_reactor_holder/associated_reactor=null
	density =1
	anchored =1
	name="fission reactor casing"
	icon='icons/obj/fissionreactor/reactorcase.dmi'
	icon_state="case"
	
/obj/structure/fission_reactor_case/examine()
	..()
	if(associated_reactor?.considered_on())
		to_chat(usr,"the outer plating looks like it could be cut,<span class='danger'> but it seems like a <u>really</u> bad idea.</span>")
	else
		to_chat(usr,"the outer plating looks like it could be cut.")


/obj/structure/fission_reactor_case/attackby(var/obj/I,var/mob/user)
	if(iswelder(I))
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP)
				to_chat(usr,"<span class='danger'>this seems like a really bad idea.</span>")
				return
			var/obj/item/tool/weldingtool/WT = I
			user.visible_message("<span class='notice'>[user] starts welding \the [src]'s external plating off its frame.</span>", "<span class='notice'>You start welding \the [src]'s external plating off its frame.</span>")
			if(WT.do_weld(user,src,60,0))
				qdel(src)
				var/obj/structure/girder/reactor/newcase= new /obj/structure/girder/reactor
				newcase.forceMove(loc)
				newcase.state=3


/obj/structure/girder/reactor
	name="reactor casing girder"
	material=/obj/item/stack/sheet/plasteel
	construction_length=60
	var/pipeadded=FALSE
	
	
/obj/structure/girder/reactor/examine()
	..()
	switch(state)
		if(0)
			to_chat(usr, "The reinforcing rods have not been added. It looks like a wrench could take it apart.")
		if(1)
			to_chat(usr, "The reinforcing rods are not fastened. It looks like you could cut through them easily.")
		if(2)
			to_chat(usr, "The internal structure is firm, but the outer plating is missing sheets. It looks like you could unsecure the support rods.")
			if(pipeadded)
				var/dirstr=""
				if (dir&NORTH)
					dirstr="north"
				if (dir&SOUTH)
					dirstr="soth"
				if (dir&EAST)
					dirstr="east"
				if (dir&WEST)
					dirstr="west"
				to_chat(usr,"There's piping installed, it's facing [dirstr]. It looks like a wrench could take it out. You think a crowbar might be able to turn where it's facing.")
			else
				to_chat(usr,"It looks like you could fit in some piping right now.")
		if(3)
			to_chat(usr, "The outer plating sits loose on the frame and needs to be bonded. It looks like you could pry it off.")
			if(pipeadded)
				var/dirstr=""
				if (dir&NORTH)
					dirstr="north"
				if (dir&SOUTH)
					dirstr="soth"
				if (dir&EAST)
					dirstr="east"
				if (dir&WEST)
					dirstr="west"
				to_chat(usr,"There's piping installed, it's facing [dirstr].")
			
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
			if(istype(W, /obj/item/pipe ))
				if(pipeadded)
					to_chat(user, "<span class='notice'>There's already a piping added!</span>")	
					return
				var/obj/item/pipe/P = W
				if(P.pipe_type!=0)
					to_chat(user, "<span class='notice'>This isn't the right pipe to use!</span>")	
					return
				qdel(W)
				pipeadded=TRUE
				user.visible_message("<span class='notice'>[user] adds piping into \the [src].</span>", "<span class='notice'>You add piping into \the [src].</span>")	
				return
			if(pipeadded && W.is_wrench(user))
				W.playtoolsound(src, 100)	
				to_chat(user, "<span class='notice'>You remove the piping from \the [src]</span>")	
				var/obj/item/pipe/np= new /obj/item/pipe 
				np.pipe_type=1
				np.forceMove(loc)
				pipeadded=FALSE
				return
			if(pipeadded && iscrowbar(W))
				W.playtoolsound(src, 100)
				var/nds=""
				if(dir&NORTH)
					dir=EAST
					nds="east"
				else if(dir&EAST)
					dir=SOUTH
					nds="south"
				else if(dir&SOUTH)
					dir=WEST
					nds="west"
				else if(dir&WEST)
					dir=NORTH
					nds="north"
				to_chat(user, "<span class='notice'>You turn \the [src]'s piping. It is now facing [nds]</span>")	
				return
			to_chat(user, "<span class='notice'>You can't find a use for \the [W]</span>")	
			return
		if(3) // plating added
			if(iswelder(W))
				var/obj/item/tool/weldingtool/WT = W
				user.visible_message("<span class='notice'>[user] starts welding the external plating to \the [src]'s frame.</span>", "<span class='notice'>You start welding the external plating to \the [src]'s frame.</span>")
				if(WT.do_weld(user,src,construction_length,0))
					user.visible_message("<span class='notice'>[user] welds the external plating to \the [src]'s frame.</span>", "<span class='notice'>You weld the external plating to \the [src]'s frame.</span>")
					
					if(!pipeadded)
						var/obj/structure/fission_reactor_case/newcase= new /obj/structure/fission_reactor_case
						newcase.forceMove(loc)
						newcase.dir=src.dir
					else
						var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/newcase= new /obj/machinery/atmospherics/unary/fissionreactor_coolantport
						newcase.dir=src.dir
						newcase.forceMove(loc)
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



/obj/machinery/constructable_frame/machine_frame/reinforced
	name="reinforced frame"
	desc="A frame made from plasteel for heavy-duty applications."
	

/obj/machinery/constructable_frame/machine_frame/reinforced/attackby(obj/item/P as obj, mob/user as mob)
	if(P.crit_fail)
		to_chat(user, "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>")
		return

	switch(build_state)
		if(1)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, src, 20))
						if(C && C.amount >= 5) // Check again
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							set_build_state(2)
			else if(istype(P, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/glass/G=P
				if(G.amount<1)
					return
				G.use(1)
				to_chat(user, "<span class='notice'>You add the glass to the frame.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				build_path = 1
				icon_state="box_glass"
				return
			else
				if(P.is_wrench(user))
					P.playtoolsound(src, 75)
					to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
					drop_stack(sheet_type, get_turf(src), 5, user)
					qdel(src)
		if(2)
			if(!..())
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == MACHINE_REINFORCED)
						if(!user.drop_item(B, src, failmsg = TRUE))
							return

						playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
						circuit = P
						set_build_state(3)
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						req_component_names = circuit.req_components.Copy()
						for(var/A in req_components)
							var/atom/path = A
							req_component_names[A] = initial(path.name)
						update_desc() // sets the description based on req_components
						to_chat(user, desc)
					else
						to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				else
					if(P.is_wirecutter(user))
						P.playtoolsound(src, 50)
						to_chat(user, "<span class='notice'>You remove the cables.</span>")
						set_build_state(1)
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
						A.amount = 5

		if(3)
			if(!..())
				if(iscrowbar(P))
					P.playtoolsound(src, 50)
					set_build_state(2)
					circuit.forceMove(src.loc)
					circuit = null
					if(components.len == 0)
						to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
					else
						to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
						for(var/obj/item/I in components)
							I.forceMove(src.loc)
					desc = initial(desc)
					req_components = null
					components = null
				else
					if(P.is_screwdriver(user))
						if(isshuttleturf(get_turf(src)))
							to_chat(user, "<span class='warning'>You must move \the [src] to a more stable location, such as a space station, before you can finish constructing it.</span>")
							return
						var/component_check = 1
						for(var/R in req_components)
							if(req_components[R] > 0)
								component_check = 0
								break
						if(component_check)
							P.playtoolsound(src, 50)
							var/type2build = src.circuit.build_path
							if(arcanetampered || circuit.arcanetampered)
								type2build = pick(typesof(/obj/machinery/cooking))
							var/obj/machinery/new_machine = new type2build(loc)
							for(var/obj/O in new_machine.component_parts)
								qdel(O)
							new_machine.component_parts = list()
							for(var/obj/O in src)
								if(circuit.contain_parts) // things like disposal don't want their parts in them
									O.forceMove(components_in_use)
								else
									O.forceMove(null)
								new_machine.component_parts += O
							if(circuit.contain_parts)
								circuit.forceMove(components_in_use)
							else
								circuit.forceMove(null)
							new_machine.RefreshParts()
							new_machine.power_change()
							circuit.finish_building(new_machine, user)
							components = null
							if(arcanetampered || circuit.arcanetampered)
								new_machine.stat |= BROKEN
								new_machine.update_icon()
							qdel(src)
					else
						if(istype(P, /obj/item/weapon/storage/bag/gadgets/part_replacer) && P.contents.len && get_req_components_amt())
							var/obj/item/weapon/storage/bag/gadgets/part_replacer/replacer = P
							var/list/added_components = list()
							var/list/part_list = replacer.contents.Copy()

							//Sort the parts. This ensures that higher tier items are applied first.
							part_list = sortTim(part_list, /proc/cmp_rped_sort)

							for(var/path in req_components)
								while(req_components[path] > 0 && (locate(path) in part_list))
									var/obj/item/part = (locate(path) in part_list)
									if(!part.crit_fail)
										added_components[part] = path
										replacer.remove_from_storage(part, src)
										req_components[path]--
										part_list -= part

							for(var/obj/item/weapon/stock_parts/part in added_components)
								components += part
								to_chat(user, "<span class='notice'>[part.name] applied.</span>")
							replacer.play_rped_sound()

							update_desc()

						else
							if(istype(P, /obj/item/weapon) || istype(P, /obj/item/stack))
								var/matched = FALSE
								for(var/I in req_components)
									if(istype(P, I) && (req_components[I] > 0))
										matched = TRUE
										var/wentin = FALSE
										playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
										if(istype(P, /obj/item/stack))
											var/obj/item/stack/CP = P
											var/camt = min(CP.amount, req_components[I]) // amount of the stack to take, idealy amount required, but limited by amount provided
											var/obj/item/stack/CC = locate() in src
											if(!CC)
												CC = new I(src)
											CC.amount = camt
											CC.update_icon()
											CP.use(camt)
											if(!(CC in components))
												components += CC
											req_components[I] -= camt
											wentin = TRUE

										else if(user.drop_item(P, src))
											components += P
											req_components[I]--
											if(P.is_open_container())
												. = 1
											wentin = TRUE

										if(wentin)
											update_desc()
											to_chat(user, desc)
											break

								if(!matched)
									to_chat(user, "<span class='warning'>You cannot add that component to the machine!</span>")
									

/obj/item/weapon/circuitboard/fission_reactor
	name = "Circuit board (Fission Reactor Controller)"
	desc = "A circuit board for running a fission reactor."
	build_path = /obj/machinery/fissioncontroller
	board_type = MACHINE_REINFORCED
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=4"
	var/safety_disabled=FALSE
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen=1,
		/obj/item/stack/rods = 2,
	)

/obj/item/weapon/circuitboard/fission_reactor/solder_improve(mob/user)
	to_chat(user, "<span class='[safety_disabled ? "notice" : "warning"]'>You [safety_disabled ? "re" : "dis"]connect the auto-SCRAM fuse.</span>")
	safety_disabled = !safety_disabled
	
	
/obj/item/weapon/circuitboard/fission_reactor/finish_building(var/obj/machinery/new_machine,var/mob/user)
	var/obj/machinery/fissioncontroller/fc=new_machine
	fc.can_autoscram =!safety_disabled
/*

				else if(istype(circuit,/obj/item/weapon/circuitboard/fission_reactor))
					var/obj/machinery/computer/fissioncontroller/RC = B
					var/obj/item/weapon/circuitboard/fission_reactor/C = circuit
					RC.can_autoscram = !C.safety_disabled
*/