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


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/Destroy()
	if(associated_reactor)
		associated_reactor.handledestruction(src)
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


/obj/machinery/atmospherics/unary/fissionreactor_coolantport/New()
	..()
	src.buildFrom(usr,src)
	for(var/datum/fission_reactor_holder/r in fissionreactorlist)
		if(r.turf_in_reactor(src.loc))
			if(r.adopt_part(src))
				break

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
	var/datum/html_interface/interface
	var/lastupdatetick=0
	var/displaycoolantinmoles=FALSE
	var/tempdisplaymode=0

/obj/machinery/fissioncontroller/New()
	..()
	interface=new /datum/html_interface(src,"Fission reactor controller",590,340,"<link rel='stylesheet' href='fission.css'>")
	for(var/datum/fission_reactor_holder/r in fissionreactorlist)
		if(r.turf_in_reactor(src.loc))
			if(r.adopt_part(src))
				break
				
				
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
			to_chat(user,"There's already a fuel rod inserted into \the [src].")
		else
			var/obj/item/weapon/fuelrod/newrod=I
			if(!user.drop_item(newrod))
				return
			to_chat(user,"You insert the fuel rod into \the [src].")
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
				to_chat(user,"<span class='notice'>You're not sure it's safe to remove the fuel rod.</span>")
				return
			user.visible_message("<span class='warning'>[user] starts prying the fuel rod out of \the [src], even though the reactor is active!</span>", "<span class='warning'>You start prying the fuel rod out of \the [src], even though the reactor is active!</span>")
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
			associated_reactor=null
			return
		associated_reactor.init_parts()
		associated_reactor.controller=src
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
			estimatedtimeleft="DO:NE"
		else if(associated_reactor.fuel_rods_affected_by_rods==associated_reactor.fuel_rods.len && associated_reactor.control_rod_insertion>=1.0)
			estimatedtimeleft="HA:LT" //avoids a div by 0
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
			estimatedtimeleft="[mins]:[num2text(secs,2,10)]"
	else	
		estimatedtimeleft="NO:NE"

	var/rodinsertpercent= floor(associated_reactor.control_rod_target*100+0.5)

	var/status="operational"
	var/statuscolor="lime"
	if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP)
		status="danger"
		statuscolor="red"
	else if(!associated_reactor.fuel)
		status="no fuel"
		statuscolor="blue"
	else if(associated_reactor.fuel.life<=0)
		status="depleated"
		statuscolor="blue"
	else if (!associated_reactor.considered_on())
		status="standby"
	
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
	
	var/fueltxt="EJECT FUEL"
	if(associated_reactor.considered_on())
		fueltxt="FUEL LOCKED"
	else if (!associated_reactor.fuel)
		fueltxt="NO FUEL"
	
	var/coolant_tempdisplay="[associated_reactor.coolant.temperature]K"
	var/reactor_tempdisplay="[associated_reactor.temperature]K"
	if(tempdisplaymode==1) //C
		coolant_tempdisplay="[associated_reactor.coolant.temperature-273.15]°C"
		reactor_tempdisplay="[associated_reactor.temperature-273.15]°C"
	else if(tempdisplaymode==2) //F (because this is really old, outdated tech (fission is soooo last millenium))
		coolant_tempdisplay="[1.8*associated_reactor.coolant.temperature-459.67]°F"
		reactor_tempdisplay="[1.8*associated_reactor.temperature-459.67]°F"
	else if(tempdisplaymode==3) //R (because muh absolute scale)
		coolant_tempdisplay="[1.8*associated_reactor.coolant.temperature]R"
		reactor_tempdisplay="[1.8*associated_reactor.temperature]R"
	
	
	var/temp_suffix=""
	if(associated_reactor.temperature>FISSIONREACTOR_MELTDOWNTEMP)
		temp_suffix="_danger"
	else if(associated_reactor.temperature>FISSIONREACTOR_DANGERTEMP)
		temp_suffix="_caution"
		
	var/temp_suffix_C=""
	if(associated_reactor.coolant.temperature>FISSIONREACTOR_MELTDOWNTEMP)
		temp_suffix_C="_danger"
	else if(associated_reactor.coolant.temperature>FISSIONREACTOR_DANGERTEMP)
		temp_suffix_C="_caution"	
		
	
	aychteeemel_string={"<table style='width:100%;height:100%;'>
<tr>
<td style='width:90%;'>

	<table style='height:100%;width:97.5%'>
	<tr><td style='width:100%;text-align:center;'>
		<span class='bar_back' id='reactor_fuelbar_back'>
			<span class='bar_overlay' id='reactor_fuelbar_overlay' style='width:[fuelusepercent]%'>
				
			</span>
			<span style='position:relative;top:-1.5em;font-size:2em;font-weight:bold;color:black;text-shadow: 0px 0px 3px white;'>[fuelusepercent]% ([estimatedtimeleft])</span>
		</span>
		fuel life remaining
	</td></tr>
	
	<tr><td style='width:100%;text-align:center;'>
		<span class='bar_back' id='reactor_tempbar_back'>
			<span class='bar_overlay' id='reactor_tempbar_overlay[temp_suffix]'  style='width:[coretemppercent]%'>
				
			</span>
			<span style='position:relative;top:-1.5em;font-size:2em;font-weight:bold;color:black;text-shadow: 0px 0px 3px white;'>[reactor_tempdisplay]</span>
		</span>
		core temp <a href='?src=\ref[interface];action=swap_tempunit'><span class='button'>change unit</span></a>
	</td></tr>
	
	<tr><td style='width:100%;text-align:center;'>
		<span class='bar_back' id='reactor_coolantbar_back'>
			<span class='bar_overlay' id='reactor_coolantbar_overlay[temp_suffix_C]' style='width:[coolanttemppercent]%'>
				
			</span>
			<span style='position:relative;top:-1.5em;font-size:1.25em;font-weight:bold;color:black;text-shadow: 0px 0px 3px white;'>[coolant_tempdisplay] [displaycoolantinmoles? "& [associated_reactor.coolant.total_moles] moles" : "@ [associated_reactor.coolant.pressure]kPa"]</span> 
		</span> 
		coolant <a href='?src=\ref[interface];action=swap_gasunit'><span class='button'>[displaycoolantinmoles ? "in moles" : "in kPa"]</span></a>
	</td></tr> 

	<tr><td style='font-size:2em;font-weight:bold;text-align:center;'><span style='text-align:right;'>reactor status:<span> <span style='text-align:left;color:[statuscolor];'>[status]</span></td></tr>
	<tr><td><a href='?src=\ref[interface];action=eject'><span class='button[(associated_reactor.considered_on() || (!associated_reactor.fuel)) ? "_locked" : ""]' style='font-size:150%;font-weight:bold;'>[fueltxt]</span></a></td></tr>

	<tr><td style='font-size:125%;'><span style='width:50%;display:inline-block;text-align:left;'>fuel reactivity:[reactivity]%</span><span style='width:50%;display:inline-block;text-align:right'>fuel rods:[associated_reactor.fuel_rods.len]</span></td></tr>
	<tr><td style='font-size:125%;'><span style='width:50%;display:inline-block;text-align:left;'>fissile speed:[speed]%</span><span style='width:50%;display:inline-block;text-align:right;margin-bottom:1em;'>control rods:[associated_reactor.control_rods.len]</span></td></tr>
	</table>

</td>
<td>

	<table style='width:100%;height:100%;'>
	<tr><td style='text-align:center;'>
		
		<span class='fuelrod_text_bg' style='font-size:1.5em;border-bottom:none;'>control<br>rods</span>
		<a href='?src=\ref[interface];action=rods_up'><span class='reactor_controlrod_movebutton'>\[UP\]</span></a>
		<span id='fuelrod_gradient' style='width:100%;height:10em;display:block;'>
			<span style='background-color:#222;width:40%;height:[rodinsertpercent]%;display:block;position:relative;left:30%;'></span>
		</span>
		<a href='?src=\ref[interface];action=rods_down'><span class='reactor_controlrod_movebutton'>\[DN\]</span></a>
		<span class='fuelrod_text_bg' style='font-size:2em;border-top:none;'>[rodinsertpercent]%</span>
		
		
		
	</td></tr>
	<tr><td> <a href='?src=\ref[interface];action=SCRAM'><span id='reactor_scrambutton[associated_reactor.SCRAM ? "_on" : ""]'>SCRAM</span></a> </td></tr>
	</table>


</td>
</tr>
</table>"}
	
	interface.updateLayout(aychteeemel_string)
	

/obj/machinery/fissioncontroller/update_icon()
	icon_state="control"
	if(!powered())
		icon_state="control0"
	else if(stat & BROKEN)
		icon_state="controlb"
	else if(!associated_reactor)
		icon_state="control_noreactor"
	else if(associated_reactor.temperature>=FISSIONREACTOR_DANGERTEMP || associated_reactor.SCRAM)
		icon_state="control_danger"
	else if(!associated_reactor.fuel)
		icon_state="control_nofuel"
	else if(associated_reactor.fuel.life <=0)
		icon_state="control_depleted"
	else if(!associated_reactor.considered_on())
		icon_state="control_idle"
	

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
		to_chat(usr, "The readouts indicate there's no fuel rod inserted.")
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

/obj/machinery/fissioncontroller/process()
	update_icon()
	if(!associated_reactor) //no reactor? no processing to be done.
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
		return
	else
		poweroutagemsg=FALSE
	



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
				to_chat(hclient.client, "The reactor safety locks prevent the fuel rod from being ejected!")
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


/obj/structure/fission_reactor_case/Destroy()
	if(associated_reactor)
		associated_reactor.handledestruction(src)
	..()
	
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