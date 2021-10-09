#define TRADE_SINGLE "Single Products"
#define TRADE_VARIETY "Variety Packs"
#define FLUX_CHANCE 3
#define NEW_RECRUIT -1

/datum/trade_product
	var/name = "Abstract Product"
	var/path = null
	var/baseprice = 50
	var/maxunits = 1
	var/totalsold = 0
	var/flux_rate = 1
	var/sales_category = TRADE_SINGLE

/datum/trade_product/proc/current_price(mob/user)
	if(isAdminGhost(user))
		return round(baseprice * flux_rate * SStrade.shoal_prestige_factor()) //Don't factor in personal discount
	return round(baseprice * flux_rate * SStrade.shoal_prestige_factor() * SStrade.loyal_customer(user))

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

/datum/trade_product/mechagy
	name = "Mecha Graveyard shuttle disk"
	path = /obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	baseprice = 100

/datum/trade_product/mechexpac
	name = "exosuit expansion kit"
	path = /obj/item/weapon/mech_expansion_kit
	baseprice = 50
	maxunits = 3

/datum/trade_product/wetdryvac
	name = "wet/dry vacuum"
	path = /obj/structure/wetdryvac
	baseprice = 50

/datum/trade_product/huntingrifle
	name = "hunting rifle"
	path = /obj/item/weapon/gun/projectile/hecate/hunting
	baseprice = 100
	maxunits = 2

/datum/trade_product/fakeposter
	name = "cargo cache kit"
	path = /obj/item/weapon/fakeposter_kit
	baseprice = 50

/datum/trade_product/yantarcrate
	name = "Yantar medical crate"
	path = /obj/structure/closet/crate/medical/yantar
	baseprice = 220
	maxunits = 2
	sales_category = TRADE_VARIETY

/datum/trade_product/condidisp
	name = "condiment dispenser ancient flatpack"
	path = /obj/structure/closet/crate/flatpack/ancient/condiment_dispenser
	baseprice = 100

/datum/trade_product/randommobs
	name = "dehydrated friend cubes"
	path = /obj/item/weapon/storage/box/mysterycubes
	baseprice = 80
	maxunits = 2
	sales_category = TRADE_VARIETY

/datum/trade_product/randomchems
	name = "assorted chemical pack"
	path = /obj/item/weapon/storage/box/mystery_vial
	baseprice = 30
	maxunits = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/randomcircuits
	name = "children's circuitry booster pack"
	path = /obj/item/weapon/storage/box/mystery_circuit
	baseprice = 30
	sales_category = TRADE_VARIETY

/datum/trade_product/randommats
	name = "surplus material scrap box"
	path = /obj/item/weapon/storage/box/large/mystery_material
	baseprice = 50
	maxunits = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/oddmats
	name = "odd scrap box"
	path = /obj/item/weapon/storage/box/large/mystery_material/odd
	baseprice = 30
	maxunits = 5
	sales_category = TRADE_VARIETY

/datum/trade_product/randomfood
	name = "bootleg picnic supplies"
	path = /obj/structure/closet/crate/freezer/bootlegpicnic
	baseprice = 50
	maxunits = 3
	sales_category = TRADE_VARIETY

