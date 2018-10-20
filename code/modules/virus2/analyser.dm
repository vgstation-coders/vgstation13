/obj/machinery/disease2/diseaseanalyser
	name = "disease analyser"
	desc = "For analysing and storing viral samples."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = TRUE
	density = TRUE
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

	var/scanning = 0
	var/pause = 0
	var/process_time = 5
	var/minimum_growth = 50
	var/list/toscan = new //List of samples to analyse
	var/obj/item/weapon/virusdish/dish = null //Repurposed to mean 'dish currently being analysed'

/obj/machinery/disease2/diseaseanalyser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/diseaseanalyser,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
	)

	RefreshParts()

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	var/scancount = 0
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module))
			scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	minimum_growth = round((initial(minimum_growth) - (scancount * 3)))
	process_time = round((initial(process_time) - lasercount))

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	. = ..()
	if(.)
		return
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		var/obj/item/weapon/virusdish/D = I

		if(!c.drop_item(D, src))
			return 1

		if(!D.analysed)
			if(!dish)
				dish = D
			else
				toscan += D

		visible_message("<span class='notice'>[user.name] inserts the [D.name] in the [src.name].</span>")
		src.updateUsrDialog()

/obj/machinery/disease2/diseaseanalyser/proc/PrintPaper(var/obj/item/weapon/virusdish/D)
	var/obj/item/weapon/paper/P = new(src.loc)
	P.info = D.virus2.get_info()
	P.name = "Virus #[D.virus2.uniqueID]"
	visible_message("\The [src.name] prints a sheet of paper.")

/obj/machinery/disease2/diseaseanalyser/proc/Analyse(var/obj/item/weapon/virusdish/D)
	dish.info = D.virus2.get_info()
	dish.analysed = 1
	if (D.virus2.addToDB())
		say("Added new pathogen to database.")
	dish.forceMove(src.loc)
	dish = null
	icon_state = "analyser"
	src.updateUsrDialog()

/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			Analyse(dish)
	else if((dish || toscan.len > 0) && !scanning && !pause)
		if(!dish)
			dish = toscan[1] //Load next dish to analyse
			toscan -= dish //Remove from scanlist
		if(dish.virus2 && dish.growth > minimum_growth)
			dish.growth -= 10
			scanning = process_time
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.forceMove(src.loc)
				dish = null
				alert_noise("buzz")
				pause = 0

/obj/machinery/disease2/diseaseanalyser/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["close"])
		usr << browse(null, "\ref[src]")
		usr.unset_machine()
		return 1

	usr.set_machine(src)
	if(href_list["eject"])
		var/obj/item/weapon/virusdish/O = locate(href_list["dishI"])
		if(O && O in contents)
			O.forceMove(loc)
			if(O in toscan)
				toscan -= O
		src.updateUsrDialog()
	else if(href_list["print"])
		var/obj/item/weapon/virusdish/O = locate(href_list["dishI"])
		if(O && O in contents)
			PrintPaper(O)

/obj/machinery/disease2/diseaseanalyser/attack_hand(var/mob/user as mob)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/dat = list()
	dat += "Currently stored samples: [src.contents.len]<br><hr>"
	if (src.contents.len > 0)
		dat += {"
<table cellpadding='1' style='width: 100%;text-align:center; white-space: nowrap;'>
	<td>Name</td>
	<td>Details</td>
	<td>Symptoms</td>
	<td>Antibodies</td>
	<td>Transmission</td>
	<td>Options</td>
"}
		for(var/obj/item/weapon/virusdish/B in src.contents)
			var/ID = B.virus2.uniqueID
			if("[ID]" in virusDB) //If it's in the DB they might have given it a name
				var/datum/data/record/v = virusDB["[ID]"]
				dat += "<tr><td>[v.fields["name"]]</td>"
			else //Use ID instead
				dat += "<tr><td>[B.virus2.name()]</td>"
			dat += "<td>Infection rate: [B.virus2.infectionchance]<br>Progress speed: [B.virus2.stageprob]</td>"
			dat+="<td>"
			if(!B.analysed)
				dat += "Awaiting analysis.</td><td></td><td></td>"
			else
				for(var/datum/disease2/effect/e in B.virus2.effects)
					dat += "<br>[e.name] (Strength: [e.multiplier] | Verosity: [e.chance])"
				dat +="</td>"
				dat += "<td>[antigens2string(B.virus2.antigen)]</td>"
				dat += "<td>[(B.virus2.spreadtype)]</td>"
			if(B == dish)
				dat += "<td></td>"
			else
				dat += "<td><A href='?src=\ref[src];eject=1;dishI=\ref[B];'>Eject</a>"
				dat += "<br>[B.analysed ? "<A href='?src=\ref[src];print=1;dishI=\ref[B];'>Print</a>" : ""]</td>"
			dat += "</tr>"
		dat += "</table>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "\ref[src]", "Viral Storage & Analysis Unit", 800, 350, src)
	popup.set_content(dat)
	popup.open()
