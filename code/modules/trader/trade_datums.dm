/datum/trade_products
	var/path = null
	var/baseprice = 50
	var/maxunits = 1
	var/totalsold = 0
	var/sales_category = null

/datum/trade_product/wardrobe
	path = /obj/structure/closet/secure_closet/wonderful
	baseprice = 150

/datum/trade_product/shoaljunk
	path = /obj/structure/closet/crate/shoaljunk
	baseprice = 100
	maxunits = 3

/datum/trade_product/cloudnine
	path = /obj/structure/closet/crate/internals/cloudnine
	baseprice = 150
	maxunits = 3

/datum/trade_product/alcatrazfour
	path = /obj/structure/closet/crate/chest/alcatraz
	baseprice = 150
	maxunits = 3

/datum/trade_product/energyshotty
	path = /obj/item/weapon/storage/lockbox/advanced/energyshotgun
	baseprice = 100

/datum/trade_product/ricotase
	path = /obj/item/weapon/storage/lockbox/advanced/ricochettaser
	baseprice = 25

/datum/trade_product/mechagy
	path = /obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	baseprice = 100

/datum/trade_product/mechexpac
	path = /obj/item/weapon/mech_expansion_kit
	baseprice = 50
	maxunits = 3

/datum/trade_product/wetdryvac
	path = /obj/structure/wetdryvac
	baseprice = 50

/datum/trade_product/huntingrifle
	path = /obj/item/weapon/gun/projectile/hecate/hunting
	baseprice = 100
	maxunits = 2

/datum/trade_product/fakeposter
	path = /obj/item/weapon/fakeposter_kit
	baseprice = 50

/datum/trade_product/yantarcrate
	path = 220
	baseprice = /obj/structure/closet/crate/medical/yantar

/datum/trade_product/condidisp
	path = /obj/structure/closet/crate/flatpack/ancient/condiment_dispenser
	baseprice = 100

/datum/trade_product/randommobs
	path = /obj/item/weapon/storage/box/mysterycubes
	baseprice = 75
	maxunits = 2

/datum/trade_product/randomchems
	path = /obj/item/weapon/storage/box/mystery_vial
	baseprice = 25
	maxunits = 5

/datum/trade_product/randomcircuits
	path = /obj/item/weapon/storage/box/mystery_circuit
	baseprice = 25

/datum/trade_product/randommats
	path = /obj/item/weapon/storage/box/large/mystery_material
	baseprice = 50
	maxunits = 5

/datum/trade_product/oddmats
	path = /obj/item/weapon/storage/box/large/mystery_material/odd
	baseprice = 25
	maxunits = 5

/datum/trade_product/randomfood
	path = /obj/structure/closet/crate/freezer/bootlegpicnic
	baseprice = 50
	maxunits = 3

