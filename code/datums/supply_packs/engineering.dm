//////ENGINEERING//////

/datum/supply_packs/electrical
	name = "Electrical maintenance equipment"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 15
	containertype = /obj/structure/closet/crate/engi
	containername = "electrical maintenance crate"
	group = "Engineering"
	containsicon = /obj/item/clothing/gloves/yellow
	containsdesc = "Glubbs. Comes with two sets of electricity-proof yellow gloves, two electrical toolboxes, and a variety of power cells."

/datum/supply_packs/mechanical
	name = "Mechanical maintenance equipment"
	contains = list(/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate/engi
	containername = "mechanical maintenance crate"
	group = "Engineering"
	containsdesc = "For when you've got a lot of work to do and tool storage was blown up. Comes with three pre-loaded utility belts, three hazard vests, two welder masks, and a hard hat for good measure."

/datum/supply_packs/scrubberpump
	name = "Portable Scrubber and Pump"
	contains = list(/obj/machinery/portable_atmospherics/pump,
					/obj/machinery/portable_atmospherics/scrubber)
	cost = 25
	containertype = /obj/structure/largecrate
	containername = "portable atmospherics crate"
	group = "Engineering"
	containsdesc = "A portable scrubber and pump, just like the label says."

/datum/supply_packs/solar
	name = "Solar panels kit"
	contains  = list(/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly,
					/obj/machinery/power/solar_assembly, //21 Solar Assemblies. 1 Extra for the controller
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 20
	containertype = /obj/structure/closet/crate/engi
	containername = "solar panels crate"
	group = "Engineering"
	containsicon = "solars"
	containsdesc = "A solar panel starter kit. Comes with the framework for 20 solar panels, a solar tracker, and a computer to manage it. Glass and wires are not included."

/datum/supply_packs/engine
	name = "Emitters"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "emitter crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsicon = "emitters"
	containsdesc = "Two emitters. Perfect for... setting up the engines. Yes. Engines."

/datum/supply_packs/engine/field_gen
	name = "Field generators"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "field generator crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "Contains two field generators."

/datum/supply_packs/engine/sing_gen
	name = "Singularity generator"
	contains = list(/obj/machinery/the_singularitygen)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "singularity generator crate"
	access = list(access_ce)
	group = "Engineering"
	containsdesc = "A black hole generator. Only the bravest of space men would power their station with this. Requires a particle accelerator to get started."

/datum/supply_packs/engine/collector
	name = "Radiation collectors"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containername = "collector crate"
	group = "Engineering"
	containsdesc = "Three radiation collectors. Plasma tanks not included."

/datum/supply_packs/engine/prism
	name = "Optical prisms"
	contains = list(/obj/machinery/prism,
					/obj/machinery/prism)
	containername = "prism crate"
	group = "Engineering"
	containsdesc = "Two optical prisms, perfect for manipulating emitter beams."

/datum/supply_packs/engine/PA
	name = "Particle accelerator parts"
	cost = 40
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "particle accelerator crate"
	access = list(access_engine_major)
	group = "Engineering"
	containsdesc = "A full kit for setting up your own wave pool!"

/datum/supply_packs/shieldgens
	name = "Shield generators"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "shield generators crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "Contains four shield generators, ready and willing to protect you from threats inside of your station."

/datum/supply_packs/engine/amrcontrol
	name = "Antimatter control unit"
	contains = list(/obj/machinery/power/am_control_unit)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "antimatter control unit crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "Antimatter control unit for an antimatter engine. Reactor parts and fuel not included!"

/datum/supply_packs/engine/amrparts
	name = "Antimatter reactor parts"
	contains  = list(/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container,
					/obj/item/device/am_shielding_container)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "packaged antimatter reactor crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "Contains 12 antimatter reactor parts. Enough to power a regular space station."

/datum/supply_packs/engine/amrcontainment
	name = "Antimatter containment jars"
	contains = list(/obj/item/weapon/am_containment,
					/obj/item/weapon/am_containment,
					/obj/item/weapon/am_containment)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "antimatter containment jar crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "Three jars of antimatter for use with an antimatter engine."

/datum/supply_packs/engine/amrcontainment/big
	name = "Large Antimatter Containment Jar"
	contains = list(/obj/item/weapon/am_containment/big)
	cost = 200	//10x the fuel, 10x the cost + 50 for convenience
	containername = "Large antimatter containment jar crate"
	containsdesc = "One very large can of antimatter, ten times the size of a regular can. Comes at a slight premium."

/datum/supply_packs/rust
	contains = list(/obj/item/weapon/module/rust_fuel_compressor,
					/obj/item/weapon/module/rust_fuel_port,
					/obj/machinery/power/rust_fuel_injector,
					/obj/machinery/power/rust_core
					)
	name = "R-UST Mk. 7 foundation kit"
	cost = 50
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "\improper R-UST Mk. 7 fuel compressor circuitry crate"
	group = "Engineering"
	access = list(access_engine_major)
	containsdesc = "The core components of a R-UST. You can't make this powerful engine without at least one of these kits."

/datum/supply_packs/rust_consoles
	contains = list(/obj/item/weapon/circuitboard/rust_gyrotron_control,
					/obj/item/weapon/circuitboard/rust_fuel_control,
					/obj/item/weapon/circuitboard/rust_core_monitor,
					/obj/item/weapon/circuitboard/rust_core_control
					)
	name = "R-UST Mk. 7 console circuitry kit"
	cost = 30
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "\improper R-UST Mk. 7 console circuitry crate"
	group = "Engineering"
	access = list(access_engine_major)
	containsdesc = "Circuit boards for controlling a R-UST engine."

/datum/supply_packs/rust_gyrotron
	contains = list(/obj/machinery/rust/gyrotron)
	name = "R-UST Mk. 7 gyrotron"
	cost = 25
	containertype = /obj/structure/closet/crate/secure/large
	containername = "\improper R-UST Mk. 7 gyrotron crate"
	group = "Engineering"
	access = list(access_engine_major)
	containsdesc = "A single gryotron for a R-UST engine. Orderable in single crates for a perfect sized fit to your needs!"

/datum/supply_packs/shield_gen
	contains = list(/obj/structure/closet/crate/flatpack/starscreen_generator,
					/obj/structure/closet/crate/flatpack/starscreen_capacitor)
	name = "Starscreen shield generator"
	cost = 100
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Starscreen shield generator crate"
	group = "Engineering"
	access = list(access_engine_minor)
	containsdesc = "A Starscreen shield generator kit. Used to make a moderately large force field inside of your space station!"

/datum/supply_packs/shield_gen/post_creation(var/atom/movable/container)
	var/obj/structure/closet/crate/flatpack/flatpack1 = locate(/obj/structure/closet/crate/flatpack/starscreen_generator/) in container
	var/obj/structure/closet/crate/flatpack/flatpack2 = locate(/obj/structure/closet/crate/flatpack/starscreen_capacitor/) in container
	flatpack1.add_stack(flatpack2)

/datum/supply_packs/shield_gen_ex
	contains = list(/obj/structure/closet/crate/flatpack/starscreen_ex_generator,
					/obj/structure/closet/crate/flatpack/starscreen_capacitor)
	name = "Starscreen-EX shield generator"
	cost = 100
	containertype = /obj/structure/closet/crate/secure/large/reinforced
	containername = "Starscreen-EX shield generator crate"
	group = "Engineering"
	access = list(access_engine_minor)
	containsdesc = "A Starscreen-EX shield generator kit. Powerful enough to make a force field around the entire outer hull of your space station!"

/datum/supply_packs/shield_gen_ex/post_creation(var/atom/movable/container)
	var/obj/structure/closet/crate/flatpack/flatpack1 = locate(/obj/structure/closet/crate/flatpack/starscreen_ex_generator/) in container
	var/obj/structure/closet/crate/flatpack/flatpack2 = locate(/obj/structure/closet/crate/flatpack/starscreen_capacitor/) in container
	flatpack1.add_stack(flatpack2)

/datum/supply_packs/teg
	contains = list(/obj/machinery/power/generator)
	name = "Mark I Thermoelectric generator"
	cost = 75
	containertype = /obj/structure/closet/crate/secure/large
	containername = "mk1 TEG crate"
	group = "Engineering"
	access = list(access_engine_minor)
	containsdesc = "A central core for a thermoelectric generator. Requires two circulators to function (not included)."

/datum/supply_packs/circulator
	contains = list(/obj/machinery/atmospherics/binary/circulator)
	name = "Binary atmospheric circulator"
	cost = 25
	containertype = /obj/structure/closet/crate/secure/large
	containername = "atmospheric circulator crate"
	group = "Engineering"
	access = list(access_engine_minor)
	containsdesc = "Two circulators for a thermoelectric generator. Requires the generator itself to function (not included)."

/datum/supply_packs/supermatter_shard
	contains = list(/obj/machinery/power/supermatter/shard)
	name = "Supermatter shard"
	cost = 300 //So cargo thinks thrice before killing themselves with it. You're going to need a department account most likely.
	containertype = /obj/structure/closet/crate/secure/large/reinforced/shard/empty
	containername = "supermatter shard crate"
	group = "Engineering"
	access = list(access_engine_major)
	var/static/list/shard_counts_by_user = list()
	containsdesc = "A single shard of Supermatter, delivered directly from Central Command. Please take all precautions when ordering this crate."


/datum/supply_packs/supermatter_shard/OnConfirmed(var/mob/user)
	shard_counts_by_user[user.ckey]++
	var/i = shard_counts_by_user[user.ckey]
	var/span = ""
	switch (i)
		if (1)
			span = "notice"
		if (2 to 5)
			span = "warning"
		else
			span = "danger"
	message_admins("<span class='[span]'>[key_name(user)] has ordered a supermatter shard supplypack, this is his #[i] order. @[formatJumpTo(user)]</span>")
	log_admin("[key_name(user)] has ordered a supermatter shard supplypack, this is his #[i] order. @([user.x], [user.y], [user.z])")

/datum/supply_packs/portable_smes
	contains = list(/obj/machinery/power/battery/portable,
						/obj/item/weapon/circuitboard/battery_port,
						/obj/item/weapon/stock_parts/capacitor,
						/obj/item/weapon/stock_parts/capacitor,
						/obj/item/weapon/stock_parts/capacitor,
						/obj/item/weapon/stock_parts/console_screen)
	name = "Portable SMES parts"
	cost = 50
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "portable SMES crate"
	group = "Engineering"
	access = list(access_engine_minor)
	containsdesc = "A large battery pack, perfect for storing excess power for later use, or selling it for profit."

/datum/supply_packs/inflatables
	name = "Inflatable structures pack"
	contains = list (/obj/item/weapon/storage/box/inflatables,
					 /obj/item/weapon/storage/box/inflatables,
					 /obj/item/weapon/storage/box/inflatables)
	cost = 15
	containertype = /obj/structure/closet/crate/engi
	containername = "inflatable structures crate"
	group = "Engineering"
	containsdesc = "Three boxes of inflatable doors and walls, great for a breached space station."

/datum/supply_packs/firefighting_advanced
	name = "Advanced firefighting equipment"
	contains = list (/obj/item/weapon/fireaxe,
					/obj/item/tool/crowbar/halligan,
					/obj/item/weapon/extinguisher/foam,
					/obj/item/weapon/extinguisher/foam)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "advanced firefighting equipment crate"
	access = list(access_atmospherics)
	group = "Engineering"
	containsdesc = "Advanced firefighting accessories. Includes an axe, a halligan bar, and two foam extinguishers. Fire jacket and red hard hat not included - try the standard equipment crate."

/datum/supply_packs/radiation_suit
	name = "Radiation suit"
	contains = list()
	cost = 150
	containertype = /obj/structure/closet/crate/radiation
	containername = "radiation suit crate"
	group = "Engineering"
	containsicon = /obj/item/clothing/suit/radiation
	containsdesc = "A single radiation-proof suit, for when you need to stand before the Shard."

/datum/supply_packs/engine_parts
	name = "DIY Shuttle Engine kit"
	contains = list(/obj/structure/shuttle/engine/propulsion/DIY,
					/obj/structure/shuttle/engine/heater/DIY)
	cost = 100
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "\improper Shuttle engines crate"
	group = "Engineering"
	containsdesc = "Engines designed to work with the DIY Shuttle permit. Requires two engines per fifteen units of ship."

/datum/supply_packs/shuttle_permit
	name = "DIY Shuttle permit"
	contains = list(/obj/item/shuttle_license,
					/obj/item/weapon/book/manual/ship_building)

	cost = 300
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "secure shuttle permit crate"
	group = "Engineering"
	containsdesc = "A license to build your own shuttle. Not required to make the shuttle itself, but you won't be flying it without this baby."

/datum/supply_packs/gourmonger
	name = "Dehydrated gourmonger"
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube/gourmonger)
	cost = 75
	containertype = /obj/structure/closet/crate/secure/engisec
	containername = "Gourmonger Crate"
	access = list(access_engine_minor)
	group = "Engineering"
	containsdesc = "A fearsome monster, dehydrated into portable form. Can possibly be used to generate a large amount of power, but is more likely just going to eat through your walls."
