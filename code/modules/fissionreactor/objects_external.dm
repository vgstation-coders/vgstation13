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

/obj/machinery/atmospherics/unary/fissionreactor_coolantport/examine()
	..()
	if(associated_reactor && associated_reactor.considered_on())
		to_chat(usr,"the outer plating looks like it could be cut,<span class='danger'> but it seems like a <u>really</u> bad idea.</span>")
	else
		to_chat(usr,"the outer plating looks like it could be cut.")


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/attackby(var/obj/I,var/mob/user)
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
				newcase.loc=src.loc
				newcase.pipeadded=TRUE
				newcase.state=3



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
	icon='icons/obj/fissionreactor/controller.dmi'
	icon_state="control_noreactor"
	idle_power_usage = 500
	active_power_usage = 500
	circuit=/obj/item/weapon/circuitboard/fisson_reactor
	var/can_autoscram=TRUE //automatic safeties if it gets too hot or power is cut.
	var/datum/fission_reactor_holder/associated_reactor=null
	var/obj/item/weapon/fuelrod/currentfuelrod=null
	var/poweroutagemsg=FALSE

/*/proc/playsound(var/atom/source, soundin, vol as num, vary = 0, extrarange as num, falloff, var/gas_modified = 1, var/channel = 0,var/wait = FALSE, var/frequency = 0)*/

/obj/machinery/computer/fissioncontroller/attackby(var/obj/I,var/mob/user)
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
			if(associated_reactor)
				associated_reactor.fuel=newrod.fueldata
		return
	if(iscrowbar(I) && currentfuelrod)
		if(associated_reactor && associated_reactor.considered_on())
			if(user.a_intent==I_HELP) //spreading rads is in fact not very helpful
				to_chat(user,"<span class='notice'>You're not sure it's safe to remove the fuel rod.</span>")
				return
			user.visible_message("<span class='warning'>[user] starts prying the fuel rod out of \the [src], even though the reactor is active!</span>", "<span class='warning'>You start prying the fuel rod out of \the [src], even though the reactor is active!</span>")
			playsound(src,'sound/items/crowbar.ogg',50)
			if(do_after(user, src,30))
				currentfuelrod.loc=src.loc
				currentfuelrod=null
				playsound(src,'sound/machines/door_unbolt.ogg',50)
				if(associated_reactor)
					associated_reactor.fuel=null
				//TODO: SPREAD RADS
			return
				
		user.visible_message("<span class='notice'>[user] starts prying the fuel rod out of \the [src].</span>", "<span class='notice'>You start prying the fuel rod out of \the [src].</span>")
		playsound(src,'sound/items/crowbar.ogg',50)
		if(do_after(user, src,20))
			currentfuelrod.loc=src.loc
			currentfuelrod=null
			playsound(src,'sound/machines/door_unbolt.ogg',50)
			if(associated_reactor)
				associated_reactor.fuel=null
		return
	..()

/obj/machinery/computer/fissioncontroller/attack_hand(mob/user)
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
		if(currentfuelrod)
			associated_reactor.fuel=currentfuelrod.fueldata
		say("Reactor setup success.", class = "binaryradio")
		update_icon()
	

/obj/machinery/computer/fissioncontroller/update_icon()
	if(!powered())
		icon_state="control0"
		return
	if(stat & BROKEN)
		icon_state="controlb"
		return
	if(!associated_reactor)
		icon_state="control_noreactor"
		return
	if(!associated_reactor.fuel)
		icon_state="control_nofuel"
		return
	if(associated_reactor.fuel.life <=0)
		icon_state="control_depleted"
		return
	if(associated_reactor.temperature>=4500)
		icon_state="control_danger"
		return
	if(!associated_reactor.considered_on())
		icon_state="control_idle"
		return
	icon_state="control"

/obj/machinery/computer/fissioncontroller/examine()
	..()
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

/obj/machinery/computer/fissioncontroller/set_broken()
	if(..())
		if(can_autoscram)
			associated_reactor.SCRAM=TRUE
			say("Reactor controller electrical fault detected, engaging SCRAM.", class = "binaryradio")
			return TRUE
	return FALSE
	
/obj/machinery/computer/fissioncontroller/process()
	update_icon()
	if(!associated_reactor) //no reactor? no processing to be done.
		return	
		
	associated_reactor.update_all_icos()
	associated_reactor.coolantcycle()
	if(!powered()) //with my last breath, i curse zoidberg!
		if(!poweroutagemsg)
			poweroutagemsg=TRUE
			if(can_autoscram)
				say("Reactor lost power, engaging SCRAM.", class = "binaryradio")
				associated_reactor.SCRAM=TRUE
	else
		poweroutagemsg=FALSE
		
	if(!associated_reactor.fuel) //no fuel? no reactions to be done.
		return
	if(associated_reactor.fuel.life<=0) //fuel depleted? no reactions to be done.
		return

	associated_reactor.fissioncycle()
	
	if(associated_reactor.fuel.life<=0)
		say("Reactor fuel depleted.", class = "binaryradio")
	
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP)
		if(associated_reactor.temperature>=FISSIONREACTOR_MELTDOWNTEMP)
			say("Reactor at critical temperature: [associated_reactor.temperature]K. Evacuate immediately.", class = "binaryradio")
			if(can_autoscram && !associated_reactor.SCRAM )
				say("critical temperature reached, engaging SCRAM.", class = "binaryradio")
				associated_reactor.SCRAM=TRUE
		else
			say("Reactor at dangerous temperature: [associated_reactor.temperature]K", class = "binaryradio")
	
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
	if(associated_reactor && associated_reactor.considered_on())
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
				newcase.loc=src.loc
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
				if(P.pipe_type==0)
					to_chat(user, "<span class='notice'>This isn't the right pipe to use!</span>")	
					return
				pipeadded=TRUE
			if(pipeadded && W.is_wrench(user))
				W.playtoolsound(src, 100)	
				to_chat(user, "<span class='notice'>You remove the piping from \the [src]</span>")	
				var/obj/item/pipe/np= new /obj/item/pipe
				np.loc=src.loc
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

