/*
in this file:
the machine which makes fuel reservoirs have things in them.
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
	var/reagent_wiki=null //stores a reagent id. if not null, displays some info instead of the regular ui.
	
/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/get_pipe_dir() //the atmos gods demand a sacrifice.
	return dir	

/obj/machinery/atmospherics/unary/fissionfuelmaker/New()
	..()
	src.buildFrom(usr,src)
	interface=new /datum/html_interface(src,"isotopic separational combiner",500,300,"<link rel='stylesheet' href='nanotrasen.css'>")	
	buildui()

/obj/machinery/atmospherics/unary/fissionfuelmaker/attackby(var/obj/item/I,var/mob/user)
	if(istype(I,/obj/item/weapon/fuelrod))
		if(heldrod)
			to_chat(user,"There's already a fuel reservoir inserted into \the [src].")
		else
			if(!user.drop_item(I))
				return
			to_chat(user,"You insert the fuel reservoir into \the [src].")
			I.forceMove(src)
			heldrod=I
			heldrod.fueldata.fuel=heldrod.fueldata.get_products() //process the fuel turning
			heldrod.fueldata.life=1
			heldrod.fueldata.rederive_stats()
			ask_remakeUI()
			playsound(src,'sound/items/crowbar.ogg',50)
			update_icon()
		return
	if(iscrowbar(I) && heldrod)
		user.visible_message("<span class='notice'>[user] starts prying the fuel reservoir out of \the [src].</span>", "<span class='notice'>You start prying the fuel reservoir out of \the [src].</span>")
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
		C.forceMove(src)
		container=C
		to_chat(user,"You add \the [C] to \the [src]")
		ask_remakeUI()
		return TRUE
		

	//..()


/obj/machinery/atmospherics/unary/fissionfuelmaker/attack_hand(mob/user)
	if(..())
		if(container)
			to_chat(user,"You remove \the [container] from \the [src]")
			container.forceMove(src.loc)
			container=null
			ask_remakeUI()
		return

	interface.show(user)
	register_asset("nanotrasen.css", 'code/modules/html_interface/nanotrasen/nanotrasen.css')
	send_asset(user, "nanotrasen.css")
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
					to_chat(hclient.client,"There's no fuel reservoir to eject.")
				else
					heldrod.forceMove(src.loc)
					heldrod.update_icon()
					heldrod=null
					update_icon()
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
		else if(href_list["dir"]=="goto_wiki")
			reagent_wiki=href_list["reagent"]
	if(href_list["dir"]=="exit_wiki")
		reagent_wiki=null
		
	
	ask_remakeUI()


/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/transfer_from_fuelrod(var/reagent_id,var/amount)
	if(!heldrod)
		return "no fuel reservoir"
	if(reagent_id==RADON || reagent_id=="RADON")
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
		return "no fuel reservoir"
	if(reagent_id==RADON || reagent_id=="RADON")
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
	for (var/client/C in interface.clients)
		if(C.mob && get_dist(C.mob.loc,src.loc)<=1)
			interface.show( interface._getClient(interface.clients[C]) ) 
		else
			interface.hide(interface._getClient(interface.clients[C]))


/obj/machinery/atmospherics/unary/fissionfuelmaker/proc/buildui()	
	var/html=""

	var/current_rodamt=0
	var/estimated_time=0
	var/estimated_power=0
	
	if(heldrod)
		for(var/datum/reagent/R  in heldrod.fueldata.fuel.reagent_list)
			current_rodamt+=R.volume
					
		estimated_time=floor(heldrod.fueldata.lifetime/60)
		if(heldrod.fueldata.absorbance>heldrod.fueldata.wattage)
			if(heldrod.fueldata.wattage>0)
				estimated_time/= (heldrod.fueldata.absorbance-heldrod.fueldata.wattage)/heldrod.fueldata.wattage
				estimated_time=floor(estimated_time)
			else
				estimated_time="never"
		else
			estimated_power=heldrod.fueldata.wattage - heldrod.fueldata.absorbance		
				
				
	if (reagent_wiki)
		var/datum/reagent/sample=chemical_reagents_list[reagent_wiki]
		var/byproducts="unknown"
		if(sample)
			var/list/prod=sample.irradiate()
			byproducts=""
			for(var/id in prod)
				var/datum/reagent/prd=chemical_reagents_list[id]
				if(prd)
					byproducts+="[prd.name]:&nbsp;[floor(prod[id]*100)]% "
				
		html={"<div style='margin-left:5px;margin-right:5px;'><br>
			<a href='?src=\ref[interface];dir=exit_wiki'>Return</a><br>
			
			<b>[sample ? sample.name : "unknown"]</b><br>
			
			<i>[sample? sample.description : "unable to identify reagent"]</i><br>
			<hr>
			Power: [sample? sample.fission_power - sample.fission_absorbtion : "?"] Watts<br>
			Lifespan: [sample? (sample.fission_time || "non-fissile") : "?"] [sample? (sample.fission_time!=null ? "Seconds" : "") : "Seconds"]<br>
			
			Products: [byproducts]
			
			
		</div>"}
	else
		var/producttext="none"
		if(heldrod)
			var/list/temp_list=new()
			producttext = heldrod.fueldata.fuel.reagent_list.len==0 ? "none" : ""
			var/high=0
			for(var/datum/reagent/R  in heldrod.fueldata.fuel.reagent_list)
				temp_list[R.id]=R.volume
				high=max(high,R.volume)
			if (high>0)
				for(var/i in temp_list)
					temp_list[i]/=high
			var/list/prods=new()		
			for(var/datum/reagent/R  in heldrod.fueldata.fuel.reagent_list)
				var/list/l=R.irradiate(temp_list)
				for(var/regid in l)
					prods[regid] = (prods[regid]==null ? 0 : prods[regid]) + l[regid]*R.volume
			for(var/i in prods)
				producttext+="[chemical_reagents_list[i]?.name ]:&nbsp;[prods[i]]&nbsp;units&emsp;"
				
		html={"<div style='margin-left:5px;margin-right:5px;'>
		<div >
		Baseline fuel lifespan: [estimated_time] minutes <br>
		Baseline heat generation: [floor(estimated_power)] Watts <br>
		<table><tr><td style='white-space: nowrap;'>Expected byproducts:&nbsp;</td><td>[producttext]</td></tr></table>
		</div>"}


		html+={"<hr> <table style='width:100%;'><tr><td> Fuel Reservoir: [ heldrod ? "[heldrod.name]  \[[current_rodamt]/[heldrod.units_of_storage]\]" : "none" ] <a href='?src=\ref[interface];action=eject_fuel'>Eject</a></td> <td style='text-align:right;'>Transfer To Container</td> </tr>"}
	
		if(heldrod)
			for(var/datum/reagent/R  in heldrod.fueldata.fuel.reagent_list)
				html+="<tr><td> [R.name] <a href='?src=\ref[interface];reagent=[R.id];dir=goto_wiki'>(?)</a> [R.volume] unit[R.volume!=1?"s":""] </td>"
				html+="<td style='text-align:right;'><a  <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=1'>1u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=5'>5u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=10'>10u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=25'>25u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=from_fuel;amount=999999'>All</a></td></tr>"


		html+={"</table><hr><table style='width:100%;'><tr><td>
Container: [container ? container : "none"][container ? " \[[container.reagents.total_volume]/[container.volume]\]" : ""] <a href='?src=\ref[interface];action=eject_cont'>Eject</a></td><td style='text-align:right;'> Transfer To Fuel Reservoir</td> </tr>"}

		if(container)
			for(var/datum/reagent/R in container.reagents.reagent_list)
				html+="<tr><td> [R.name] <a href='?src=\ref[interface];reagent=[R.id];dir=goto_wiki'>(?)</a> [R.volume] unit[R.volume!=1?"s":""] </td>"
				html+="<td style='text-align:right;'><a  <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=1'>1u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=5'>5u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=10'>10u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=25'>25u</a> <a href='?src=\ref[interface];reagent=[R.id];dir=to_fuel;amount=999999'>All</a></td></tr>"
		if(air_contents)
			if(air_contents.gas[GAS_RADON])
				html+="<tr><td> Radon <a href='?src=\ref[interface];reagent=RADON;dir=goto_wiki'>(?)</a> [air_contents.gas[GAS_RADON]] units </td>"
				html+="<td style='text-align:right;'><a  <a href='?src=\ref[interface];reagent=RADON;dir=to_fuel;amount=1'>1u</a> <a href='?src=\ref[interface];reagent=RADON;dir=to_fuel;amount=5'>5u</a> <a href='?src=\ref[interface];reagent=RADON;dir=to_fuel;amount=10'>10u</a> <a href='?src=\ref[interface];reagent=RADON;dir=to_fuel;amount=25'>25u</a> <a href='?src=\ref[interface];reagent=RADON;dir=to_fuel;amount=999999'>All</a></td></tr>"
	

	
		html+={"</table></div>"}


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
		to_chat(usr,"There is a fuel reservoir inserted into it.")
	else
		to_chat(usr,"The fuel reservoir receptacle is empty.")
		
		
		
		
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
	
	
