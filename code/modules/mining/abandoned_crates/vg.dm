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
//bottlecaps separate crate, more common as a result
/obj/structure/closet/crate/secure/loot/vg_coins/New()
	..()
	var/picked = pick(subtypesof(/obj/item/weapon/coin) - /obj/item/weapon/coin/pomf - /obj/item/weapon/coin/pumf - /obj/item/weapon/coin/nuka)
	for(var/i = 0, i < 30, i++)
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
		drop_stack(/obj/item/stack/sheet/mineral/gold, src, rand(10,20))

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
		var/obj/item/toy/plushie/fumo/fuuumo = new picked(src)
		fuuumo.name = "rare " + fuuumo.name

//guns
/obj/structure/closet/crate/secure/loot/vg_glocks/New()
	..()
	for(var/i = 0, i < 12, i++)
		var/picked = pickweight(list(/obj/item/toy/gun/glock = 5,
									/obj/item/weapon/gun/projectile/glock = 1))
		new picked(src)

//enough to dress your whole merry band!
/obj/structure/closet/crate/secure/loot/vg_pirate_clothes/New()
	..()
	for(var/i = 0, i < 7, i++)
		new/obj/item/weapon/storage/box/smartbox/clothing_box/pirateoutfit(src)

//in an affront to storytelling, here's the salvage captain. or at least one of his clones.
/obj/structure/closet/crate/secure/loot/vg_captain_himself/New()
	..()
	new/obj/effect/landmark/corpse/skellington/spess_captain(src)
	new/obj/item/weapon/pen/fountain/cap(src)
	new/obj/item/weapon/paper/captain/finalmessage(src)

/obj/structure/closet/crate/secure/loot/vg_pickaxe/New()
	var/obj/item/weapon/pickaxe/diamond/dorillu = new(src)
	dorillu.name = "sharp pickaxe"
	dorillu.desc = "A very sharp pickaxe made with a material that looks similar to solid plasma but isn't."
	dorillu.icon_state = "ppickaxe"
	dorillu.item_state = "ppickaxe"
	dorillu.force = 16
	dorillu.toolspeed = 0.05
	dorillu.sharpness = 0.2 // 16*5 = 80% to instantly sever limbs. Owch. Reduce this to like, 16%
	dorillu.sharpness_flags |= SHARP_BLADE
	dorillu.diggables = DIG_ROCKS | DIG_SOIL | DIG_WALLS | DIG_RWALLS //it's that strong
	dorillu.starting_materials += list(MAT_PHAZON = CC_PER_SHEET_PHAZON * 0.1) //the secret sauce is a phazon edge

//taken directly from peach's castle
/obj/structure/closet/crate/secure/loot/vg_pinups/New()
	..()
	for(var/i = 0, i < 10, i++)
		new/obj/item/mounted/poster/pinups(src)

//troll
/obj/structure/closet/crate/secure/loot/vg_goliath/New()
	..()
	new/mob/living/simple_animal/hostile/asteroid/goliath(src)

//troll
/obj/structure/closet/crate/secure/loot/vg_lootget/New()
	..()
	for(var/i = 0, i < 10, i++)
		new/obj/item/weapon/winter_gift/dorkcube(src)

//santa's lost presents
/obj/structure/closet/crate/secure/loot/vg_lost_christmas/New()
	..()
	var/obj/item/weapon/storage/backpack/santabag/my_bag = new(src)
	my_bag.desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! It doesn't look like it's as big as the movies would suggest..."
	my_bag.max_combined_w_class = 28 //equal to bag of holding
	for(var/i = 0, i < 14, i++)
		var/gift = pick(/obj/item/weapon/winter_gift/cloth,/obj/item/weapon/winter_gift/regular,/obj/item/weapon/winter_gift/food)
		new gift(my_bag)
	my_bag.update_icon()

//literally maint trash, not even the good stuff
/obj/structure/closet/crate/secure/loot/vg_trash/New()
	..()
	new/obj/abstract/map/spawner/maint/filled_crate(src)

//A crown with a third hand you say
/obj/structure/closet/crate/secure/loot/vg_crown/New()
	..()
	new/obj/item/cursed_hand_crown(src)

//Funny dispenser
/obj/structure/closet/crate/secure/loot/vg_rare_dispenser/New()
	..()
	new/obj/item/weapon/circuitboard/chem_dispenser/single/loot(src)


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

//Mancraft reference
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

//A full tank of karmotrine. Brace your body.
/obj/structure/reagent_dispensers/karmotrinetank
	name = "karmotrine tank"
	desc = "A storage tank containing a strange, alcoholic substance."
	icon_state = "liquidtank"

/obj/structure/reagent_dispensers/karmotrinetank/New()
	. = ..()
	reagents.add_reagent(KARMOTRINE, 1000)
	var/image/karmolay = image(icon, "[icon_state]_colorbase")
	karmolay.color = "#66ffff"
	overlays += karmolay

//Fake glocks!
/obj/item/toy/gun/glock
	name = "\improper NT Glock"
	desc = "The NT Glock is a cheap, ubiquitous sidearm, produced by a NanoTrasen subsidiary. Uses... caps. This is a cap gun. The real thing is so cheap that you couldn't initially tell the difference between it and a toy."
	icon = 'icons/obj/gun.dmi'
	icon_state = "secglock"
	bullets = 10
	max_bullets = 10

/obj/item/toy/gun/glock/New()
	var/image/magazine_adjustment = image("icon" = 'icons/obj/gun_part.dmi', "icon_state" = "m380AUTO")
	magazine_adjustment.pixel_x -= 11
	magazine_adjustment.pixel_y -= 11
	overlays += magazine_adjustment

//The ultimate fate of the salvage captain
/obj/effect/landmark/corpse/skellington/spess_captain
	name = "Unknown"
	corpseuniform = /obj/item/clothing/under/captain_fly
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsegloves = /obj/item/clothing/gloves/white
	corpsehelmet = /obj/item/clothing/head/helmet/space
	corpsesuit = /obj/item/clothing/suit/space
	corpsemask = /obj/item/clothing/mask/breath
	corpseback = /obj/item/weapon/tank/oxygen/empty
	corpseglasses = /obj/item/clothing/glasses/eyepatch

/obj/item/weapon/paper/captain/finalmessage
	name = "paper- 'note'"
	info = {"<span style="font-family:'Segoe Script', cursive;">Captain's Log
				<br>
				My men mutiny against me. I am doomed, lest I escape. I will hide in this crate, they will never find me here.
				<br>
				My men have hauled this crate and many others out of the ship. I know not where I am. Yet, alas! I've misplaced my ID.
				I cannot unlock the crate! My air supplies are running thin...
				<br>
				I hear some drilling noises nearby... air, please, hold out!</span>"}

//Hand selected posters for those with refined taste
/obj/item/mounted/poster/pinups
	name = "sexy poster"

/obj/item/mounted/poster/pinups/pick_design()
	var/list/poster_designs = list(/datum/poster/bay_21,
									/datum/poster/bay_22,
									/datum/poster/bay_12,
									/datum/poster/bay_9,
									/datum/poster/bay_23,
									/datum/poster/bay_24,
									/datum/poster/tg_4,
									/datum/poster/vg_2,
									/datum/poster/bay_8,
									/datum/poster/bay_9,
									/datum/poster/bay_17,)
	var/type = pick(poster_designs)
	design = new type

//I don't want to sprite this but here you go
/obj/item/cursed_hand_crown
	name = "\improper Cursed Hand Crown"
	desc = "It almost seems as though it's alive."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "lichcrown_fancy"
	item_state = "lichcrown_fancy"
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_HEAD
	canremove = 0
	cant_remove_msg = " is fused to your body!"

/obj/item/cursed_hand_crown/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_head) == src && equipped_slot != null && equipped_slot == slot_head)
		H.set_hand_amount(H.held_items.len + 1)
		to_chat(H, "You feel something strange coming out of your head. You can control the golden hand of the crown!")

/obj/item/cursed_hand_crown/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_head && istype(user))
		user.set_hand_amount(user.held_items.len - 1)
		to_chat(user, "The sensation of having an extra hand fades away.")

//futureproofed maint spanwer crate in case the loot tables change
/obj/abstract/map/spawner/maint/filled_crate
	amount = 30
	chance = 100


//Special Chemistry Dispensers that Dispense Single Reagents
/obj/machinery/chem_dispenser/single
	name = "\improper Single Chemical Dispenser"
	icon_state = "mixertall"
	dispensable_reagents = list()
	var/single_reagent = WATER
	beaker_height = 1
	max_beaker_size = W_CLASS_MEDIUM

/obj/machinery/chem_dispenser/single/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/single,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	dispensable_reagents = list(single_reagent)
	var/datum/reagent/temp = chemical_reagents_list[single_reagent]
	desc = "It dispenses [temp ? temp.name : single_reagent]."

/obj/machinery/chem_dispenser/single/update_icon()

	overlays.len = 0

	if(container)

		var/image/overlay

		if(istype(container, /obj/item/weapon/reagent_containers/glass/beaker/bluespace) || istype(container, /obj/item/weapon/reagent_containers/glass/beaker/noreact))
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_bluesp")
		else if(istype(container, /obj/item/weapon/reagent_containers/food/drinks/soda_cans))
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_soda")
		else if(istype(container, /obj/item/weapon/reagent_containers/glass/bucket))
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_bucket")
		else
			overlay = image('icons/obj/chemical.dmi', src, "dispenser_overlay_glassb")

		overlay.pixel_y = beaker_height * PIXEL_MULTIPLIER //used for children
		overlays += overlay

//Returns the pixel_x that our beaker overlay should have to match up with where the user clicked.
/obj/machinery/chem_dispenser/single/x_coord_to_nozzle(x_coord)
	return 0

/obj/machinery/chem_dispenser/single/RefreshParts()
	..()
	for(var/obj/item/weapon/circuitboard/chem_dispenser/single/C in component_parts)
		single_reagent = C.single_reagent
	update_chem_list()

/obj/machinery/chem_dispenser/single/update_chem_list()
	dispensable_reagents = list(single_reagent)
	var/datum/reagent/temp = chemical_reagents_list[single_reagent]
	desc = "It dispenses [temp ? temp.name : single_reagent]."

/obj/machinery/chem_dispenser/single/examine(var/mob/user)
	..()
	if(user?.client?.holder)
		to_chat(user,"Hello admin, you can use the change_reagent proc to change the reagent!")

//admin proc to change the reagent
/obj/machinery/chem_dispenser/single/proc/change_reagent()
	var/input_reagent = copytext(sanitize(input("Enter the name of any liquid", "Input") as text),1,MAX_MESSAGE_LEN)
	input_reagent = lowertext(input_reagent) // Lowercase for easier parsing
	if(findtext(input_reagent,"a cup of ")) // These appear at the start of a lot of requests in the SCP so parse these properly too
		input_reagent = replacetext(input_reagent,"a cup of ","")
	else if(findtext(input_reagent,"cup of ",0,7))
		input_reagent = replacetext(input_reagent,"cup of ","")
	var/chemfound = FALSE
	// Then searches through the list of all reagents and ignores case, plus converts spaces into either nothing or underscores for IDs
	// (due to no consistent alternating between either)
	for(var/reagent_id in chemical_reagents_list)
		var/datum/reagent/R = chemical_reagents_list[reagent_id]
		if(input_reagent == lowertext(R.name) || input_reagent == lowertext(reagent_id) || lowertext(reagent_id) == replacetext(input_reagent," ","") || lowertext(reagent_id) == replacetext(input_reagent," ","_"))
			input_reagent = reagent_id
			chemfound = R.name
			break
	if(chemfound)
		single_reagent = input_reagent
		for(var/obj/item/weapon/circuitboard/chem_dispenser/single/C in component_parts)
			C.single_reagent = input_reagent
		RefreshParts()
		to_chat(usr,"Updated \the [src] to have [chemfound].")
	else
		to_chat(usr,"OUT OF RANGE")

//
//Looted Dispenser
//Has random reagents
//
/obj/machinery/chem_dispenser/single/loot
	name = "\improper Mysterious Dispenser"
	single_reagent = null

/obj/machinery/chem_dispenser/single/loot/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/single/loot,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)
	RefreshParts() //Circuitboard controls everything!

//Circuitboards for the above
/obj/item/weapon/circuitboard/chem_dispenser/single
	name = "Circuit Board (Single Chemical Dispenser)"
	desc = "A circuit board used to run a reagent dispensing machine which dispenses a single chemical."
	build_path = /obj/machinery/chem_dispenser/single
	var/single_reagent = WATER

/obj/item/weapon/circuitboard/chem_dispenser/single/New()
	..()
	if(istype(loc,/obj/machinery/chem_dispenser/single))
		var/obj/machinery/chem_dispenser/single/my_dispenser = loc
		single_reagent = my_dispenser.single_reagent
	var/datum/reagent/temp = chemical_reagents_list[single_reagent]
	desc = "A circuit board used to run a reagent dispensing machine which dispenses a single chemical. An attached label says [temp ? temp.name : single_reagent]."

//Lootboard
/obj/item/weapon/circuitboard/chem_dispenser/single/loot
	name = "Circuit Board (Mysterious Dispenser)"
	desc = "A circuit board used to run a strange dispensing machine."
	build_path = /obj/machinery/chem_dispenser/single/loot
	single_reagent = null

/obj/item/weapon/circuitboard/chem_dispenser/single/loot/New()
	..()
	if(!single_reagent)
		single_reagent = determine_random_loot_reagent()
	var/datum/reagent/temp = chemical_reagents_list[single_reagent]
	desc = "A circuit board used to run a strange dispensing machine. A faded label says [temp ? temp.name : single_reagent]."

//Helper proc to generate looty reagents.
/proc/determine_random_loot_reagent()
	return pick(list(
	BEER,
	WHISKEY,
	TEQUILA,
	VODKA,
	VERMOUTH,
	RUM,
	COGNAC,
	WINE,
	SAKE,
	TRIPLESEC,
	BITTERS,
	CINNAMONWHISKY,
	SCHNAPPS,
	BLUECURACAO,
	KAHLUA,
	ALE,
	CHAMPAGNE,
	PWINE,
	WATER,
	GIN,
	SODAWATER,
	COLA,
	CREAM,
	TOMATOJUICE,
	ORANGEJUICE,
	LIMEJUICE,
	TONIC,
	SPACEMOUNTAINWIND,
	LEMON_LIME,
	DR_GIBB,
	TEA,
	GREENTEA,
	REDTEA,
	COFFEE,
	MILK,
	HOT_COCO,
	SOYMILK,
	SPORTDRINK,
	REFRIEDBEANS,
	BEFF,
	HORSEMEAT,
	CORNSYRUP,
	OFFCOLORCHEESE,
	BONEMARROW,
	GREENRAMEN,
	DEEPFRIEDRAMEN,
	DISCOUNT,
	NUTRIMENT,
	SUGAR,
	CORNOIL,
	LIPOZINE,
	INAPROVALINE,
	ANTI_TOXIN,
	BLISTEROL,
	KELOTANE,
	DEXALIN,
	LEPORAZINE,
	COCAINE,
	HYPERZINE,
	OPIUM,
	SPACE_DRUGS,
	ZAMMILD,
	ZAMSPICES,
	BLOOD,
	PANCAKE,
	FLOUR,
	MANNITOL,
	TRICORDRAZINE,
	HONKSERUM,
	AMINOMICIN,
	AMINOBLATELLA,
	))
