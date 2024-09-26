/*
in this file:
the machine which makes fuel rods have things in them.
*/

//because radon is a gas, we need to interface with gasses. yeah, this kind of sucks, but what are you gonna do? (inb4 make better code lol)
/obj/machinery/atmospherics/unary/fissionfuelmaker
	name="isotopic separational combiner" //just about the most technobable you could get.
	var/datum/reagents/held_elements=new /datum/reagents
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 200
	anchored=1
	density=1
	active_power_usage = 1000
	icon='icons/obj/fissionreactor/fuelmaker.dmi'
	icon_state="fuelmaker"
	var/hatchopen=FALSE
	var/obj/item/weapon/fuelrod/heldrod = null
	var/obj/item/weapon/reagent_containers/container=null
	var/datum/html_interface/interface
	var/pipename="isotopic separational combiner"
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/get_pipe_dir() //the atmos gods demand a sacrifice.
	return dir	

/obj/machinery/atmospherics/unary/fissionfuelmaker/New()
	..()
	src.buildFrom(usr,src)
	interface=new /datum/html_interface(src,"isotopic separational combiner",550,500,"<link rel='stylesheet' href='fission.css'>")	
	buildui()

/obj/machinery/atmospherics/unary/fissionfuelmaker/attackby(var/obj/item/I,var/mob/user)
	if(istype(I,/obj/item/weapon/fuelrod))
		if(heldrod)
			to_chat(user,"There's already a fuel rod inserted into \the [src].")
		else
			if(!user.drop_item(I))
				return
			to_chat(user,"You insert the fuel rod into \the [src].")
			I.loc=null
			heldrod=I
			heldrod.fueldata.fuel=heldrod.fueldata.get_products() //process the fuel turning
			heldrod.fueldata.life=1
			heldrod.fueldata.rederive_stats()
			ask_remakeUI()
			playsound(src,'sound/items/crowbar.ogg',50)
			update_icon()
		return
	if(iscrowbar(I) && heldrod)
		user.visible_message("<span class='notice'>[user] starts prying the fuel rod out of \the [src].</span>", "<span class='notice'>You start prying the fuel rod out of \the [src].</span>")
		playsound(src,'sound/items/crowbar.ogg',50)
		if(do_after(user, src,20))
			heldrod.forceMove(loc)
			heldrod=null
			ask_remakeUI()
			playsound(src,'sound/machines/door_unbolt.ogg',50)
		update_icon()
		return
		
	if(I.is_screwdriver(user))
		I.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] [hatchopen ? "closes" : "opens"] the maintenance hatch of the [src].</span>", "<span class='notice'>You [hatchopen ? "close" : "open"] the maintenance hatch of the [src].</span>")	
		hatchopen=!hatchopen
	if(iscrowbar(I))
		I.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] starts prying the electronics out of \the [src].</span>", "<span class='notice'>You start prying the electronics out of \the [src].</span>")
		if(do_after(user, src, 30 ))
			user.visible_message("<span class='warning'>[user] pries the electronics out of \the [src]</span>","<span class='notice'>You pry the electronics out of \the [src].</span>")
			var/obj/machinery/constructable_frame/machine_frame/newframe= new /obj/machinery/constructable_frame/machine_frame(loc)
			newframe.set_build_state(3)
			newframe.forceMove(loc)
			newframe.circuit= new /obj/item/weapon/circuitboard/fission_fuelmaker
			newframe.components+=new /obj/item/weapon/stock_parts/console_screen
			newframe.components+=new /obj/item/weapon/stock_parts/manipulator
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			newframe.components+=new /obj/item/weapon/stock_parts/matter_bin
			newframe.components+=new /obj/item/weapon/stock_parts/scanning_module
			newframe.components+=new /obj/item/weapon/stock_parts/scanning_module
			qdel(src)
	if( istype(I,/obj/item/weapon/reagent_containers) )
		var/obj/item/weapon/reagent_containers/C=I
		if(container)
			to_chat(user,"There's already a container inside of \the [src].")
			return TRUE
		if(!user.drop_item(C))
			return
		C.forceMove(null)
		container=C
		to_chat(user,"You add \the [C] to \the [src]")
		ask_remakeUI()
		return TRUE
		

	//..()


/obj/machinery/atmospherics/unary/fissionfuelmaker/attack_hand(mob/user)
	if(..())
		if(container)
			to_chat(user,"You remove \the [container] from \the [src]")
			container.loc=src.loc
			container=null
			ask_remakeUI()
		return

	interface.show(user)
	register_asset("fission.css", 'code/modules/fissionreactor/fission.css')
	send_asset(user, "fission.css")
	register_asset("uiBg.png", 'code/modules/html_interface/nanotrasen/uiBg.png')
	send_asset(user, "uiBg.png")
	
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/Topic(var/href, var/list/href_list , var/datum/html_interface_client/hclient)
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
	
	if(href_list["action"])
		switch(href_list["action"])
			if("eject_fuel")	
				if(!heldrod)
					to_chat(hclient.client,"There's no fuel rod to eject.")
				else
					heldrod.forceMove(src.loc)
					heldrod.update_icon()
					heldrod=null
			if("eject_cont")
				if(!container)
					to_chat(hclient.client,"There's no container to eject.")
				else
					container.forceMove(src.loc)
					container.update_icon()
					container=null
					
	if(href_list["reagent"])
		if(href_list["dir"]=="to_fuel")
			var/error=transfer_to_fuelrod( href_list["reagent"] , text2num(href_list["amount"]) || 0 )
			if(error)
				to_chat(hclient.client,"could not transfer reagent: [error]!")
		else if(href_list["dir"]=="from_fuel")
			var/error=transfer_from_fuelrod( href_list["reagent"] , text2num(href_list["amount"]) || 0 )
			if(error)
				to_chat(hclient.client,"could not transfer reagent: [error]!")
		
	
	ask_remakeUI()


/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/transfer_from_fuelrod(var/reagent_id,var/amount)
	if(!heldrod)
		return "no fuel rod"
	if(reagent_id==RADON)
		if(air_contents)
			var/actually_taken=heldrod.fueldata.take_shit_from(reagent_id,amount ,heldrod.fueldata.fuel)
			if(!air_contents.gas[GAS_RADON])
				air_contents.gas[GAS_RADON]=0
			air_contents.gas[GAS_RADON]+=actually_taken
			air_contents.update_values()	
			if(network)
				network.update=1
		return
	if(!container)
		return "no container"
		
	amount=min(amount,container.volume-container.reagents.total_volume)
	
	var/actually_taken=heldrod.fueldata.take_shit_from(reagent_id,amount ,heldrod.fueldata.fuel)
	
	container.reagents.add_reagent(reagent_id, actually_taken)

/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/transfer_to_fuelrod(var/reagent_id,var/amount)
	if(!heldrod)
		return "no fuel rod"
	if(reagent_id==RADON)
		if(air_contents)
			var/avalible_gas=air_contents.gas[GAS_RADON] || 0 
			amount=min(amount,avalible_gas,heldrod.units_of_storage-heldrod.fueldata.fuel.total_volume)
			air_contents.gas[GAS_RADON]= max(0,avalible_gas-amount)
			heldrod.fueldata.add_shit_to(reagent_id,amount ,heldrod.fueldata.fuel)
			air_contents.update_values()	
			if(network)
				network.update=1
		return
	if(!container)
		return "no container"
	amount=min(amount,heldrod.units_of_storage-heldrod.fueldata.fuel.total_volume,container.reagents.amount_cache[reagent_id] || 0)
	
	heldrod.fueldata.add_shit_to(reagent_id,amount ,heldrod.fueldata.fuel)

	container.reagents.remove_reagent(reagent_id, amount, TRUE)

/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/ask_remakeUI()
	buildui()
	for (var/client in interface.clients)
		interface.show( interface._getClient(interface.clients[client]) )

/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/buildui()	
	var/html=""

	var/current_rodamt=0
	var/rodpercent=0
	var/estimated_time=0
	var/estimated_power=0
	
	var/list/allreagentlists=list() //stores the reagents of both, at least the id, which is the important one
	
	if(container)
		for(var/datum/reagent/R in container.reagents.reagent_list)
			allreagentlists+=R
	
	if(heldrod)
		for(var/datum/reagent/R  in heldrod.fueldata.fuel.reagent_list)
			var/add=TRUE
			for(var/datum/reagent/R2 in allreagentlists)
				if(R2.id==R.id)
					add=FALSE
					break
			if(add)
				allreagentlists+=R
			current_rodamt+=R.volume
				
		rodpercent=current_rodamt/heldrod.units_of_storage
		rodpercent=floor(rodpercent*100+0.5)
		
		estimated_time=heldrod.fueldata.lifetime
		if(heldrod.fueldata.absorbance>heldrod.fueldata.wattage)
			if(heldrod.fueldata.wattage>0)
				estimated_time/= (heldrod.fueldata.absorbance-heldrod.fueldata.wattage)/heldrod.fueldata.wattage
			else
				estimated_time="NEVER"
		else
			estimated_power=heldrod.fueldata.wattage - heldrod.fueldata.absorbance		
				
				

	if(air_contents)

		var/add=TRUE
		for(var/datum/reagent/R  in allreagentlists)
			if(R.id==RADON)
				add=FALSE
				break

		if(add && air_contents.gas[GAS_RADON])
			var/datum/reagent/radon_to_add = new /datum/reagent
			radon_to_add.volume=air_contents.gas[GAS_RADON] || 0
			radon_to_add.id=RADON  
			radon_to_add.name="Radon"
			allreagentlists+=radon_to_add

	
	html={"<table style='width:100%;height:100%;'>
<tr><td>

<div id='fuelbar'>

<span id='fuelbar_overlay' style='width:[rodpercent]%'></span> <!--apply storage left in the width percentage-->

<span id='fuelbar_text'>[ heldrod ? "[current_rodamt]/[heldrod.units_of_storage]" : "NO FUEL ROD" ]</span>

</div>

</td></tr>
<tr><td>

<div class='fuelstats'>
Baseline fuel lifespan: <i>[floor(estimated_time/60)] minutes </i><br>
Baseline heat generation: <i>[floor(estimated_power)] Watts</i>
</div>

</td></tr>
<tr><td>
<br>
<a href='?src=\ref[interface];action=eject_fuel'><span class='button[heldrod ? "" : "_locked"]'>Eject fuel rod</span></a>
<br><br>
</td></tr>



<tr><td>

<span style='width:100%;height:5px;background-color:#ccc;display:inline-block;margin-bottom:1em;'> </span>

<span style='font-size:115%;'>current container: [container ? container : "NONE"] <a href='?src=\ref[interface];action=eject_cont'><span class='button[container ? "" : "_locked"]'>EJECT</span></a><br>
[container? container.reagents.total_volume : 0]/[ container? container.volume : 0] units</span>
<br><br>

</td></tr>
<tr><td>

<table id='fuellisting' style='width:100%;text-align:center;line-height:200%;'>
	<tr style='font-size:125%;'>
		<th>material</th>
		<th>to add</th>
		<th>available</th>
	</tr>"}
	
	var/list/sortedlist=list()
	
	for(var/i=1,i<=allreagentlists.len,i++) //bad performance scaling, but it shouldn't matter *too* much given the circumstances.
		var/datum/reagent/R=allreagentlists[i]
		var/spot=sortedlist.len+1
		for(var/i2=1,i2<=sortedlist.len,i2++)
			var/datum/reagent/R2 =sortedlist[i2]
			if(sorttext(R.name,R2.name)==1)
				spot=i2
				break
		sortedlist.Insert(spot,R)	
	
	for(var/datum/reagent/R in sortedlist)
		var/avalibstr="[container ? (container.reagents.amount_cache[R.id] || 0) : 0]"
		if (R.id==RADON)
			avalibstr=air_contents.gas[GAS_RADON] || 0
		html+={"	<tr style='font-size:90%;'>
			<td>[R.name]</td>
			<td style='white-space:nowrap;'>  <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=25'><span class='button'>---</span></a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=5'><span class='button'>--</span></a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=1'><span class='button'>-</span></a> [heldrod ? (heldrod.fueldata.fuel.amount_cache[R.id] || 0) : 0] <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=1'><span class='button'>+</span></a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=5'><span class='button'>++</span></a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=25'><span class='button'>+++</span></a> </td>
			<td>[avalibstr]</td>
			<tr>"}
	
	
	html+={"</table>

</td></tr>
</table>"}


	interface.updateLayout(html)

/obj/machinery/atmospherics/unary/fissionfuelmaker/process() //because atmos fuckery, we have to periodically update it.
	ask_remakeUI()
	..()

/obj/machinery/atmospherics/unary/fissionfuelmaker/update_icon()
	..()
	if(!powered())
		icon_state="fuelmaker_off[heldrod?"_insert":""]"
	else if(stat & BROKEN)
		icon_state="fuelmaker_broken[heldrod?"_insert":""]"
	else
		icon_state="fuelmaker[heldrod?"_insert":""]"
	
	
	
	
	
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/examine()
	..()
	to_chat(usr,"The maintenance hatch is [hatchopen ? "open" : "closed"]. It's affixed by some screws.")
	if(hatchopen)
		to_chat(usr,"It looks like you could pry out the electronics.")
	if(heldrod)
		to_chat(usr,"There is a fuel rod inserted into it.")
	else
		to_chat(usr,"The fuel rod receptacle is empty.")
		
		
		
		
/obj/item/weapon/circuitboard/fission_fuelmaker
	name = "Circuit board (isotopic separational combiner)"
	desc = "A circuit board for combining various isotopes together, as well as separating them."
	build_path = /obj/machinery/atmospherics/unary/fissionfuelmaker
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=4"
	var/safety_disabled=FALSE
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen=1,
	)
	
	
