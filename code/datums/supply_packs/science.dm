//////SCIENCE//////

/datum/supply_packs/research_parts
	name = "RnD stock parts"
	contains = list(
					/obj/item/weapon/circuitboard/protolathe,
					/obj/item/weapon/circuitboard/rdconsole,
					/obj/item/weapon/circuitboard/circuit_imprinter,
					/obj/item/weapon/circuitboard/destructive_analyzer,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/stock_parts/manipulator,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/stock_parts/scanning_module,
					/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/micro_laser)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "research and development stock parts crate"
	access = list(access_science)
	group = "Science"
	containsdesc = "A starter kit for performing destructive-style research. Experimentally proven by NT scientists to work, though the lessons are usually quickly forgotten."

/datum/supply_packs/research_nanotrasen
	name = "RnD experimental tech"
	contains = list(
		/obj/item/weapon/disk/tech_disk/nanotrasen,
		/obj/item/weapon/paper/tech_nanotrasen,
		)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "research and development experimental crate"
	access = list(access_science)
	group = "Science"
	containsdesc = "A disk directly from Central Command containing data regarding their most recent high tech experimental research, including plasma-fueled cutting tools and mind-swapping devices."

/datum/supply_packs/robotics
	name = "Robotics assembly kit"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "robotics assembly crate"
	access = list(access_robotics)
	group = "Science"
	containsdesc = "A starter robotics kit. Perfect for building your first few basic robots."

/datum/supply_packs/robot_maintenance
	name = "Robot maintenance equipment"
	contains = list(/obj/item/weapon/book/manual/robotics_cyborgs,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/storage/toolbox/robotics,
					/obj/item/robot_parts/robot_component/armour,
					/obj/item/robot_parts/robot_component/actuator,
					/obj/item/robot_parts/robot_component/radio,
					/obj/item/robot_parts/robot_component/binary_communication_device,
					/obj/item/robot_parts/robot_component/camera,
					/obj/item/robot_parts/robot_component/diagnosis_unit,
					/obj/item/borg/upgrade/restart
					)
	cost = 120
	containertype = /obj/structure/closet/crate/sci
	containername = "robot maintenance equipment crate"
	group = "Science"
	containsdesc = "A cyborg repair kit. Contains common replacement parts for most broken components of a damaged cyborg."

/datum/supply_packs/grey_extract
	name = "Grey slime extracts"
	contains = list(/obj/item/slime_extract/grey,
					/obj/item/slime_extract/grey
					)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "grey slime extract crate"
	access = list(access_science)
	group = "Science"
	containsdesc = "An xenobiology sample crate. Contains two extracts of grey slimes for research."

/datum/supply_packs/suspension_gen
	name = "Suspension field generator"
	contains = list(/obj/machinery/suspension_gen)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "suspension field generator crate"
	access = list(access_science)
	group = "Science"
	containsdesc = "A suspension field generator, perfect for suspending dangerous artifacts in stasis."

/datum/supply_packs/excavation_gear
	name = "Excavation equipment"
	contains = list(
		/obj/item/weapon/storage/belt/archaeology,
		/obj/item/weapon/storage/box/excavation,
		/obj/item/device/flashlight/lantern,
		/obj/item/device/depth_scanner,
		/obj/item/device/core_sampler,
		/obj/item/clothing/glasses/scanner/meson,
		/obj/item/weapon/pickaxe,
		/obj/item/device/measuring_tape,
		/obj/item/weapon/pickaxe/hand,
		)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "excavation equipment crate"
	access = list(access_science)
	group = "Science"
	containsdesc = "The perfect gift for a young and upcoming xenoarchaeologist. Includes picks, samplers, depth scanners, and mesons. Does not include a whip."

/datum/supply_packs/plasma
	name = "Plasma assembly kit"
	contains = list(/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/infra,
					/obj/item/device/assembly/infra,
					/obj/item/device/assembly/infra,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = list(access_tox_storage)
	group = "Science"
	containsdesc = "A basic kit for plasma research. Contains three plasma tanks and a whole bunch of assorted assemblies."

/datum/supply_packs/borer
	name = "Borer egg"
	contains = list (/obj/item/weapon/reagent_containers/food/snacks/borer_egg)
	cost = 100
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "borer egg crate"
	access = list(access_xenobiology)
	group = "Science"
	containsdesc = "Contains one borer egg, perfect for raising your own snack."

/datum/supply_packs/anomaly_container
	name = "Anomaly container"
	cost = 50
	containertype = /obj/structure/largecrate/anomaly_container
	containername = "anomaly container crate"
	group = "Science"
	containsicon = /obj/structure/anomaly_container
	containsdesc = "A large container for sealing away strange alien anomalies."

/datum/supply_packs/suit_modification_station
	name = "Suit modification station"
	contains = list()
	cost = 200
	containertype = /obj/structure/closet/crate/flatpack/suit_modifier
	group = "Science"
	containsicon = /obj/machinery/suit_modifier
	containsdesc = "The suit modification station is an all-in-one hardsuit modification machine. Comes with a sample health readout upgrade."

/datum/supply_packs/hardsuit_frames
	name = "Hardsuit frames"
	contains = list(/obj/item/device/rigframe,
					/obj/item/device/rigframe,
					/obj/item/device/rigframe)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/scisec
	access = list(access_robotics)
	containername = "hardsuit frame crate"
	group = "Science"
	containsdesc = "A crate with three frames suitable for the production of hardsuits."

/datum/supply_packs/grey_rigkits
	name = "GDR rig parts"
	contains = list(/obj/item/device/rigparts/ayy_worker,
					/obj/item/device/rigparts/ayy_researcher)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/ayy_general
	one_access = list(access_robotics, access_mothership_research)
	containername = "GDR rig parts crate"
	group = "Science"
	contraband = 1
	containsdesc = "A package from the mothership with two hardsuit construction kits: one for a laborer and one for a researcher. A human won't be able to squeeze their fat body into these."
