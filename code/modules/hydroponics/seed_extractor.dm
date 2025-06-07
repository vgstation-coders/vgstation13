/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	light_range_on = 2
	light_color = LIGHT_COLOR_CYAN
	var/piles = list()

	var/min_seeds = 1 //better manipulators improve this
	var/max_seeds = 4 //better scanning modules improve this

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/seed_extractor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/seed_extractor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()
	update_icon()

/obj/machinery/seed_extractor/power_change()
	..()
	update_icon()

/obj/machinery/seed_extractor/RefreshParts()
	var/B=0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		B += (M.rating-1)*0.5
	min_seeds=1+B

	B=0
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		B += M.rating-1
	max_seeds=4+B

/obj/machinery/seed_extractor/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	// Emptying a plant bag
	if (istype(AM,/obj/item/weapon/storage/bag/plants))
		if(contents.len >= MAX_N_OF_ITEMS)
			return FALSE
		var/obj/item/weapon/storage/P = AM
		for(var/obj/item/seeds/G in P.contents)
			moveToStorage(G)
		return TRUE

	// Loading individual seeds into the machine
	if(istype(AM,/obj/item/seeds))
		if(contents.len >= MAX_N_OF_ITEMS)
			return FALSE
		moveToStorage(AM)
		updateUsrDialog()
		return TRUE

	//Grass. //Why isn't this using the nonplant_seed_type functionality?
	if(istype(AM, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = AM
		S.use(1)
		new /obj/item/seeds/grassseed(loc)
		return TRUE

	if(seedify(AM, src))
		return TRUE
	return FALSE

/obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)

	// Emptying a plant bag
	if (istype(O,/obj/item/weapon/storage/bag/plants))
		if (!hasSpaceCheck(user))
			return
		var/obj/item/weapon/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			++loaded
			moveToStorage(G)
			if(contents.len >= MAX_N_OF_ITEMS)
				to_chat(user, "<span class='notice'>You fill \the [src] to the brim.</span>")
				return
		if (loaded)
			to_chat(user, "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	// Loading individual seeds into the machine
	if(istype(O,/obj/item/seeds))
		if (!hasSpaceCheck(user))
			return
		user.drop_item(force_drop = 1)
		moveToStorage(O)
		to_chat(user, "<span class='notice'>You add [O] to [src.name].</span>")
		updateUsrDialog()
		return

	//Grass. //Why isn't this using the nonplant_seed_type functionality?
	if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		to_chat(user, "<span class='notice'>You extract some seeds from the [S.name].</span>")
		S.use(1)
		new /obj/item/seeds/grassseed(loc)
		return

	if(seedify(O, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds from [O].</span>")
		return

	..()

/obj/machinery/seed_extractor/update_icon()
	if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = "sextractor-off"
		kill_moody_light()
	else
		icon_state = "sextractor"
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_sextractor")

//Code shamelessly ported over and adapted from tgstation's github repo, PR #2973, credit to Kelenius for the original code
/datum/seed_pile //Maybe there's a better way to do this.
	var/datum/seed/seed
	var/amount

/datum/seed_pile/New(var/seed, var/amount = 1)
	src.seed = seed
	src.amount = amount

/obj/machinery/seed_extractor/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/seed_extractor/interact(mob/user as mob)
	if (stat)
		return 0

	user.set_machine(src)

	var/dat = list()

	dat += "<b>Stored seeds:</b><br>"

	if (contents.len == 0)
		dat += "<font color='red'>No seeds in storage!</font>"
	else
		dat += {"
<table cellpadding='3' style='text-align:center;'>
	<thead>
	<tr>
		<th>Name</th>
		<th>Lifespan</th>
		<th>Endurance</th>
		<th>Maturation</th>
		<th>Production</th>
		<th>Yield</th>
		<th>Potency</th>
		<th>Stock</th>
		<th>Notes (Mouseover for Info)</th>
	</tr>
	<tr>
		<th>
			<a href="?src=\ref[src];sortby=name_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=name_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=lifespan_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=lifespan_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=endurance_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=endurance_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=maturation_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=maturation_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=production_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=production_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=yield_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=yield_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=potency_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=potency_dsc">&darr;</a>
		</th>
		<th>
			<a href="?src=\ref[src];sortby=stock_asc">&uarr;</a>
			<a href="?src=\ref[src];sortby=stock_dsc">&darr;</a>
		</th>
	</tr>
	</thead>
	<tbody>
"}
		for (var/datum/seed_pile/P in piles)
			dat += {"
		<tr>
			<td>[P.seed.display_name][P.seed.roundstart ? "":" (#[P.seed.uid])"]</td>
			<td>[P.seed.lifespan]</td>
			<td>[P.seed.endurance]</td>
			<td>[P.seed.maturation]</td>
			<td>[P.seed.production]</td>
			<td>[P.seed.yield]</td>
			<td>[P.seed.potency]</td>
			<td>
			<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=1'>Vend</a>
			<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=5'>5x</a>
			<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=[P.amount]'>All</a>
			([P.amount] left)</td>
			<td>"}
			if(P.seed.biolum && P.seed.biolum_colour)
				dat += "<span title=\"This plant is bioluminescent.\" color=[P.seed.biolum_colour]>LUM </span>"
			switch(P.seed.spread)
				if(1)
					dat += "<span title=\"This plant is capable of growing beyond the confines of a tray.\">CREEP </span>"
				if(2)
					dat += "<span title=\"This plant is a robust and vigorous vine that will spread rapidly.\">VINE </span>"
			switch(P.seed.voracious)
				if(1)
					dat += "<span title=\"This plant is voracious and will eat tray pests and weeds for sustenance.\">VORA </span>"
				if(2)
					dat += "<span title=\"This plant is carnivorous and poses a significant threat to living things around it.\">CARN </span>"
			switch(P.seed.juicy)
				if(1)
					dat += "<span title=\"This plant's fruit is soft-skinned and abudantly juicy\">SPLAT </span>"
				if(2)
					dat += "<span title=\"This plant's fruit is excessively soft and juicy.\">SLIP </span>"
			if(P.seed.immutable > 0)
				dat += "<span title=\"This plant does not possess genetics that are alterable.\">NOMUT </span>"
			if(P.seed.hematophage)
				dat += "<span title=\"This plant is a highly specialized hematophage that will only draw nutrients from blood.\">BLOOD </span>"
			if(P.seed.alter_temp)
				dat += "<span title=\"This plant will gradually alter the local room temperature to match it's ideal habitat.\">TEMP </span>"
			if(P.seed.consume_gasses.len)
				dat += "<span title=\"This plant will consume gas from the environment.\">CGAS </span>"
			if(P.seed.gas_absorb)
				dat += "<span title=\"This plant will convert consumed gas to reagents.\">ABSOR </span>"
			if(P.seed.exude_gasses.len)
				dat += "<span title=\"This plant will exude gas into the environment.\">EGAS </span>"
			if(P.seed.thorny)
				dat += "<span title=\"This plant possesses a cover of sharp thorns.\">THORN </span>"
			if(P.seed.stinging)
				dat += "<span title=\"This plant possesses a cover of fine stingers capable of releasing chemicals on touch.\">STING </span>"
			if(P.seed.ligneous)
				dat += "<span title=\"This is a ligneous plant with strong and robust stems.\">WOOD </span>"
			if(P.seed.teleporting)
				dat += "<span title=\"This plant possesses a high degree of temporal/spatial instability and may cause spontaneous bluespace disruptions.\">TELE </span>"
			if(P.seed.toxin_affinity > 7)
				dat += "<span title=\"This plant can only survive in extremely toxic environments.\">HTOX </span>"
			else if(P.seed.toxin_affinity > 5)
				dat += "<span title=\"This plant requires a balanced toxin and water environment.\">TOX </span>"
			dat += "</td><tr>"
		dat += "</tbody></table>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "seed_ext", name, 1000, 400)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	var/static/list/sorting_methods = list(
		"name_asc" = /proc/cmp_seed_name_asc,
		"name_dsc" = /proc/cmp_seed_name_dsc,
		"lifespan_asc" = /proc/cmp_seed_lifespan_asc,
		"lifespan_dsc" = /proc/cmp_seed_lifespan_dsc,
		"endurance_asc" = /proc/cmp_seed_endurance_asc,
		"endurance_dsc" = /proc/cmp_seed_endurance_dsc,
		"maturation_asc" = /proc/cmp_seed_maturation_asc,
		"maturation_dsc" = /proc/cmp_seed_maturation_dsc,
		"production_asc" = /proc/cmp_seed_production_asc,
		"production_dsc" = /proc/cmp_seed_production_dsc,
		"yield_asc" = /proc/cmp_seed_yield_asc,
		"yield_dsc" = /proc/cmp_seed_yield_dsc,
		"potency_asc" = /proc/cmp_seed_potency_asc,
		"potency_dsc" = /proc/cmp_seed_potency_dsc,
		"stock_asc" = /proc/cmp_seed_stock_asc,
		"stock_dsc" = /proc/cmp_seed_stock_dsc,
	)

	var/sortby = href_list["sortby"]
	if(sortby && (sortby in sorting_methods))
		sortTim(piles, sorting_methods[sortby])
		updateUsrDialog()
		return

	if("amt" in href_list)
		var/amt = text2num(href_list["amt"])
		var/datum/seed/S = SSplant.seeds[href_list["seed"]]

		for(var/datum/seed_pile/P in piles)
			if(P.seed == S)
				if(P.amount <= 0)
					return
				P.amount -= amt
				if (P.amount <= 0)
					piles -= P
					qdel(P)
				break

		for (var/obj/item/seeds/O in contents) //Now we find the seed we need to vend
			if(O.seed == S)
				O.forceMove(src.loc)
				amt--
				if (amt <= 0)
					break

		updateUsrDialog()
		return

/obj/machinery/seed_extractor/proc/moveToStorage(var/obj/item/seeds/O as obj)
	if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.forceMove(src)

	for(var/datum/seed_pile/P in piles)
		if(P.seed == O.seed)
			P.amount++
			return
	piles += new /datum/seed_pile(O.seed)

/obj/machinery/seed_extractor/proc/hasSpaceCheck(mob/user as mob)
	if(contents.len >= MAX_N_OF_ITEMS)
		to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		return 0
	else
		return 1

/proc/cmp_seed_name_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return sorttext(b.seed.name, a.seed.name)
/proc/cmp_seed_name_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return sorttext(a.seed.name, b.seed.name)

/proc/cmp_seed_lifespan_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.lifespan - b.seed.lifespan
/proc/cmp_seed_lifespan_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.lifespan - a.seed.lifespan

/proc/cmp_seed_endurance_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.endurance - b.seed.endurance
/proc/cmp_seed_endurance_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.endurance - a.seed.endurance

/proc/cmp_seed_maturation_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.maturation - b.seed.maturation
/proc/cmp_seed_maturation_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.maturation - a.seed.maturation

/proc/cmp_seed_production_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.production - b.seed.production
/proc/cmp_seed_production_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.production - a.seed.production

/proc/cmp_seed_yield_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.yield - b.seed.yield
/proc/cmp_seed_yield_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.yield - a.seed.yield

/proc/cmp_seed_potency_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.seed.potency - b.seed.potency
/proc/cmp_seed_potency_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.seed.potency - a.seed.potency

/proc/cmp_seed_stock_asc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return a.amount - b.amount
/proc/cmp_seed_stock_dsc(var/datum/seed_pile/a, var/datum/seed_pile/b)
	return b.amount - a.amount
