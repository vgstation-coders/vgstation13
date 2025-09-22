//traditional bay lootcrates, but with some slight power creeping
//illegal supplies crate
/obj/structure/closet/crate/secure/loot/bay_01/New()
	..()
	for(var/i = 0, i < 9, i++)
		var/picked = pick(list(
			/obj/item/weapon/reagent_containers/food/drinks/bottle/rum,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/fireballwhisky,
			/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,
			/obj/item/clothing/mask/cigarette/cigar,
			/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus,))
		new picked(src)
	new	/obj/item/weapon/lighter/zippo(src)

//spaceman package
/obj/structure/closet/crate/secure/loot/bay_02/New()
	..()
	new/obj/item/weapon/pickaxe/drill(src)
	new/obj/item/device/taperecorder(src)
	new/obj/item/clothing/suit/space(src)
	new/obj/item/clothing/head/helmet/space(src)
	new/obj/item/weapon/paper/tommyboy(src)

//a bluespace beaker, but larger
/obj/structure/closet/crate/secure/loot/bay_03/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/large/powerful_beaker = new(src)
	powerful_beaker.name = "larger bluespace beaker"
	powerful_beaker.desc = "A prototype ultra-capacity beaker that uses advances in bluespace research. Can hold up to 450 units."
	powerful_beaker.volume = 450
	powerful_beaker.reagents.maximum_volume = 450

//minecraft diamonds
/obj/structure/closet/crate/secure/loot/bay_04/New()
	..()
	drop_stack(/obj/item/stack/ore/diamond, src, rand(10,20))

//some planters for the hobo, but with actual seeds instead of weed RNG
/obj/structure/closet/crate/secure/loot/bay_05/New()
	..()
	for(var/i = 0, i < 3, i++)
		new/obj/machinery/portable_atmospherics/hydroponics/loose(src)
	for(var/i = 0, i < 6, i++)
		var/picked = pickweight(seedbush_spawns)
		new picked(src)

//buncha no-react beakers
/obj/structure/closet/crate/secure/loot/bay_06/New()
	..()
	for(var/i = 0, i < 3, i++)
		new/obj/item/weapon/reagent_containers/glass/beaker/noreact/large(src)

//bluespace crystal bundle
/obj/structure/closet/crate/secure/loot/bay_07/New()
	..()
	for(var/i = 0, i < 9, i++)
		new/obj/item/bluespace_crystal(src)

//Enough classic batons to equip security or cargo
/obj/structure/closet/crate/secure/loot/bay_08/New()
	..()
	for(var/i = 0, i < 3, i++)
		new/obj/item/weapon/melee/classic_baton(src)

//A powerful choose-your-jumpsuit, with bonus ties for days
/obj/structure/closet/crate/secure/loot/bay_09/New()
	..()
	new/obj/item/clothing/under/chameleon(src)
	for(var/i = 0, i < 14, i++)
		new/obj/item/clothing/accessory/tie/horrible(src)

//shorts
/obj/structure/closet/crate/secure/loot/bay_10/New()
	..()
	new/obj/item/clothing/under/shorts/red(src)
	new/obj/item/clothing/under/shorts/blue(src)

//Enough modern batons to equip security twice over or cargo
/obj/structure/closet/crate/secure/loot/bay_11/New()
	..()
	for(var/i = 0, i < 3, i++)
		new/obj/item/weapon/melee/baton/loaded(src)
