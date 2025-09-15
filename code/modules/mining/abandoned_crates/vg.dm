//vg-themed lootcrates
//taken directly from peach's castle
/obj/structure/closet/crate/secure/loot/vg_painting/New()
	..()
	for(var/i = 0, i < 5, i++)
		new/obj/item/mounted/frame/painting(src)

//remember the good ol days of the merch computer...
/obj/structure/closet/crate/secure/loot/vg_switchtool/New()
	..()
	for(var/i = 0, i < 3, i++)
		new/obj/item/weapon/switchtool/swiss_army_knife(src)

//one day...
/obj/structure/closet/crate/secure/loot/vg_iou/New()
	..()
	new/obj/item/weapon/paper/iou(src)

//someone's trash is another person's treasure
/obj/structure/closet/crate/secure/loot/vg_atari/New()
	..()
	for(var/i = 0, i < 30, i++)
		new/obj/item/weapon/cartridge/spess_pets(src)

//anime fans rejoice
/obj/structure/closet/crate/secure/loot/vg_anime_pirate/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/devil(src)

//cash
/obj/structure/closet/crate/secure/loot/vg_coins/New()
	..()
	for(var/i = 0, i < 30, i++)
		var/picked = pick(subtypesof(/obj/item/weapon/coin) - /obj/item/weapon/coin/pomf - /obj/item/weapon/coin/pumf - /obj/item/weapon/coin/nuka)
		new picked(src)

//post apoc cash
/obj/structure/closet/crate/secure/loot/vg_caps/New()
	..()
	for(var/i = 0, i < 30, i++)
		new/obj/item/weapon/coin/nuka(src)

//heart of the sea except spess and you put it in your body
/obj/structure/closet/crate/secure/loot/vg_heart/New()
	..()
	new/obj/item/organ/internal/heart/hivelord/spess(src)

//straight up gold bars
/obj/structure/closet/crate/secure/loot/vg_gold/New()
	..()
	for(var/i = 0, i < 5, i++)
		drop_stack(/obj/item/stack/ore/gold, src, rand(10,20))

//the space pirates knew how to drink
/obj/structure/closet/crate/secure/loot/vg_va11halla/New()
	..()
	new/obj/structure/reagent_dispensers/karmotrinetank(src)
	new/obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	new/obj/item/weapon/book/manual/barman_recipes(src)

//so did the sea pirates
/obj/structure/closet/crate/secure/loot/vg_grog/New()
	..()
	var/obj/structure/reagent_dispensers/beerkeg/grogkeg = new(src)
	grogkeg.icon_state = "bloodkeg"
	grogkeg.reagents.clear_reagents()
	grogkeg.reagents.add_reagent(GROG, 1000)
	for(var/i = 0, i < 5, i++)
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/grogmug = new(src)
		grogmug.reagents.add_reagent(GROG, 25)

//another anime stash...
/obj/structure/closet/crate/secure/loot/vg_fumo/New()
	..()
	for(var/i = 0, i < 15, i++)
		var/picked = pick(subtypesof(/obj/item/toy/plushie/fumo))
		new picked(src)
		picked.name = "rare " + picked.name

/*
// Unique Loot Items
*/

/obj/item/weapon/cartridge/spess_pets
    name = "\improper Spess PETS! Cartridge"
    desc = "A faded price label suggests that this cartridge didn't sell very well."
    icon_state = "cart"
    starting_apps = list(
        /datum/pda_app/spesspets,
    )

//Fruit that grants a beneficial genetic power to the one who consumes it
/obj/item/weapon/reagent_containers/food/snacks/devil
	name = "devil's fruit"
	desc = "Anything you want, at your fingertips."
	icon = 'icons/lamprey.dmi'
	icon_state = "allfruit"
	volume = 3
	bitesize = 1
	var/power_granted_name
	var/power_granted_block

//Pick a randomly generated genetic power
/obj/item/weapon/reagent_containers/food/snacks/devil/New()
	..()
	reagents.add_reagent(NUTRIMENT, 3)
	var/list/good_list = list()
	for(var/gene_type in dna_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		if(!gene.block)
			continue
		if(gene.genetype!=GENETYPE_GOOD)
			continue
		good_list += gene
	var/datum/dna/gene/chosen = pick(good_list)
	power_granted_name = lowertext(chosen.name)
	power_granted_block = chosen.block

//Grants the power to the person who gets the last bite!
/obj/item/weapon/reagent_containers/food/snacks/devil/after_consume(var/mob/user, var/datum/reagents/reagentreference)
	if(!user)
		return
	if(reagents)
		reagentreference = reagents
	if(!reagentreference || !reagentreference.total_volume) //Are we done eating (determined by the amount of reagents left, here 0)
		user.visible_message("<span class='notice'>[user] finishes eating \the [src].</span>", \
		"<span class='notice'>You finish eating \the [src].</span>")
		to_chat(user,"<span class='notice'>Suddenly, you feel a bizarre surge of power! You've unlocked the abilities of \the [src] of [power_granted_name]!</span>")
		user.dna.SetSEState(power_granted_block,1)
		genemutcheck(user, power_granted_block,null,MUTCHK_FORCED)
		to_chat(user,"<span class='warning'>Unfortunately, you've permanently lost the ability to swim.</span>")
		qdel(src)
		return
	..()

//No eating this with a fork. You will eat this with your bare hands!
/obj/item/weapon/reagent_containers/food/snacks/devil/is_compatible_utensil(var/obj/item/W,var/mob/user)
	return FALSE

/obj/item/organ/internal/heart/hivelord/spess
	name = "heart of the spess"
	desc = "A mysterious, beating crystal. It feels like it belongs inside your body."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "Green lump"
	stabilized = TRUE
	organ_type = /datum/organ/internal/heart/hivelord/spess

/obj/item/organ/internal/heart/hivelord/spess/die()
	..()
	desc = "The crystal is inert."

/datum/organ/internal/heart/hivelord/spess
	name = "heart of the spess"
	removed_type = /obj/item/organ/internal/heart/hivelord/spess
	min_bruised_damage = 20
	min_broken_damage = 40

/obj/structure/reagent_dispensers/karmotrinetank
	name = "karmotank"
	desc = "A storage tank containing a strange, alcoholic substance."
	icon_state = "liquidtank"

/obj/structure/reagent_dispensers/karmotrinetank/New()
	. = ..()
	reagents.add_reagent(KARMOTRINE, 1000)
	var/image/karmolay = image(icon, "[icon_state]_colorbase")
	karmolay.color = "#66ffff"
	overlays += karmolay

