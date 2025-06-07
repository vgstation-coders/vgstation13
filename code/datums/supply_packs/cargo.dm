//////CARGO//////

/datum/supply_packs/mule
	name = "MULEbot"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot crate"
	group = "Cargo"
	containsdesc = "Contains an entire MULEbot. For when two broken pieces of crap aren't enough to move your pallets, so you want to order a third one."

/datum/supply_packs/tractor
	name = "Tractor"
	contains = list(/obj/structure/bed/chair/vehicle/tractor,
					/obj/machinery/cart/cargo)
	cost = 40
	containertype = /obj/structure/largecrate
	containername = "tractor crate"
	group = "Cargo"
	containsicon = "tractor"
	containsdesc = "The classic ride for any cargo man. Comes with one tractor, and as a limited time bonus: a free cart!"

/datum/supply_packs/carts
	name = "Carts"
	contains = list(/obj/machinery/cart/cargo,
                    /obj/machinery/cart/cargo)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "carts crate"
	group = "Cargo"
	containsdesc = "Two carts, usable with any tractor. Tractor not included."

/datum/supply_packs/mining
	name = "Mining equipment"
	contains = list(/obj/item/weapon/pickaxe/drill,
					/obj/item/weapon/pickaxe,
					/obj/item/weapon/pickaxe,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/flashlight/lantern,
					/obj/item/device/mining_scanner,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/ore,
					/obj/item/weapon/storage/bag/money,
					/obj/item/weapon/storage/bag/money)
	cost = 20
	containertype = /obj/structure/closet/crate/basic
	containername = "mining equipment crate"
	access = list(access_mining)
	group = "Cargo"
	containsdesc = "An emergency set of basic mining gear. Comes with enough gear for three miners to do their jobs. One gets a fancy drill, but the other two get entire bags to put their money in."

/datum/supply_packs/rcs_device
	name = "Rapid-Crate-Sender"
	contains = list (/obj/item/weapon/rcs)
	cost = 80
	containertype = /obj/structure/closet/crate/engi
	containername = "\improper RCS crate"
	group = "Cargo"
	containsdesc = "A rapid crate sending device. Comes pre-loaded with a rechargeable cell. Telepads not included!"

/datum/supply_packs/rcs_telepad
	name = "Cargo telepads"
	contains = list (/obj/item/device/telepad_beacon,
					 /obj/item/device/telepad_beacon,
					 /obj/item/device/telepad_beacon)
	cost = 80
	containertype = /obj/structure/closet/crate/engi
	containername = "\improper RCS telepad crate"
	group = "Cargo"
	containsdesc = "Telepads for use with the rapid crate sender. Contains three."

/datum/supply_packs/automation
	name = "Automation supplies"
	contains = list(/obj/item/weapon/circuitboard/autoprocessor/wrapping,
					/obj/item/weapon/circuitboard/autoprocessor/clothing,
					/obj/item/weapon/circuitboard/sorting_machine/item,
					/obj/item/weapon/circuitboard/crate_opener,
					/obj/item/weapon/circuitboard/crate_closer)
	cost = 25
	containertype = /obj/structure/closet/crate/engi
	containername = "automation supplies crate"
	group = "Cargo"
	containsdesc = "A starter pack for automating cargo. Includes an automatic crate opener, closer, wrapper, sorter, and even an auto-dresser."

/datum/supply_packs/package_wrap
	name = "Package wrap"
	contains = list(/obj/item/stack/package_wrap,
                    /obj/item/stack/package_wrap,
                    /obj/item/stack/package_wrap,
                    /obj/item/stack/package_wrap)
	cost = 10
	containertype = /obj/structure/closet/crate/basic
	containername = "package wrap crate"
	group = "Cargo"
	containsdesc = "Four bundles of package wrap. Perfect for when your merch computer is blown up and you've got a lot of packages to wrap."

/datum/supply_packs/cargonia_propaganda
	name = "Cargo posters"
	contains = list(/obj/item/mounted/poster/cargo,
                    /obj/item/mounted/poster/cargo,
                    /obj/item/mounted/poster/cargo,
                    /obj/item/mounted/poster/cargo,
                    /obj/item/mounted/poster/cargo,
                    /obj/item/mounted/poster/cargo)
	cost = 50
	containertype = /obj/structure/closet/crate/basic
	containername = "cargonia poster crate"
	group = "Cargo"
	containsdesc = "Six posters. Hail, hail Cargonia, Land of Stolen Things!"
