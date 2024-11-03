//////MEDICAL//////

/datum/supply_packs/medical
	name = "Medical supplies"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/bag/chem,
					/obj/item/weapon/storage/box/autoinjectors,
					/obj/item/clothing/accessory/stethoscope)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"
	containsdesc = "Emergency medical supplies, perfect for stocking an OSHA compliant first aid station. Includes four first aid kits, a box of emergency auto-injectors, several medicines, and a stethoscope."

/datum/supply_packs/virus
	name = "Disease dishes"
	contains = list(/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/medsec
	containername = "disease crate"
	access = list(access_biohazard)
	group = "Medical"
	containsdesc = "Several samples of deadly diseases from exotic worlds, provided by Central Command. Take great care in handling these, unless you wish to unleash a deadly disease upon your station!"

/datum/supply_packs/surgery
	name = "Surgery tools"
	contains = list(/obj/item/tool/cautery,
					/obj/item/tool/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/tank/anesthetic,
					/obj/item/tool/FixOVein,
					/obj/item/tool/hemostat,
					/obj/item/tool/scalpel,
					/obj/item/tool/bonegel,
					/obj/item/tool/retractor,
					/obj/item/tool/bonesetter,
					/obj/item/tool/circular_saw)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/medsec
	containername = "surgery crate"
	access = list(access_medical)
	group = "Medical"
	containsdesc = "A full set of surgery tools and supplies, including anesthetic gas."

/datum/supply_packs/sterile
	name = "Sterile equipment"
	contains = list(/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/weapon/storage/box/masks,
					/obj/item/weapon/storage/box/gloves,
					/obj/item/weapon/storage/box/bodybags)
	cost = 15
	containertype = /obj/structure/closet/crate/medical
	containername = "sterile equipment crate"
	group = "Medical"
	containsdesc = "Also known as the deadly pathogen first response kit. Contains masks, gloves, two suits, and a box of body bags."

/datum/supply_packs/bloodbags
	name = "Bloodbags"
	contains = list(/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/medsec
	containername = "bloodbag crate"
	access = list(access_medical)
	group = "Medical"
	containsdesc = "A resupply of donated blood. Contains six filled packs and three empty ones."

/datum/supply_packs/bloodbot
	name = "Blood donation drive"
	contains = list(/obj/machinery/bot/bloodbot,
					/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
					/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
					/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
					/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje)
	cost = 50
	containertype = /obj/structure/largecrate
	containername = "blood donation drive crate"
	group = "Medical"
	containsdesc = "A basic blood donation kit. Comes with an automated robot that will perform the donation process for you. Includes snacks for those donating!"

/datum/supply_packs/chemkit
	name = "Basic chemistry kit"
	contains = list(/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/beaker,
					/obj/item/weapon/reagent_containers/glass/bottle/carbon,
					/obj/item/weapon/reagent_containers/glass/bottle/silicon,
					/obj/item/weapon/reagent_containers/glass/bottle/sugar,
					/obj/item/weapon/reagent_containers/glass/bottle/oxygen,
					/obj/item/weapon/reagent_containers/glass/bottle/hydrogen,
					/obj/item/weapon/reagent_containers/glass/bottle/nitrogen,
					/obj/item/weapon/reagent_containers/glass/bottle/potassium,
					/obj/item/weapon/reagent_containers/dropper)
	cost = 80
	containertype = /obj/structure/closet/crate/medical
	containername = "basic chemistry kit"
	group = "Medical"
	containsdesc = "A space man's first chemistry lab. Comes with a few beakers, common chemicals, and a dropper."


/datum/supply_packs/wheelchair
	name = "Wheelchair"
	contains = list(/obj/structure/bed/chair/vehicle/wheelchair)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "wheelchair crate"
	group = "Medical"
	containsdesc = "A basic wheelchair."

/datum/supply_packs/wheelchair_motorized
	name = "Motorized wheelchair"
	contains = list(/obj/structure/bed/chair/vehicle/wheelchair/motorized)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/medsec
	containername = "motorized wheelchair crate"
	access = list(access_medical)
	group = "Medical"
	containsdesc = "A wheelchair with a small electric engine attached."

/datum/supply_packs/skele_stand
	name = "Hanging skeleton model"
	cost = 30
	containertype = /obj/structure/largecrate/skele_stand
	containername = "hanging skeleton model crate"
	group = "Medical"
	containsicon = /obj/structure/skele_stand
	containsdesc = "A spooky, spooky skeleton!"

/datum/supply_packs/biosuits
	name = "Biosuits"
	contains = list(/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit)
	cost = 85
	containertype = /obj/structure/closet/crate/medical
	containername = "Regular Biosuits"
	group = "Medical"
	containsdesc = "The second responder's supplies. Contains three biohazard suits."

/datum/supply_packs/mouse
	name = "Laboratory mice and cages"
	contains = list (
					/obj/item/critter_cage,
					/obj/item/critter_cage,
					/obj/item/weapon/storage/box/monkeycubes/mousecubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "lab mouse crate"
	group = "Medical"
	containsdesc = "An experimental mice set. Comes with two cages and several dehydrated mice."

/datum/supply_packs/sutures
	name = "Wound mending supplies"
	contains = list (
					/obj/item/tool/suture/surgical_line,
					/obj/item/tool/suture/surgical_line,
					/obj/item/tool/suture/synthgraft,
					/obj/item/tool/suture/synthgraft)
	cost = 50
	containertype = /obj/structure/closet/crate/medical
	containername = "CM surplus medical equipment crate"
	group = "Medical"
	containsdesc = "Surplus wound-stitching supplies. Contains two lines and two grafts."
