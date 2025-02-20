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
	icon_state="case"
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


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/Destroy()
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	var/origloc=loc
	for(var/obj/structure/fission_reactor_case/part in range(src,1) )
		loc=null
		part.update_icon()
	loc=origloc
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(src,1) )
		loc=null
		part.update_icon()			
	..()

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
			var/obj/structure/girder/reactor/newcase= new /obj/structure/girder/reactor(loc)
			newcase.forceMove(loc)
			newcase.pipeadded=TRUE
			newcase.state=3
			qdel(src)
			
/obj/machinery/atmospherics/unary/fissionreactor_coolantport/update_icon()
	var/dirs=0
	overlays=list()
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, WEST) )
		dirs|=WEST
		
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, WEST) )
		dirs|=WEST	
		
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, WEST) )
		dirs|=WEST	
		
	overlays+=image(icon, src,"coonantpipeoverlay")	
	icon_state="case_[dirs]"

/obj/machinery/atmospherics/unary/fissionreactor_coolantport/New()
	..()
	src.buildFrom(usr,src)
	for(var/datum/fission_reactor_holder/r in fissionreactorlist)
		if(r.turf_in_reactor(src.loc))
			if(r.adopt_part(src))
				break
	for(var/obj/structure/fission_reactor_case/part in range(src,1) )
		part.update_icon()
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(src,1) )
		part.update_icon()	
		
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
		
		
/obj/machinery/atmospherics/unary/fissionreactor_coolantport/ex_act(var/severity, var/child=null, var/mob/whodunnit)
	switch(severity)
		if(1) //dev
			if(rand()>0.1) //90% chance to destroy
				qdel(src)
		if(2) //heavy
			if(rand()<0.25) //25% chance to destroy
				qdel(src)
		if(3) //light
			return
	
	


/obj/machinery/fissioncontroller
	name="fission reactor controller"
	icon='icons/obj/fissionreactor/reactorcase.dmi' // 'icons/obj/fissionreactor/controller.dmi'
	icon_state="case" // "control_noreactor"
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
	var/datum/html_interface/interface
	var/lastupdatetick=0
	var/displaycoolantinmoles=FALSE
	var/tempdisplaymode=0
	var/list/temperature_history[]
	var/max_temp_history=15 // every 2 seconds will plot it. how many points on the graph.

/obj/machinery/fissioncontroller/New()
	..()
	var/tl[max_temp_history]
	temperature_history=tl
	for(var/i=1, i<=max_temp_history,i++)
		temperature_history[i]=20.0 //default it to 20K at all points
	
	interface=new /datum/html_interface(src,"Fission reactor controller",500,290,"<link rel='stylesheet' href='fission.css'>")
	for(var/datum/fission_reactor_holder/r in fissionreactorlist)
		if(r.turf_in_reactor(src.loc))
			if(r.adopt_part(src))
				break
	update_icon()
	for(var/obj/structure/fission_reactor_case/part in range(src,1) )
		part.update_icon()
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(src,1) )
		part.update_icon()	
				
				
/obj/machinery/fissioncontroller/Destroy()
	if(currentfuelrod)
		currentfuelrod.forceMove(loc)
		currentfuelrod=null
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	qdel(interface)
	if(associated_reactor && associated_reactor.fuel && associated_reactor.considered_on())
		var/rads= associated_reactor.fuel_rods.len*((associated_reactor.fuel_reactivity) - ( (associated_reactor.fuel_reactivity-associated_reactor.fuel_reactivity_with_rods)*associated_reactor.control_rod_insertion))*associated_reactor.fuel.wattage/25000
		for(var/mob/living/l in range(src.loc, 5))
			l.apply_radiation(rads, RAD_EXTERNAL)
	..()

/*/proc/playsound(var/atom/source, soundin, vol as num, vary = 0, extrarange as num, falloff, var/gas_modified = 1, var/channel = 0,var/wait = FALSE, var/frequency = 0)*/

/obj/machinery/fissioncontroller/attackby(var/obj/I,var/mob/user)
	if(istype(I,/obj/item/weapon/fuelrod))
		if(currentfuelrod)
			to_chat(user,"There's already a fuel reservoir inserted into \the [src].")
		else
			var/obj/item/weapon/fuelrod/newrod=I
			if(!user.drop_item(newrod))
				return
			to_chat(user,"You insert the fuel reservoir into \the [src].")
			if(powered() && !(stat&BROKEN))
				playsound(src,'sound/machines/fission/rc_fuelnone.ogg',50)
			newrod.loc=null
			currentfuelrod=newrod
			playsound(src,'sound/items/crowbar.ogg',50)
			associated_reactor?.fuel=newrod.fueldata
		return
	if(iscrowbar(I) && currentfuelrod)
		if(associated_reactor?.considered_on())
			if(user.a_intent==I_HELP) //spreading rads is in fact not very helpful
				to_chat(user,"<span class='notice'>You're not sure it's safe to remove the fuel reservoir.</span>")
				return
			user.visible_message("<span class='warning'>[user] starts prying the fuel reservoir out of \the [src], even though the reactor is active!</span>", "<span class='warning'>You start prying the fuel reservoir out of \the [src], even though the reactor is active!</span>")
			playsound(src,'sound/items/crowbar.ogg',50)
			if(do_after(user, src,30))
				currentfuelrod.forceMove(loc)
				currentfuelrod=null
				playsound(src,'sound/machines/door_unbolt.ogg',50)
				if(associated_reactor && associated_reactor.fuel && associated_reactor.considered_on())
					var/rads= associated_reactor.fuel_rods.len*((associated_reactor.fuel_reactivity) - ( (associated_reactor.fuel_reactivity-associated_reactor.fuel_reactivity_with_rods)*associated_reactor.control_rod_insertion))*associated_reactor.fuel.wattage/25000
					for(var/mob/living/l in range(src.loc, 5))
						l.apply_radiation(rads, RAD_EXTERNAL)
				associated_reactor?.fuel=null

			return
				
		user.visible_message("<span class='notice'>[user] starts prying the fuel reservoir out of \the [src].</span>", "<span class='notice'>You start prying the fuel reservoir out of \the [src].</span>")
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
			var/obj/machinery/constructable_frame/machine_frame/reinforced/newframe= new /obj/machinery/constructable_frame/machine_frame/reinforced(loc)
			newframe.forceMove(loc)
			//newframe.build_state=3
			newframe.set_build_state(3)
			newframe.circuit= new /obj/item/weapon/circuitboard/fission_reactor
			newframe.components=list()
			newframe.components+= new /obj/item/stack/rods(null,2)
			newframe.components+=new /obj/item/weapon/stock_parts/console_screen
			newframe.components+=new /obj/item/weapon/stock_parts/manipulator
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			newframe.components+=new /obj/item/weapon/stock_parts/scanning_module
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
			qdel(associated_reactor)
			associated_reactor=null
			return
		associated_reactor.init_parts()
		associated_reactor.controller=src
		if(!associated_reactor.verify_integrity())
			say("Failed to setup reactor: construction validation error", class = "binaryradio")
			associated_reactor=null
			return
		if(currentfuelrod)
			associated_reactor.fuel=currentfuelrod.fueldata
		say("Reactor setup success.", class = "binaryradio")
		update_icon()
	interface.show(user)
	register_asset("fission.css", 'code/modules/fissionreactor/fission.css')
	send_asset(user, "fission.css")
	register_asset("uiBg.png", 'code/modules/html_interface/nanotrasen/uiBg.png')
	send_asset(user, "uiBg.png")
	
	
	
/obj/machinery/fissioncontroller/proc/buildui()
	var/aychteeemel_string=""
	if(!associated_reactor)
		interface.updateLayout("<h1>NO REACTOR</h1>")
		return 
		
	var/fuelusepercent=associated_reactor.fuel? floor(associated_reactor.fuel.life*100+0.5) : 0
	var/estimatedtimeleft =""
	if(associated_reactor.fuel)
		if(associated_reactor.fuel.life<=0)
			estimatedtimeleft="Expired"
		else if(associated_reactor.fuel_rods_affected_by_rods==associated_reactor.fuel_rods.len && associated_reactor.control_rod_insertion>=1.0)
			estimatedtimeleft="Halted" //avoids a div by 0
		else
			var/secs=associated_reactor.fuel.lifetime
			secs/=associated_reactor.fuel_rods.len - (associated_reactor.fuel_rods_affected_by_rods*associated_reactor.control_rod_insertion)
			secs *= associated_reactor.fuel.life
			secs=floor(secs)
			var/mins=floor(secs/60)
			secs%=60
			//if(mins>99)
			//	mins=99
			//	secs=99
			estimatedtimeleft="[mins]m [secs]s"
	else	
		estimatedtimeleft="None"

	var/rodtargettpercent= floor(associated_reactor.control_rod_target*100+0.5)
	var/rodinsertpercent= floor(associated_reactor.control_rod_insertion*100+0.5)


	var/status="<span class='status_ok'>OKAY</span>"
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP)
		status="<span class='status_danger'>[associated_reactor.temperature>=FISSIONREACTOR_MELTDOWNTEMP ? "RUN" : "DANGER"]</span>"
	else if(!associated_reactor.fuel)
		status="<span class='status_nofuel'>No Fuel</span>"
	else if(associated_reactor.fuel.life<=0)
		status="<span class='status_done'>Depleated</span>"
	else if (!associated_reactor.considered_on())
		status="<span class='status_halt'>Standby</span>"
	
	var/coretemppercent= associated_reactor.temperature / FISSIONREACTOR_MELTDOWNTEMP
	coretemppercent=max(min(coretemppercent,1),0)
	coretemppercent=floor(coretemppercent*100+0.5)
	var/coolanttemppercent=associated_reactor.coolant.temperature / FISSIONREACTOR_MELTDOWNTEMP
	coolanttemppercent=max(min(coolanttemppercent,1),0)
	coolanttemppercent=floor(coolanttemppercent*100+0.5)
	
	var/reactivity=associated_reactor.fuel_rods.len*((associated_reactor.fuel_reactivity) - ( (associated_reactor.fuel_reactivity-associated_reactor.fuel_reactivity_with_rods)*associated_reactor.control_rod_insertion))
	reactivity=floor(reactivity*100+0.5)
	var/speed=associated_reactor.fuel_rods.len - (associated_reactor.fuel_rods_affected_by_rods*associated_reactor.control_rod_insertion)
	speed=floor(speed*100+0.5)
	

	var/highesttemp=0.0
	var/graphstring=""
	for(var/i=1,i<=temperature_history.len,i++)
		highesttemp=max(highesttemp,temperature_history[i])
		var y=(1.0-( (temperature_history[i] || 20.0) /FISSIONREACTOR_MELTDOWNTEMP))*100
		var x=(1.0-((i-1)/(temperature_history.len-1)))*350
		graphstring+=i==1 ? "M[x] [y]" : "L[x] [y]"
	
	
	
	var/coolant_tempdisplay="[floor(associated_reactor.coolant.temperature)]K"
	var/reactor_tempdisplay="[floor(associated_reactor.temperature)]K"
	var/reactor_highesttempdisplay="[floor(highesttemp)]K"
	if(tempdisplaymode==1) //C
		coolant_tempdisplay="[floor(associated_reactor.coolant.temperature-273.15)]°C"
		reactor_tempdisplay="[floor(associated_reactor.temperature-273.15)]°C"
		reactor_highesttempdisplay="[floor(highesttemp-273.15)]°C"
	else if(tempdisplaymode==2) //F (because this is really old, outdated tech (fission is soooo last millenium))
		coolant_tempdisplay="[floor(1.8*associated_reactor.coolant.temperature-459.67)]°F"
		reactor_tempdisplay="[floor(1.8*associated_reactor.temperature-459.67)]°F"
		reactor_highesttempdisplay="[floor(1.8*highesttemp-459.67)]°F"
	else if(tempdisplaymode==3) //R (because muh absolute scale)
		coolant_tempdisplay="[floor(1.8*associated_reactor.coolant.temperature)]R"
		reactor_tempdisplay="[floor(1.8*associated_reactor.temperature)]R"
		reactor_highesttempdisplay="[floor(1.8*highesttemp)]R"
		
	
	aychteeemel_string={"<table style='border-collapse:initial;'>
<tr><td style='vertical-align:top;'>

<div style='width:350px;'>
<div>
<svg id='TempGraph' width=350 height=100>
	

	<path d='M0 82 L350 82' style='stroke:#077;'/>
	<path d='M0 18 L350 18' style='stroke:#700;'/>
	
	
	<path d='M0 [100*(1-highesttemp/FISSIONREACTOR_MELTDOWNTEMP)] L350 [100*(1-highesttemp/FISSIONREACTOR_MELTDOWNTEMP)]' style='stroke:#770;'> </path>
	
	<path d='[graphstring]'> </path>
	
	<path d='M0 0 L350 0 L350 100 L0 100 Z' style='stroke:#777;stroke-width:4px;'/>
</svg>
</div>


<div style="display:inline-block;width:100%;">
<span style="width:50%;display:inline-block;">Temperature:&nbsp;[coolant_tempdisplay]</span><span style="width:50%;display:inline-block;text-align:right;">Recent Peak:&nbsp;[reactor_highesttempdisplay]</span>
<span style="width:50%;display:inline-block;">Coolant:&nbsp;[reactor_tempdisplay]</span><span style="width:50%;display:inline-block;text-align:right;">[displaycoolantinmoles ? "[associated_reactor.coolant.total_moles]mol" : "[associated_reactor.coolant.pressure]kPa" ]</span>
</div>

<br>
<br>

<div style="display:inline-block;width:100%;">
<span style="width:50%;display:inline-block;">Fuel Life:&nbsp;[fuelusepercent]%</span><span style="width:50%;display:inline-block;text-align:right;">Reactivity:&nbsp;[reactivity]%</span>
<span style="width:50%;display:inline-block;">Est. Time:&nbsp;[estimatedtimeleft]</span><span style="width:50%;display:inline-block;text-align:right;">Fissile Rate:[speed]%</span>
<span style="width:50%;display:inline-block;">Status:&nbsp;[status]</span><span style="width:50%;display:inline-block;text-align:right;">Fuel: [associated_reactor.fuel_rods.len]&nbsp;&nbsp;Ctrl:[associated_reactor.control_rods.len]</span>
</div>

<br>
<br>

<div style='display:inline-block;width:100%;'>
<a href='?src=\ref[interface];action=eject' [(!associated_reactor.fuel ||  associated_reactor.considered_on()) ? "class='blocked'" : ""]>\[EJECT FUEL\]</a>&nbsp;&nbsp;<a href='?src=\ref[interface];action=swap_tempunit'>\[TEMPERATURE\]</a>&nbsp;&nbsp;&nbsp;<a href='?src=\ref[interface];action=rods_up'>\[RODS UP\]</a> <br>
&nbsp;<a href='?src=\ref[interface];action=SCRAM' id='scram' style='[associated_reactor.SCRAM ? "animation-name:scramon;" : "" ]'>\[&nbsp;SCRAM&nbsp;]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='?src=\ref[interface];action=swap_gasunit'>\[COOLANT\]</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href='?src=\ref[interface];action=rods_down'>\[RODS DOWN\]</a>
</div>

</div>


</td><td style='vertical-align:top;'>

<div style='width:120px;'>
<div style='margin-left:10px;'>
<svg id='ControlRods' width=100 height=200>
	<rect x='28' y='0' width='43' height='[associated_reactor.control_rod_target*200]' fill='#070'/>
	<rect x='33' y='0' width='33' height='[associated_reactor.control_rod_insertion*200]' fill='#0f0'/>
	
	<path d='M0 0 L100 0 L100 200 L0 200 Z' style='stroke:#777;stroke-width:4px;'/>
</svg>
</div>


<div>
&nbsp;Control Rods<br>
<span>Insertion:</span><span style="text-align:right;float:right;">[rodinsertpercent]%</span>
<span>Target:</span><span style="text-align:right;float:right;">[rodtargettpercent]%</span>
</div>


</div>

</td></tr>
</table>"}
	
	interface.updateLayout(aychteeemel_string)
	

/obj/machinery/fissioncontroller/update_icon()
	overlays=null
	var/dirs=0
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, WEST) )
		dirs|=WEST
		
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, WEST) )
		dirs|=WEST	
		
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, WEST) )
		dirs|=WEST	
		
	icon_state="case_[dirs]"
	



	var/overlay_icon="control"
	if(!powered())
		overlay_icon="control0"
	else if(stat & BROKEN)
		overlay_icon="controlb"
	else if(!associated_reactor)
		overlay_icon="control_noreactor"
	else if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP || associated_reactor.SCRAM)
		overlay_icon="control_danger"
	else if(!associated_reactor.fuel)
		overlay_icon="control_nofuel"
	else if(associated_reactor.fuel.life <=0)
		overlay_icon="control_depleted"
	else if(!associated_reactor.considered_on())
		overlay_icon="control_idle"
	overlays+=image('icons/obj/fissionreactor/controller.dmi', src,overlay_icon)

/obj/machinery/fissioncontroller/examine()
	..()
	to_chat(usr, "It's held together tightly, you'll have to cut the metal to take it apart.")
	if(!powered())
		to_chat(usr, "The power is off. You should plug it in. Soon.")
		return
	if(stat & BROKEN)
		to_chat(usr, "The screen is broken. You should fix it soon.")
		return
	
	if(!associated_reactor)
		to_chat(usr, "The readouts indicate there's no linked reactor.")
		return

	if(associated_reactor.SCRAM)
		to_chat(usr, "<span class='warning'>The readouts indicate that the SCRAM protocol has been activated.</span>")
	
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP)
		to_chat(usr, "<span class='warning'>The readouts indicate that the reactor is overheated, and that you should cool it down.</span>")
	
	if(!associated_reactor.fuel)
		to_chat(usr, "The readouts indicate there's no fuel reservoir inserted.")
	else
		if(associated_reactor.fuel.life <=0)
			to_chat(usr, "The readouts indicate that the fuel is depleted.")
		else
			if(associated_reactor.considered_on())
				to_chat(usr, "The readouts indicate that the reactor is operating normally.")
			else
				to_chat(usr, "The readouts indicate that the reactor is shut down.")
			to_chat(usr, "The fuel reads out [floor(associated_reactor.fuel.life*100+0.5)]% life remaining")
	to_chat(usr, "The temperature reads out [associated_reactor.temperature]K")



/obj/machinery/fissioncontroller/proc/ask_remakeUI(var/forced=FALSE)
	if(lastupdatetick==world.time && !forced)
		return
	buildui()
	for (var/client/C in interface.clients)
		if(C.mob && get_dist(C.mob.loc,src.loc)<=1)
			interface.show( interface._getClient(interface.clients[C]) ) //"There's probably shenanigans" - dilt. yes there are.
		else
			interface.hide(interface._getClient(interface.clients[C]))
	lastupdatetick=world.time

/obj/machinery/fissioncontroller/proc/add_history_temp(var/temp=20.0)
	temperature_history.Insert(1,temp)
	temperature_history.len=max_temp_history
	
/obj/machinery/fissioncontroller/process()
	update_icon()
	if(!associated_reactor) //no reactor? no processing to be done.
		add_history_temp()
		return	
		
	ask_remakeUI(TRUE)
		

	
	associated_reactor.update_all_icos()
	//associated_reactor.coolantcycle()
	if(!powered()) //with my last breath, i curse zoidberg!
		if(!poweroutagemsg)
			poweroutagemsg=TRUE
			if(can_autoscram)
				say("Reactor lost power, engaging SCRAM.", class = "binaryradio")
				playsound(src,'sound/machines/fission/rc_scram.ogg',50)
				associated_reactor.SCRAM=TRUE
		add_history_temp()		
		return
	else
		poweroutagemsg=FALSE
	
	add_history_temp(associated_reactor.temperature)


	if(associated_reactor.fuel?.life<=0)
		if(!fueldepletedmsg)
			say("Reactor fuel depleted.", class = "binaryradio")
			playsound(src,'sound/machines/fission/rc_fuelnone.ogg',50)
		fueldepletedmsg=TRUE
	else
		fueldepletedmsg=FALSE
	
	
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP && can_autoscram && !associated_reactor.SCRAM )
		say("critical temperature reached, engaging SCRAM.", class = "binaryradio")
		playsound(src,'sound/machines/fission/rc_scram.ogg',50)
		associated_reactor.SCRAM=TRUE
	
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP && associated_reactor.temperature>lasttempnag )
		if(associated_reactor.temperature>=FISSIONREACTOR_MELTDOWNTEMP)
			say("Reactor at critical temperature: [associated_reactor.temperature]K. Evacuate immediately.", class = "binaryradio")
			playsound(src,'sound/machines/fission/rc_scram.ogg',50,0,10) //lots of extra range because shit is about to go down to hit the fan town.
		else
			say("Reactor at dangerous temperature: [associated_reactor.temperature]K", class = "binaryradio")
			playsound(src,'sound/machines/fission/rc_alert.ogg',50)

	lasttempnag=associated_reactor.temperature
	
	if(associated_reactor.fuel?.life<=0) //no fuel or depleated? no reactions to be done.
		return


/obj/machinery/fissioncontroller/Topic(var/href, var/list/href_list , var/datum/html_interface_client/hclient )	
	if(!associated_reactor)
		return
	if(!powered())
		return
	if(stat & BROKEN)
		return
	if(!canGhostWrite(usr,src,"",0))
		if(usr.restrained() || usr.lying || usr.stat)
			return 1
		if (!usr.dexterity_check())
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1
		if(!is_on_same_z(usr))
			to_chat(usr, "<span class='warning'>WARNING: Unable to interface with \the [src.name].</span>")
			return 1
		if(!is_in_range(usr))
			to_chat(usr, "<span class='warning'>WARNING: Connection failure. Reduce range.</span>")
			return 1
	
	
	
	switch(href_list["action"])
		if("SCRAM")
			if(!associated_reactor.SCRAM)
				playsound(src,'sound/machines/fission/rc_scram.ogg',50)
			associated_reactor.SCRAM=TRUE
		if("rods_up")
			associated_reactor.control_rod_target-=0.05
			associated_reactor.control_rod_target=max(0,associated_reactor.control_rod_target)
		if("rods_down")
			associated_reactor.control_rod_target+=0.05
			associated_reactor.control_rod_target=min(1,associated_reactor.control_rod_target)
		if("eject")
			if(!associated_reactor.fuel)
				to_chat(hclient.client, "There's no fuel to eject!")
				return
			if(associated_reactor.considered_on())
				to_chat(hclient.client, "The reactor safety locks prevent the fuel reservoir from being ejected!")
				return
			currentfuelrod.forceMove(src.loc)
			currentfuelrod=null	
			associated_reactor.fuel=null
		if("swap_tempunit")	
			tempdisplaymode++
			tempdisplaymode%=4
		if("swap_gasunit")		
			displaycoolantinmoles=!displaycoolantinmoles
			
	ask_remakeUI() //update it so that changes appear NOW.
//SS_WAIT_MACHINERY

/obj/machinery/fissioncontroller/ex_act(var/severity, var/child=null, var/mob/whodunnit)
	switch(severity)
		if(1) //dev
			if(rand()>0.1) //90% chance to destroy
				qdel(src)
		if(2) //heavy
			if(rand()<0.25) //25% chance to destroy
				qdel(src)
		if(3) //light
			return





/obj/structure/fission_reactor_case
	var/datum/fission_reactor_holder/associated_reactor=null
	density =1
	anchored =1
	name="fission reactor casing"
	icon='icons/obj/fissionreactor/reactorcase.dmi'
	icon_state="case"

/obj/structure/fission_reactor_case/New()
	for(var/datum/fission_reactor_holder/r in fissionreactorlist)
		if(r.turf_in_reactor(src.loc))
			if(r.adopt_part(src))
				break
	for(var/obj/structure/fission_reactor_case/part in range(src,1) )
		part.update_icon()
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(src,1) )
		part.update_icon()	
	
/obj/structure/fission_reactor_case/Destroy()
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	var/origloc=loc
	for(var/obj/structure/fission_reactor_case/part in range(src,1) )
		loc=null
		part.update_icon()
	loc=origloc
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(src,1) )
		loc=null
		part.update_icon()	
	..()

	
/obj/structure/fission_reactor_case/update_icon()
	var/dirs=0
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/structure/fission_reactor_case) in get_step(src, WEST) )
		dirs|=WEST
		
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/atmospherics/unary/fissionreactor_coolantport) in get_step(src, WEST) )
		dirs|=WEST	
		
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, NORTH) )
		dirs|=NORTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, SOUTH) )
		dirs|=SOUTH
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, EAST) )
		dirs|=EAST
	if(  locate(/obj/machinery/fissioncontroller) in get_step(src, WEST) )
		dirs|=WEST	
		
	icon_state="case_[dirs]"
	
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
			var/obj/structure/girder/reactor/newcase= new /obj/structure/girder/reactor(loc)
			newcase.forceMove(loc)
			newcase.state=3
			qdel(src)


/obj/structure/fission_reactor_case/ex_act(var/severity, var/child=null, var/mob/whodunnit)
	switch(severity)
		if(1) //dev
			if(rand()>0.1) //90% chance to destroy
				qdel(src)
		if(2) //heavy
			if(rand()<0.25) //25% chance to destroy
				qdel(src)
		if(3) //light
			return



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
					dirstr="south"
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
				var/obj/item/pipe/np= new /obj/item/pipe(loc)
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
						var/obj/structure/fission_reactor_case/newcase= new /obj/structure/fission_reactor_case(loc)
						newcase.forceMove(loc)
						newcase.dir=src.dir
					else
						var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/newcase= new /obj/machinery/atmospherics/unary/fissionreactor_coolantport(loc)
						newcase.dir=src.dir
						newcase.initialize_directions=src.dir
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
	sheet_type= /obj/item/stack/sheet/plasteel
	required_circuit_type=MACHINE_REINFORCED


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
