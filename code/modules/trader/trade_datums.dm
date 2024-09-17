#define TRADE_SINGLE "Single Products"
#define TRADE_VARIETY "Variety Packs"
#define FLUX_CHANCE 9
#define NEW_RECRUIT -1

/datum/trade_product
	var/name = "Abstract Product"
	var/path = null
	var/baseprice = 50
	var/maxunits = 1 //How many times you can buy it normally
	var/restocks_left = 0 //How many times it can be restocked
	var/totalsold = 0
	var/flux_rate = 1
	var/sales_category = TRADE_SINGLE

/datum/trade_product/proc/current_price(mob/user)
	var/loyalty_multiplier = 1
	if(!isAdminGhost(user)) //admin ghosts don't have customer data
		loyalty_multiplier = SStrade.loyal_customer(user)
	return round(baseprice * flux_rate * SStrade.shoal_prestige_factor() * loyalty_multiplier * isflashed())

/datum/trade_product/proc/can_restock()
	if(!totalsold || !restocks_left)
		return FALSE
	return TRUE

/datum/trade_product/proc/restock_weight()
	//Increase weight: more restocks left, Decrease: difference between sold and maxunits
	return restocks_left / (1+maxunits-totalsold)

/datum/trade_product/proc/restock()
	restocks_left--
	maxunits++

/datum/trade_product/proc/isflashed()
	if(SStrade.flash_sale_target == src)
		return 0.7
	return 1

/datum/trade_product/wardrobe
	name = "Wonderful Wardrobe"
	path = /obj/structure/closet/secure_closet/wonderful
	baseprice = 160
	sales_category = TRADE_VARIETY

/datum/trade_product/shoaljunk
	name = "Shoal Junk crate"
	path = /obj/structure/closet/crate/shoaljunk
	baseprice = 110
	maxunits = 3
	sales_category = TRADE_VARIETY

/datum/trade_product/cloudnine
	name = "Cloud IX crate"
	path = /obj/structure/closet/crate/internals/cloudnine
	baseprice = 160
	maxunits = 3
	sales_category = TRADE_VARIETY

/datum/trade_product/alcatrazfour
	name = "Alcatraz IV crate"
	path = /obj/structure/closet/crate/chest/alcatraz
	baseprice = 160
	maxunits = 4
	sales_category = TRADE_VARIETY

/datum/trade_product/zincsaucier
	name = "Zinc Saucier's crate"
	path = /obj/structure/closet/crate/freezer/zincsaucier
	baseprice = 160
	maxunits = 3
	sales_category = TRADE_VARIETY

/datum/trade_product/babel
	name = "Library of Babel shipment"
	path = /obj/structure/closet/crate/library
	baseprice = 100
	maxunits = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/mechagy
	name = "Mecha Graveyard shuttle disk"
	path = /obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	baseprice = 100

/datum/trade_product/mechexpac
	name = "exosuit expansion kit"
	path = /obj/item/weapon/mech_expansion_kit
	baseprice = 50
	maxunits = 3
	restocks_left = 3

/datum/trade_product/wetdryvac
	name = "wet/dry vacuum"
	path = /obj/structure/wetdryvac
	baseprice = 50
	restocks_left = 1

/datum/trade_product/huntingrifle
	name = "hunting rifle"
	path = /obj/item/weapon/gun/projectile/hecate/hunting
	baseprice = 100
	maxunits = 2
	restocks_left = 3

/datum/trade_product/fakeposter
	name = "cargo cache kit"
	path = /obj/item/weapon/fakeposter_kit
	baseprice = 50

/datum/trade_product/yantarcrate
	name = "Yantar medical crate"
	path = /obj/structure/closet/crate/medical/yantar
	baseprice = 160
	maxunits = 1
	sales_category = TRADE_VARIETY

/datum/trade_product/randommobs
	name = "dehydrated friend cubes"
	path = /obj/item/weapon/storage/box/mysterycubes
	baseprice = 80
	maxunits = 2
	restocks_left = 2
	sales_category = TRADE_VARIETY

/datum/trade_product/randomchems
	name = "assorted chemical pack"
	path = /obj/item/weapon/storage/box/mystery_vial
	baseprice = 30
	maxunits = 5
	restocks_left = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/randomcircuits
	name = "children's circuitry booster pack"
	path = /obj/item/weapon/storage/box/mystery_circuit
	baseprice = 30
	restocks_left = 2
	sales_category = TRADE_VARIETY

/datum/trade_product/randomupgrades
	name = "assorted cyborg upgrade pack"
	path = /obj/item/weapon/storage/box/mystery_upgrade
	baseprice = 60
	restocks_left = 2
	sales_category = TRADE_VARIETY

/datum/trade_product/randommats
	name = "surplus material scrap box"
	path = /obj/item/weapon/storage/box/large/mystery_material
	baseprice = 50
	maxunits = 5
	restocks_left = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/oddmats
	name = "odd scrap box"
	path = /obj/item/weapon/storage/box/large/mystery_material/odd
	baseprice = 30
	maxunits = 5
	restocks_left = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/randomfood
	name = "bootleg picnic supplies"
	path = /obj/structure/closet/crate/freezer/bootlegpicnic
	baseprice = 50
	maxunits = 3
	restocks_left = 3
	sales_category = TRADE_VARIETY

/datum/trade_product/gentlingmask
	name = "gentling mask"
	path = /obj/item/clothing/mask/gentling
	baseprice = 35
	restocks_left = 3

/datum/trade_product/nanopaints
	name = "Nano Painter's crate"
	path = /obj/item/weapon/storage/toolbox/nanopaint
	baseprice = 30
	maxunits = 3
	sales_category = TRADE_VARIETY
