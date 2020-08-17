/********************
* Track orders made by centcomm
*
* Used for the new cargo system
*********************/
var/global/current_centcomm_order_id=124901

/datum/centcomm_order
	var/id = 0 // Some bullshit ID we use for fluff.
	var/name = "Central Command" // Name of the ordering entity. Fluff.
	var/datum/money_account/acct // account we pay to
	var/acct_by_string = ""
	var/silent = 0

	// Amount decided upon
	var/worth = 0

	var/must_be_in_crate = 1

	var/extra_requirements = ""

	// /type = amount
	var/list/requested=list()
	var/list/fulfilled=list()

	var/list/name_override=list()

	var/weight = 1

/datum/centcomm_order/New()
	..()
	id = current_centcomm_order_id++

	if (acct_by_string)
		acct = department_accounts[acct_by_string]
	else
		acct = station_account
		acct_by_string = station_name()

/datum/centcomm_order/proc/ExtraChecks(var/atom/movable/AM)
	return 1

/datum/centcomm_order/proc/CheckShuttleObject(var/obj/O, var/in_crate)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(O.type in requested)
		var/amount = 1
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			amount = S.amount
		if(!(O.type in fulfilled))
			fulfilled[O.type] = 0
		// Don't claim stuff that other orders may want.
		if(fulfilled[O.type] == requested[O.type])
			return 0
		if (!ExtraChecks(O))
			return 0
		fulfilled[O.type] += amount
		qdel(O)
		return 1
	return 0

/datum/centcomm_order/proc/CheckFulfilled(var/obj/O, var/in_crate)
	for(var/typepath in requested)
		if(!(typepath in fulfilled) || fulfilled[typepath] < requested[typepath])
			return FALSE
	score["stuffshipped"]++
	return TRUE

/datum/centcomm_order/proc/Pay(var/complete = TRUE)
	acct.charge(-worth,null,"Payment for order #[id]",dest_name = name)

/datum/centcomm_order/proc/getRequestsByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in requested)
		if(!path)
			continue
		var/atom_name
		if (path in name_override)
			atom_name = name_override[path]
		else
			var/atom/movable/AM = path
			atom_name = initial(AM.name)
		var/amount = "[requested[path]]"
		if (requested[path]==INFINITY)
			amount = "Just keep it comin'"
		if(html_format)
			manifest += "<li>[atom_name], amount: [amount]</li>"
		else
			manifest += "[atom_name], amount: [amount]"
	if(html_format)
		manifest += "</ul>"
		if (extra_requirements)
			if(html_format)
				manifest += "<i>[extra_requirements]</i><br>"
	return manifest

/datum/centcomm_order/proc/getFulfilledByName(var/html_format = 0)
	var/manifest = ""
	if(html_format)
		manifest = "<ul>"
	for(var/path in fulfilled)
		if(!path)
			continue
		var/atom_name
		if (path in name_override)
			atom_name = name_override[path]
		else
			var/atom/movable/AM = path
			atom_name = initial(AM.name)
		if(html_format)
			manifest += "<li>[atom_name], amount: [fulfilled[path]]</li>"
		else
			manifest += "[atom_name], amount: [fulfilled[path]]"
	if(html_format)
		manifest += "</ul>"
	return manifest

/datum/centcomm_order/proc/OnPostUnload()
	return

// These run *last*.
/datum/centcomm_order/per_unit
	var/list/unit_prices = list()
	var/left_to_check = list()
	var/toPay = 0


/datum/centcomm_order/per_unit/Pay(var/complete = TRUE)
	if(toPay)
		if(complete)
			acct.charge(-toPay,null,"Complete payment for per-unit order #[id]",dest_name = name)
			score["stuffshipped"]++
		else
			acct.charge(-toPay,null,"Partial payment for per-unit order #[id]",dest_name = name)
		toPay = 0

// Same as normal, but will take every last bit of what you provided.
/datum/centcomm_order/per_unit/CheckShuttleObject(var/obj/O, var/in_crate)
	if(must_be_in_crate && !in_crate)
		return 0
	if(!O)
		return 0
	if(O.type in requested)
		var/amount = 1
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			amount = S.amount
		if(!(O.type in left_to_check))
			left_to_check[O.type]=0
		if (!ExtraChecks(O))
			return 0
		left_to_check[O.type] += amount
		qdel(O)
		return 1
	return 0

/datum/centcomm_order/per_unit/CheckFulfilled()
	var/toPay = 0
	for(var/typepath in left_to_check)
		var/worth_per_unit = unit_prices[typepath]
		var/amount         = left_to_check[typepath]
		toPay += amount * worth_per_unit
		if(requested[typepath] != INFINITY)
			requested[typepath] = max(0,requested[typepath] - left_to_check[typepath])
		if(!(typepath in fulfilled))
			fulfilled[typepath] = 0
		fulfilled[typepath] += left_to_check[typepath]
		left_to_check[typepath] = 0
	. = ..()
	Pay(.)

//////////////////////////////////////////////
// ORDERS START HERE
//////////////////////////////////////////////

/datum/centcomm_order/per_unit/plasma//Centcom always wants plasma
	name = "Nanotrasen"
	worth = "1$ per sheet"
	silent = 1//so we don't hear the announcement at every round start
	requested = list(
		/obj/item/stack/sheet/mineral/plasma = INFINITY
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/plasma = 1
	)

/datum/centcomm_order/per_unit/plasma/CheckShuttleObject(var/obj/O, var/in_crate)
	if(!in_crate)
		return 0
	if(!O)
		return 0
	if(istype(O, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = O
		if(!(O.type in left_to_check))
			left_to_check[O.type] = 0
		left_to_check[O.type] += P.amount
		score["plasmashipped"] += P.amount
		qdel(O)
		return 1
	return 0


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            MINING ORDERS                                                 //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//6 orders

/datum/centcomm_order/per_unit/department/cargo
	name = "Nanotrasen Industries Inc."
	acct_by_string = "Cargo"

/datum/centcomm_order/per_unit/department/cargo/diamonds/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/diamond = 50
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/diamond = VALUE_DIAMOND+3
	)
	worth = "[VALUE_DIAMOND+3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/uranium/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/uranium = 50
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/uranium = VALUE_URANIUM*3
	)
	worth = "[VALUE_URANIUM*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/gold/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/gold = 50
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/gold = VALUE_GOLD*3
	)
	worth = "[VALUE_GOLD*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/silver/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/silver = 50
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/silver = VALUE_SILVER*3
	)
	worth = "[VALUE_SILVER*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/phazon/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/phazon = 10
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/phazon = VALUE_PHAZON*3
	)
	worth = "[VALUE_PHAZON*3]$ per sheet"

/datum/centcomm_order/per_unit/department/cargo/clown/New()
	..()
	requested = list(
		/obj/item/stack/sheet/mineral/clown = 10
	)
	unit_prices=list(
		/obj/item/stack/sheet/mineral/clown = VALUE_CLOWN*3
	)
	worth = "[VALUE_CLOWN*3]$ per sheet"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            SCIENCE ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//30 orders

/datum/centcomm_order/department/science
	acct_by_string = "Science"

//--------------------------------------------R&D stuff----------------------------------------------------


/datum/centcomm_order/department/science/technology
	var/required_tech
	var/required_level
	var/tech

//Technology Data Disk, with a set tech and level required
/datum/centcomm_order/department/science/technology/New()
	..()
	name = "Nanotrasen R&D"
	tech = rand(1,4)
	switch(tech)
		if (1)
			required_tech = /datum/tech/materials
			required_level = 8
		if (2)
			required_tech =  /datum/tech/bluespace
			required_level = 4
		if (3)
			required_tech =  /datum/tech/combat
			required_level = 5
		if (4)
			required_tech =  /datum/tech/magnets
			required_level = 5
	requested = list(
		/obj/item/weapon/disk/tech_disk = 1
	)
	name_override = list(
		/obj/item/weapon/disk/tech_disk = "Technology Data Disk"
	)
	var/datum/tech/DT = required_tech
	extra_requirements = "tech required: [initial(DT.name)] (Level [required_level])"
	worth = 750

/datum/centcomm_order/department/science/technology/ExtraChecks(var/obj/item/weapon/disk/tech_disk/TD)
	if (!istype(TD))
		return 0
	if (istype(TD.stored, required_tech))
		var/datum/tech/DT = TD.stored
		if (DT.level >= required_level)
			return 1
	return 0


//Component Design Disk, with a set blueprint required
/datum/centcomm_order/department/science/design
	var/required_comp
	var/comp

/datum/centcomm_order/department/science/design/New()
	..()
	name = "Nanotrasen R&D"
	var/comp = rand(1,5)
	switch(comp)
		if (1)
			required_comp = /datum/design/rad_cell
			worth = 800
		if (2)
			required_comp = /datum/design/night_vision_goggles
			worth = 500
		if (3)
			required_comp = /datum/design/plasmabeaker
			worth = 500
		if (4)
			required_comp = /datum/design/bag_holding
			worth = 700
		if (5)
			required_comp = /datum/design/gravitywell
			worth = 1000
	requested = list(
		/obj/item/weapon/disk/design_disk = 1
	)
	name_override = list(
		/obj/item/weapon/disk/design_disk = "Component Design Disk"
	)
	var/obj/item/I = required_comp
	extra_requirements = "blueprint required: [initial(I.name)]"

/datum/centcomm_order/department/science/design/ExtraChecks(var/obj/item/weapon/disk/design_disk/DD)
	if (!istype(DD))
		return 0
	if (istype(DD.blueprint, required_comp))
		return 1
	return 0

//Protolathe orders
/datum/centcomm_order/department/science/nuclear_gun/New()
	..()
	name = "CentComm's ERT"
	requested = list(
		/obj/item/weapon/gun/energy/gun/nuclear = rand(1,5)
	)
	worth = 750*requested[requested[1]]

/datum/centcomm_order/department/science/plasmacutter/New()
	..()
	requested = list(
		/obj/item/weapon/pickaxe/plasmacutter/accelerator = rand(1,5)
	)
	worth = 500*requested[requested[1]]

/datum/centcomm_order/department/science/lasercannon/New()
	..()
	requested = list(
		/obj/item/weapon/gun/energy/laser/cannon = rand(1,5)
	)
	worth = 500*requested[requested[1]]

/datum/centcomm_order/department/science/assaultrifle/New()
	..()
	requested = list(
		/obj/item/weapon/gun/projectile/automatic/xcom = rand(1,5)
	)
	worth = 500*requested[requested[1]]

//Circuit Printer orders
/datum/centcomm_order/department/science/long_range_ai_upload/New()
	..()
	requested = list(
		/obj/item/weapon/circuitboard/aiupload/longrange = 1
	)
	worth = 500

/datum/centcomm_order/department/science/supermatter_board/New()
	..()
	requested = list(
		/obj/item/weapon/circuitboard/supermatter = 1
	)
	worth = 500

/datum/centcomm_order/department/science/telestation/New()
	..()
	requested = list(
		/obj/item/weapon/circuitboard/telestation = 1
	)
	worth = 500

/datum/centcomm_order/department/science/rust_core/New()
	..()
	requested = list(
		/obj/item/weapon/circuitboard/rust_core = 1
	)
	worth = 500


//----------------------------------------------Robotics----------------------------------------------------

//So that means we either let cargo pilot the mechas and trust that they're not gonna steal them
//Or have the roboticist pilot them all the way to the supply shuttle
//We should find some other way to displace mechas later

/datum/centcomm_order/department/science/phazon/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/combat/phazon = 1
	)
	worth = 1200

/datum/centcomm_order/department/science/phazon/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/durand/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/combat/durand = 1
	)
	worth = 900

/datum/centcomm_order/department/science/durand/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/gygax/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/combat/gygax = 1
	)
	worth = 700

/datum/centcomm_order/department/science/gygax/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/odysseus/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/medical/odysseus = 1
	)
	worth = 600

/datum/centcomm_order/department/science/odysseus/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/ripley/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/working/ripley = 1
	)
	worth = 500

/datum/centcomm_order/department/science/ripley/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/clarke/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/mecha/working/clarke = 1
	)
	worth = 500

/datum/centcomm_order/department/science/clarke/ExtraChecks(var/obj/mecha/M)
	if (!istype(M))
		return 0
	M.wreckage = null
	return 1

/datum/centcomm_order/department/science/robot/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/robot_parts/robot_suit = 1
	)
	name_override = list(
		/obj/item/robot_parts/robot_suit = "Assembled Robot Chassis"
	)
	extra_requirements = "A robot endoskeleton with arms, legs, head and torso assembled."
	worth = 500

/datum/centcomm_order/department/science/robot/ExtraChecks(var/obj/item/robot_parts/robot_suit/RS)
	if (!istype(RS))
		return 0
	if (RS.l_arm && RS.r_arm && RS.l_leg && RS.r_leg && RS.chest && RS.head)
		return 1
	return 0

//-------------------------------------------Plasma Research------------------------------------------------

//what, you mean there's a reason for non-antags to make bombs now? and send them to cargo? oh boy this will be fun.

/datum/centcomm_order/department/science/bomb
	name = "CentComm Armory"
	extra_requirements = "Epicenter Radius has to be X or more."
	var/required_dev = 0

/datum/centcomm_order/department/science/bomb/New()
	..()
	requested = list(
		/obj/item/device/transfer_valve = 1
	)
	name_override = list(
		/obj/item/device/transfer_valve = "TTV Explosive"
	)
	required_dev = rand(2,5)
	worth = required_dev * 500 - 500
	extra_requirements = "Epicenter Radius has to be [required_dev] or more."

/datum/centcomm_order/department/science/bomb/ExtraChecks(var/obj/item/device/transfer_valve/TTV)
	if (!istype(TTV))
		return 0
	if (TTV.simulate_merge() < required_dev)
		return 0
	return 1

//----------------------------------------------Xenobiology----------------------------------------------------

//High-tier slime cores
/datum/centcomm_order/department/science/pyrite/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/pyrite = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/cerulean/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/cerulean = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/sepia/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/sepia = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/bluespace/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/bluespace = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/adamantine/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/adamantine = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/oil/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/oil = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/black/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/black = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/lightpink/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/lightpink = rand(1,3)
	)
	worth = 600*requested[requested[1]]


//----------------------------------------------Xenoarchaeology----------------------------------------------------

//Contained Large Artifacts
/datum/centcomm_order/department/science/artifact/New()
	..()
	name = "Nanotrasen's Secure Containment Precinct"
	must_be_in_crate = 0
	requested = list(
		/obj/structure/anomaly_container = 1
	)
	name_override = list(
		/obj/structure/anomaly_container = "Contained Large Anomaly"
	)
	worth = 1500
	extra_requirements = "Must be shipped in an Anomaly Container, stamped with its Analysis Report, and after having been activated at least once."

/datum/centcomm_order/department/science/artifact/ExtraChecks(var/obj/structure/anomaly_container/AC)
	if (!istype(AC))
		return 0
	if (istype(AC.contained) && istype(AC.report))
		var/obj/machinery/artifact/contained = AC.contained
		var/obj/item/weapon/paper/anomaly/report = AC.report
		if ((report.artifact == contained) && contained.primary_effect?.triggered)
			return 1
	return 0

//Full Supermatter. yes, the round-ending one.
/datum/centcomm_order/department/science/supermatter/New()
	..()
	name = "Nanotrasen"
	must_be_in_crate = 0
	requested = list(
		/obj/machinery/power/supermatter = 1
	)
	worth = 5000
	extra_requirements = "A single of those can produce enough shards to power countless stations. Though extremely rare, Nanotrasen would be most grateful if you found one."

//Large Crystals
/datum/centcomm_order/department/science/crystal/New()
	..()
	name = "CentComm Beautification Department"
	must_be_in_crate = 0
	requested = list(
		/obj/structure/crystal = 1
	)
	worth = 300

//Assembled Alien Skeleton
/datum/centcomm_order/department/science/skeleton/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/structure/skeleton = 1
	)
	name_override = list(
		/obj/structure/skeleton = "Complete Alien Skeleton"
	)
	worth = 900
	extra_requirements = "The alien skeleton display needs to feature all its bones."

/datum/centcomm_order/department/science/skeleton/ExtraChecks(var/obj/structure/skeleton/S)
	if (!istype(S))
		return 0
	if (S.bstate)
		return 1
	return 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            MEDICAL ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//9 orders

//----------------------------------------------Surgery----------------------------------------------------

/datum/centcomm_order/department/medical
	acct_by_string = "Medical"

/datum/centcomm_order/department/medical/kidneys/New()
	..()
	requested = list(
		/obj/item/organ/internal/kidneys = rand(1,2)
	)
	name_override = list(
		/obj/item/organ/internal/kidneys = "human kidneys"
	)
	extra_requirements = "The organs needs to be fresh, use a medical crate or a freezer."
	worth = 200*requested[requested[1]]

/datum/centcomm_order/department/medical/kidneys/ExtraChecks(var/obj/item/organ/internal/kidneys/I)
	if (!istype(I))
		return 0
	if (I.health > 0)
		return 1
	return 0

/datum/centcomm_order/department/medical/heart/New()
	..()
	requested = list(
		/obj/item/organ/internal/heart = 1
	)
	name_override = list(
		/obj/item/organ/internal/heart = "human heart"
	)
	extra_requirements = "The organ needs to be fresh, use a medical crate or a freezer."
	worth = 400

/datum/centcomm_order/department/medical/heart/ExtraChecks(var/obj/item/organ/internal/heart/I)
	if (!istype(I))
		return 0
	if (I.health > 0)
		return 1
	return 0

//----------------------------------------------Virology----------------------------------------------------

//Vaccine
/datum/centcomm_order/department/medical/vaccine
	var/required_vac

/datum/centcomm_order/department/medical/vaccine/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Vaccine"
	)
	var/difficulty = rand(1,4)
	switch (difficulty)
		if (1)
			required_vac = pick(blood_antigens)
			worth = 200
		if (2)
			required_vac = pick(common_antigens)
			worth = 400
		if (3)
			required_vac = pick(rare_antigens)
			worth = 800
		if (4)
			required_vac = pick(alien_antigens)
			worth = 1600
	extra_requirements = "Must contain [required_vac] antibodies."

/datum/centcomm_order/department/medical/vaccine/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	for(var/datum/reagent/R in V.reagents?.reagent_list)
		if (istype(R,/datum/reagent/vaccine))
			var/datum/reagent/vaccine/vaccine = R
			for (var/A in vaccine.data["antigen"])
				if (A == required_vac)
					return 1
	return 0

//Dangerous Disease Vial
/datum/centcomm_order/department/medical/harmful_disease/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Infected Blood"
	)

	extra_requirements = "Must contain a dangerous disease with a combined Effect Danger level of at least 13, and a Strength of at least 80."
	worth = 600

/datum/centcomm_order/department/medical/harmful_disease/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	var/datum/reagent/blood/blood = locate() in V.reagents.reagent_list
	if (blood?.data["virus2"])
		var/list/blood_viruses = blood.data["virus2"]
		for (var/ID in blood_viruses)
			var/datum/disease2/disease/D = blood_viruses[ID]
			if (D.strength >= 80)
				var/total_badness = 0
				for(var/datum/disease2/effect/e in D.effects)
					total_badness += e.badness
				if (total_badness >= 13)
					return 1

	return 0

//Beneficial Disease Vial
/datum/centcomm_order/department/medical/beneficial_disease/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Infected Blood"
	)

	extra_requirements = "Must contain a beneficial disease with a combined Effect Danger level of at most 2."
	worth = 1000

/datum/centcomm_order/department/medical/beneficial_disease/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	var/datum/reagent/blood/blood = locate() in V.reagents.reagent_list
	if (blood?.data["virus2"])
		var/list/blood_viruses = blood.data["virus2"]
		for (var/ID in blood_viruses)
			var/datum/disease2/disease/D = blood_viruses[ID]
			var/total_badness = 0
			for(var/datum/disease2/effect/e in D.effects)
				total_badness += e.badness
			if (total_badness <= 2)
				return 1

	return 0

//Specific GNA Disks
/datum/centcomm_order/department/medical/gna_disk
	var/already_goten = list()
	var/req_stage

/datum/centcomm_order/department/medical/gna_disk/New()
	..()
	req_stage = rand(1,4)
	requested = list(
		/obj/item/weapon/disk/disease = rand (2,5)
	)
	name_override = list(
		/obj/item/weapon/disk/disease = "GNA Disks"
	)

	extra_requirements = "Each must contain a different Stage [req_stage] symptom."
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/gna_disk/ExtraChecks(var/obj/item/weapon/disk/disease/Disk)
	if (!istype(Disk))
		return 0
	if ((Disk.stage == req_stage) && Disk.effect && !(Disk.effect.type in already_goten))
		already_goten += Disk.effect.type
			return 1
	return 0

//----------------------------------------------Genetics----------------------------------------------------

//Clean SE
/datum/centcomm_order/department/medical/clean_se/New()
	..()
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,5)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Clean SE Injector"
	)
	worth = 100 * requested[requested[1]]

/datum/centcomm_order/department/medical/vaccine/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (!I.block && I.buf)//Not a block injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			for (var/block in R.dna.SE)
				if (I.buf.dna.SE >= 2050)
					return 0
		return 1
	return 0

//Specific Superpowers
/datum/centcomm_order/department/medical/xray/New()
	..()
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "X-Ray SE Block Injector"
	)
	worth = 200 * requested[requested[1]]

/datum/centcomm_order/department/medical/xray/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == XRAYBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			var/bstate = R.dna.GetSEState(XRAYBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/hulk/New()
	..()
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Hulk SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/hulk/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == HULKBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			var/bstate = R.dna.GetSEState(HULKBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/telepathy/New()
	..()
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Telepathy SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/telepathy/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == REMOTETALKBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			var/bstate = R.dna.GetSEState(REMOTETALKBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/remoteview/New()
	..()
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Remote View SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/remoteview/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == REMOTEVIEWBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			var/bstate = R.dna.GetSEState(REMOTEVIEWBLOCK)
			return bstate
	return 0


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                         ENGINEERING ORDERS                                               //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//2 orders

/datum/centcomm_order/department/engineering
	acct_by_string = "Engineering"

//----------------------------------------------Engineering----------------------------------------------------


/datum/centcomm_order/department/engineering/portable_smes/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/machinery/power/battery/portable = 1
	)
	name_override = list(
		/obj/machinery/power/battery/portable = "Portable Power Storage Unit"
	)
	extra_requirements = "The battery must be filled to full capacity."
	worth = 800

/datum/centcomm_order/department/engineering/portable_smes/ExtraChecks(var/obj/machinery/power/battery/portable/P)
	if (!istype(P))
		return 0
	if (P.charge < P.capacity)
		return 0
	return 1


//----------------------------------------------Atmospherics----------------------------------------------------


/datum/centcomm_order/department/engineering/cold_canister/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/obj/machinery/portable_atmospherics/canister = 1
	)
	name_override = list(
		/obj/machinery/portable_atmospherics/canister = "Cold Plasma Canister"
	)
	extra_requirements = "Filled with plasma bellow 2K at over 1000 kPa."
	worth = 1300

/datum/centcomm_order/department/engineering/cold_canister/ExtraChecks(var/obj/machinery/portable_atmospherics/canister/C)
	if (!istype(C))
		return 0
	var/datum/gas_mixture/GM = C.return_air()
	if ((GM.gas?.len == 1) && (GAS_PLASMA in GM.gas) && (GM.return_temperature() < 2) && (GM.pressure > 1000))
		return 1
	return 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            SERVICE ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//8 orders

//-------------------------------------------------Chef----------------------------------------------------

/datum/centcomm_order/department/civilian
	acct_by_string = "Civilian"

/datum/centcomm_order/per_unit/department/civilian
	name = "Nanotrasen Farmers United"
	acct_by_string = "Civilian"

/datum/centcomm_order/department/civilian/food
	var/sauce = 0//I SAID I WANTED KETCHUP

/datum/centcomm_order/department/civilian/food/New()
	..()
	var/chosen_food = rand(1,7)
	switch(chosen_food)
		if (1)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/pie = rand(3,12)
			)
			worth = 30*requested[requested[1]]
			name = "Clown Federation" //honk
			//no sauce for those, we know they're not gonna eat them
		if (2)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen = rand(1,3)
			)
			worth = 200*requested[requested[1]]
			sauce = 1
		if (3)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/superbiteburger = rand(1,3)
			)
			worth = 300*requested[requested[1]]
			sauce = 2
		if (4)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey = rand(1,2)
			)
			worth = 400*requested[requested[1]]
			sauce = 2
		if (5)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/bleachkipper = rand(2,5)
			)
			worth = 300*requested[requested[1]]
		if (6)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/potentham = rand(1,2)
			)
			worth = 1000*requested[requested[1]]
		if (7)
			requested = list(
				/obj/item/weapon/reagent_containers/food/snacks/sundayroast = rand(1,2)
			)
			worth = 700*requested[requested[1]]
			sauce = 2
	if (sauce && prob(60))
		worth += 100
		switch (sauce)
			if (1)//sweet
				sauce = pick(
					/datum/reagent/sugar,
					/datum/reagent/caramel,
					/datum/reagent/honey,
					/datum/reagent/honey/royal_jelly,
					/datum/reagent/cinnamon,
					/datum/reagent/coco)
			else//salty
				sauce = pick(
					/datum/reagent/mayo,
					/datum/reagent/ketchup,
					/datum/reagent/mustard,
					/datum/reagent/capsaicin,
					/datum/reagent/soysauce,
					/datum/reagent/vinegar)
		var/datum/reagent/R = sauce
		extra_requirements = "With some [initial(R.name)] as well. Don't forget the sauce or the dish won't be accepted."


/datum/centcomm_order/department/civilian/food/ExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/F)
	if (!istype(F))
		return 0
	if (!sauce)
		return 1
	if (F.reagents?.has_reagent_type(sauce, amount = -1, strict = 1))
		return 1
	return 0


/datum/centcomm_order/department/civilian/poutinecitadel/New()
	..()
	requested = list(
		/obj/structure/poutineocean/poutinecitadel = 1
	)
	must_be_in_crate = 0
	worth = 1200

/datum/centcomm_order/department/civilian/popcake/New()
	..()
	requested = list(
		/obj/structure/popout_cake = 1
	)
	must_be_in_crate = 0
	worth = 1000

//-------------------------------------------------Botany----------------------------------------------------


/datum/centcomm_order/department/civilian/novaflower/New()
	..()
	requested = list(
		/obj/item/weapon/grown/novaflower = rand(3,8)
	)
	worth = 70*requested[requested[1]]


/datum/centcomm_order/per_unit/department/civilian/potato/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = rand(50,200)
	)
	unit_prices=list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 5
	)
	worth = "5$ per potato"


/datum/centcomm_order/per_unit/department/civilian/honeycomb
	var/flavor

/datum/centcomm_order/per_unit/department/civilian/honeycomb/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/honeycomb = rand(4,20)
	)
	if (prob(50))
		unit_prices=list(
			/obj/item/weapon/reagent_containers/food/snacks/honeycomb = 20
		)
		worth = "20$ per honeycomb"
		flavor = pick(
			/datum/reagent/drink/applejuice,
			/datum/reagent/drink/grapejuice,
			/datum/reagent/drink/banana,
			)
	else
		unit_prices=list(
			/obj/item/weapon/reagent_containers/food/snacks/honeycomb = 60
		)
		worth = "60$ per honeycomb"
		flavor = pick(
			/datum/reagent/blood,
			/datum/reagent/psilocybin,
			/datum/reagent/hyperzine/cocaine,
			)//we've got some interesting honey enthusiasts over at Central Command

	var/datum/reagent/F = flavor
	name_override = list(
		/obj/item/weapon/reagent_containers/food/snacks/honeycomb = "[initial(F.name)]-flavored Honeycombs"
	)
	extra_requirements = "The flavor has to be natural, and not injected into the honeycomb."

/datum/centcomm_order/per_unit/department/civilian/honeycomb/ExtraChecks(var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H)
	if (!istype(H))
		return 0
	if (!flavor)
		return 1
	if (!H.verify())
		return 0
	if (H.reagents?.has_reagent_type(flavor, amount = -1, strict = 1))
		return 1
	return 0

/datum/centcomm_order/department/civilian/salmon/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/food/snacks/salmonmeat = rand(3,8)
	)
	worth = 130*requested[requested[1]]


//---------------------------------------------------Bar----------------------------------------------------


/datum/centcomm_order/department/civilian/custom_drink
	var/grown

/datum/centcomm_order/department/civilian/custom_drink/New()
	..()
	grown = pick(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime,
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato,
		/obj/item/weapon/reagent_containers/food/snacks/grown/pear,
		/obj/item/weapon/reagent_containers/food/snacks/grown/aloe,
		)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = grown
	var/chosen_drink = rand(1,5)
	switch(chosen_drink)
		if (1)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine = "[G] wine"
			)
		if (2)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey = "[G] whiskey"
			)
		if (3)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth = "[G] vermouth"
			)
		if (4)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka = "[G] vodka"
			)
		if (5)
			requested = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale = rand(1,6)
			)
			name_override = list(
				/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale = "[G] ale"
			)
	worth = 100*requested[requested[1]]

/datum/centcomm_order/department/civilian/custom_drink/ExtraChecks(var/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/C)
	if (!istype(C))
		return 0
	if (!grown)
		return 1
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in C.ingredients)
		var/ok = 0
		var/ruined = 0
		if (istype(S, grown))
			ok = 1
		else
			ruined = 1
		if (ok && !ruined)
			return 1
	return 0

//////////////////////////////////////////////
// ORDERS END HERE
//////////////////////////////////////////////

/proc/create_centcomm_order(var/datum/centcomm_order/C)
	SSsupply_shuttle.add_centcomm_order(C)

/proc/get_potential_orders()
	var/list/orders = list()
	orders.Add(subtypesof(/datum/centcomm_order/per_unit/department/cargo))
	orders.Add(subtypesof(/datum/centcomm_order/department/science))
	orders.Add(subtypesof(/datum/centcomm_order/department/medical))
	orders.Add(subtypesof(/datum/centcomm_order/department/engineering))
	orders.Add(subtypesof(/datum/centcomm_order/department/civilian))

	return orders

/proc/create_random_order()
	var/choice = pick(get_potential_orders())
	create_centcomm_order(new choice)

/proc/create_random_orders(var/num_orders)
	var/list/choices = get_potential_orders()
	for(var/i = 1 to num_orders)
		var/choice = pick_n_take(choices)
		create_centcomm_order(new choice)
