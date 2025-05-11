
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            SCIENCE ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//30 orders

/datum/centcomm_order/department/science
	acct_by_string = "Science"
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Science",
		)

//--------------------------------------------R&D stuff----------------------------------------------------


/datum/centcomm_order/department/science/technology
	var/required_tech
	var/required_level
	var/tech

//Technology Data Disk, with a set tech and level required
/datum/centcomm_order/department/science/technology/New()
	..()
	name = "Nanotrasen R&D"
	tech = rand(1,5)
	switch(tech)
		if (1)
			required_tech = /datum/tech/materials
			required_level = rand(6,8)
		if (2)
			required_tech =  /datum/tech/bluespace
			required_level = rand(3,4)
		if (3)
			required_tech =  /datum/tech/combat
			required_level = rand(4,5)
		if (4)
			required_tech =  /datum/tech/magnets
			required_level = rand(4,5)
		if (5)
			required_tech =  /datum/tech/anomaly
			required_level = rand(4,6)
	requested = list(
		/obj/item/weapon/disk/tech_disk = 1
	)
	name_override = list(
		/obj/item/weapon/disk/tech_disk = "Technology Data Disk"
	)
	var/datum/tech/DT = required_tech
	extra_requirements = "tech required: [initial(DT.name)] (Level [required_level])"
	worth = 150 * required_level

/datum/centcomm_order/department/science/technology/ExtraChecks(var/obj/item/weapon/disk/tech_disk/TD)
	if (!istype(TD))
		return 0
	if (istype(TD.stored, required_tech))
		var/datum/tech/DT = TD.stored
		if (DT.level >= required_level)
			return 1
	return 0

/datum/centcomm_order/department/science/technology/BuildToExtraChecks(var/obj/item/weapon/disk/tech_disk/TD)
	if (istype(TD))
		var/datum/tech/DT = new required_tech
		DT.level = required_level
		TD.stored = DT


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

/datum/centcomm_order/department/science/design/BuildToExtraChecks(var/obj/item/weapon/disk/design_disk/DD)
	if (istype(DD))
		var/datum/design/DDS = new required_comp
		DD.blueprint = DDS

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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Robotics",
		)
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

/datum/centcomm_order/department/science/bomb/BuildToExtraChecks(var/obj/item/device/transfer_valve/TTV)
	if (istype(TTV))
		var/obj/item/weapon/tank/plasma/PT = new(TTV)
		var/obj/item/weapon/tank/oxygen/OT = new(TTV)

		TTV.tank_one = PT
		TTV.tank_two = OT

		//This is just an arbitrary mix that works fairly well.
		PT.air_contents.temperature = T0C + 170
		OT.air_contents.temperature = T0C - 100

		for(var/obj/item/weapon/tank/T in list(PT, OT))
			T.master = TTV
			var/datum/gas_mixture/G = T.air_contents
			G.update_values()
			G.multiply(((40 / 7) * required_dev) * ONE_ATMOSPHERE / G.pressure) //Should give an epicentre in the range.

		TTV.update_icon()

//----------------------------------------------Xenobiology----------------------------------------------------

//High-tier slime cores
/datum/centcomm_order/department/science/pyrite/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/pyrite = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/cerulean/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/cerulean = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/sepia/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/sepia = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/bluespace/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/bluespace = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/adamantine/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/adamantine = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/oil/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/oil = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/black/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/black = rand(1,3)
	)
	worth = 600*requested[requested[1]]

/datum/centcomm_order/department/science/lightpink/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenobiology",
		)
	must_be_in_crate = 0
	requested = list(
		/obj/item/slime_extract/lightpink = rand(1,3)
	)
	worth = 600*requested[requested[1]]


//----------------------------------------------Xenoarchaeology----------------------------------------------------

//Contained Large Artifacts
/datum/centcomm_order/department/science/artifact/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenoarchaeology",
		)
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

/datum/centcomm_order/department/science/artifact/BuildToExtraChecks(var/obj/structure/anomaly_container/AC)
	if (istype(AC))
		var/obj/machinery/artifact/AF = new(AC)
		AC.contained = AF
		if(AF.primary_effect)
			AF.primary_effect.triggered = 1
		AC.report = new /obj/item/weapon/paper/anomaly(AC)
		var/obj/item/weapon/paper/anomaly/AR = AC.report
		AR.artifact = AF
		AR.info = "<b>[src] analysis report for [AF]</b><br>"
		AR.info += "<br>"
		AR.info += "[bicon(AF)] [get_scan_info(AF)]"
		AR.stamped = list(/obj/item/weapon/stamp)
		AR.overlays = list("paper_stamp-qm")
		var/art_id = generate_artifact_id()
		excavated_large_artifacts[art_id] = AF
		AR.name = "Exotic Anomaly Report ([art_id])"
		AC.update_icon()

//Full Supermatter. yes, the round-ending one.
/datum/centcomm_order/department/science/supermatter
	hidden = TRUE

/datum/centcomm_order/department/science/supermatter/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenoarchaeology",
		)
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
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenoarchaeology",
		)
	name = "CentComm Beautification Department"
	must_be_in_crate = 0
	requested = list(
		/obj/structure/crystal = 1
	)
	worth = 300

//Assembled Alien Skeleton
/datum/centcomm_order/department/science/skeleton/New()
	..()
	request_consoles_to_notify = list(
		"Research Director's Desk",
		"Xenoarchaeology",
		)
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

/datum/centcomm_order/department/science/skeleton/BuildToExtraChecks(var/obj/structure/skeleton/S)
	if (istype(S))
		for(var/i in 1 to 3)
			S.contents.Add(new/obj/item/weapon/fossil/bone)
		S.contents.Add(new/obj/item/weapon/fossil/skull)
		S.bnum = S.breq
		S.icon_state = "skel"
		S.bstate = 1
		S.setDensity(TRUE)
		S.name = "alien skeleton display"
		S.desc = "A creature made of [S.contents.len-1] assorted bones and a skull. The plaque reads \'[S.plaque_contents]\'."
