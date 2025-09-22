//vg-themed lootcrates

//for those who enter here: the name of the game is funny
//anything below should give miners at least a sensible chuckle of some sort

//taken directly from peach's castle (old crate, updated)
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

//anime fans rejoice, now you can be the anime pirate king
/obj/structure/closet/crate/secure/loot/vg_anime_pirate/New()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/devil(src)

//cash
//bottlecaps are in a separate crate, more common as a result
/obj/structure/closet/crate/secure/loot/vg_coins/New()
	..()
	var/picked = pick(subtypesof(/obj/item/weapon/coin) + /obj/item/weapon/reagent_containers/food/snacks/chococoin - /obj/item/weapon/coin/pomf - /obj/item/weapon/coin/pumf - /obj/item/weapon/coin/nuka)
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
	new/obj/item/weapon/circuitboard/chem_dispenser/single(src, optional_reagent = "karmotrine")
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
	for(var/i = 0, i < 9, i++)
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
	..()
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

//also taken directly from peach's castle
/obj/structure/closet/crate/secure/loot/vg_pinups/New()
	..()
	for(var/i = 0, i < 10, i++)
		new/obj/item/mounted/poster/pinups(src)

//troll
/obj/structure/closet/crate/secure/loot/vg_goliath
	var/opening_buff = FALSE

/obj/structure/closet/crate/secure/loot/vg_goliath/New()
	..()
	var/mob/living/simple_animal/hostile/asteroid/goliath/surprise_inside = new(src)
	surprise_inside.environment_smash_flags = 0//so it won't just... break out instantly

/obj/structure/closet/crate/secure/loot/vg_goliath/open()
	if(opening_buff)
		return ..()
	var/list/monsters_inside = list()
	for(var/mob/living/simple_animal/hostile/asteroid/goliath/creature in contents)
		monsters_inside += creature
	if(..())
		for(var/mob/living/simple_animal/hostile/asteroid/goliath/creature in monsters_inside)
			creature.environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS //once they are free, they will smash containers once more.
		opening_buff = TRUE

//loot get!
/obj/structure/closet/crate/secure/loot/vg_lootget/New()
	..()
	for(var/i = 0, i < 12, i++)
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

//literally maint trash
/obj/structure/closet/crate/secure/loot/vg_trash/New()
	..()
	new/obj/abstract/map/spawner/maint/filled_crate(src)
	new/obj/item/weapon/reagent_containers/pill/random/maintenance(src)
	new/obj/item/weapon/reagent_containers/pill/random/maintenance(src)

//A crown with a third hand you say
/obj/structure/closet/crate/secure/loot/vg_crown/New()
	..()
	new/obj/item/cursed_hand_crown(src)

//Funny dispenser
/obj/structure/closet/crate/secure/loot/vg_rare_dispenser/New()
	..()
	new/obj/item/weapon/circuitboard/chem_dispenser/single/loot(src)

//Someone was clippin' coupons...
/obj/structure/closet/crate/secure/loot/vg_coupons/New()
	..()
	var/list/valid_vouchers = subtypesof(/obj/item/voucher/free_item) - /obj/item/voucher/free_item/scrip - /obj/item/voucher/free_item/glowing //ask pomf for one not the lootcrate system
	for(var/i = 0, i < 10, i++)
		var/obj/picked = pick(valid_vouchers)
		new picked(src)

//Turns out the pirates were actually just actors and these were their spare costumes
/obj/structure/closet/crate/secure/loot/vg_costumes/New()
	..()
	var/list/funny_outfits = list(
		/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/monkeysuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/xenosuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/gladiatorsuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/captaincasualoutfit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/schoolgirloutfit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/sovietoutfit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/fakewizard,
		/obj/item/weapon/storage/box/smartbox/clothing_box/witch,
		/obj/item/weapon/storage/box/smartbox/clothing_box/marisa,
		/obj/item/weapon/storage/box/smartbox/clothing_box/mega,
		/obj/item/weapon/storage/box/smartbox/clothing_box/sexyclown,
		/obj/item/weapon/storage/box/smartbox/clothing_box/sexymime,
		/obj/item/weapon/storage/box/smartbox/clothing_box/clownpiece,
		/obj/item/weapon/storage/box/smartbox/clothing_box/jester,
		/obj/item/weapon/storage/box/smartbox/clothing_box/maid,
		/obj/item/weapon/storage/box/smartbox/clothing_box/liberty,
		/obj/item/weapon/storage/box/smartbox/clothing_box/aviator,
		/obj/item/weapon/storage/box/smartbox/clothing_box/proto,
		/obj/item/weapon/storage/box/smartbox/clothing_box/owl,
		/obj/item/weapon/storage/box/smartbox/clothing_box/pirateoutfit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/lordadmiral,
		/obj/item/weapon/storage/box/smartbox/clothing_box/plaguedoctor,
		/obj/item/weapon/storage/box/smartbox/clothing_box/rotten,
		/obj/item/weapon/storage/box/smartbox/clothing_box/frank,
		/obj/item/weapon/storage/box/smartbox/clothing_box/mexican,
		/obj/item/weapon/storage/box/smartbox/clothing_box/banana_set,
		/obj/item/weapon/storage/box/smartbox/clothing_box/furtrapper_set,
		/obj/item/weapon/storage/box/smartbox/clothing_box/sonicman,
		/obj/item/weapon/storage/box/smartbox/clothing_box/sonicsuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/tailssuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/knucklessuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/amysuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/shadowsuit,
		/obj/item/weapon/storage/box/smartbox/clothing_box/clownpsyche,
		/obj/item/weapon/storage/box/smartbox/clothing_box/chickensuitwhite,
		/obj/item/weapon/storage/box/smartbox/clothing_box/joe,
		/obj/item/weapon/storage/box/smartbox/clothing_box/lola,
	)
	for(var/i = 0, i < 7, i++)
		var/picked = pick(funny_outfits)
		new picked(src)

//They stole a crate from the traders
/obj/structure/closet/crate/secure/loot/vg_trader/New()
	..()
	var/datum/trade_product/picked = pick(subtypesof(/datum/trade_product))
	var/obj/picked_box = new picked.path(src)
	if(picked.sales_category == "Variety Packs")
		for(var/obj/item/I in picked_box.contents)
			I.forceMove(src)
		qdel(picked_box)

//Tabletop gaming emergency crate
/obj/structure/closet/crate/secure/loot/vg_dice/New()
	..()
	var/list/good_dice = list(
		/obj/item/weapon/dice/d2,
		/obj/item/weapon/dice/d4,
		/obj/item/weapon/dice, //d6
		/obj/item/weapon/dice/d8,
		/obj/item/weapon/dice/d10,
		/obj/item/weapon/dice/d00,
		/obj/item/weapon/dice/d12,
		/obj/item/weapon/dice/d20,
		/obj/item/weapon/dice/fudge,
		/obj/item/weapon/dice/loaded,
		/obj/item/weapon/dice/loaded/d20,
	)
	for(var/i = 0, i < 13, i++)
		var/picked = pick(good_dice)
		new picked(src)
	new/obj/item/dicetower(src)
	new/obj/item/weapon/storage/box/redcore(src)

//Bunch of random parts
/obj/structure/closet/crate/secure/loot/vg_parts/New()
	..()
	var/list/parts = subtypesof(/obj/item/weapon/stock_parts) - typesof(/obj/item/weapon/stock_parts/subspace)
	var/really_good_part_picked = FALSE
	for(var/i = 0, i < 20, i++)
		var/obj/item/weapon/stock_parts/picked = pick(parts)
		if(picked.rating >= 4)
			if(really_good_part_picked) //You only can get one, extras are lost!
				continue
			really_good_part_picked = TRUE
		new picked(src)
	var/bonus_tool = pick(list(
			/obj/item/tool/wrench,
			/obj/item/tool/wrench/socket,
			/obj/item/tool/screwdriver,
			/obj/item/tool/solder/screw,
	))
	new bonus_tool(src)

//I asked a random guy what he would find in a buried chest on the roid, and he said "a cup or something"
/obj/structure/closet/crate/secure/loot/vg_cup/New()
	..()
	var/picked = pick(subtypesof(/obj/item/weapon/reagent_containers/food/drinks/flagmug))
	new picked(src)

//monky
/obj/structure/closet/crate/secure/loot/vg_monkey/New()
	..()
	new/mob/living/carbon/monkey(src)
	for(var/i = 0, i < 6, i++)
		new/obj/item/weapon/bananapeel(src)

//funny
/obj/structure/closet/crate/secure/loot/vg_recursive/New(var/loc, var/recursion = 0)
	..()
	if(recursion >= 4)
		new/obj/item/toy/figure/cargotech(src)
		return
	var/obj/structure/closet/crate/secure/loot/vg_recursive/smaller = new(src, recursion + 1)
	var/matrix/shrink = matrix()
	shrink.Scale(1 - ((recursion+1) * 0.1))
	smaller.transform = shrink

//20 bucks
/obj/structure/closet/crate/secure/loot/vg_20_bucks/New()
	..()
	new/obj/item/weapon/spacecash/c10(src, 2)

//can't give you the suit but how about this
/obj/structure/closet/crate/secure/loot/vg_bomberman/New()
	..()
	new/obj/item/weapon/vinyl/bomberman(src)
	new/obj/item/cannonball/fuse_bomb(src)
	for(var/i = 0, i < 4, i++)
		var/picked = pick(typesof(/obj/item/toy/gasha/bomberman))
		new picked(src)

//beans
/obj/structure/closet/crate/secure/loot/vg_beans/New()
	..()
	for(var/i = 0, i < 6, i++)
		new/obj/item/weapon/reagent_containers/food/snacks/beans(src)

//cargo lost a crate
/obj/structure/closet/crate/secure/loot/vg_cargo/New()
	..()
	var/list/packlist = subtypesof(/datum/supply_packs)
	var/list/valid_list = list()
	for(var/choice in packlist)
		var/datum/supply_packs/possible_choice = choice
		//no mann and co keys, you gotta actually pay for those!
		if(possible_choice.require_holiday)
			continue
		//no wooden large crates or unusual crates
		if(!ispath(possible_choice.containertype, /obj/structure/closet/crate))
			continue
		//regular sized crates only!
		if(ispath(possible_choice.containertype, /obj/structure/closet/crate/secure/large))
			continue
		valid_list += possible_choice
	var/listpick = pick(valid_list)
	var/datum/supply_packs/picked = new listpick()
	//we've chosen a crate. Now, make a manifest for it...
	var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest(src)
	slip.name = "Shipping Manifest for ... ..."
	slip.info = {"<h3>... Shipping Manifest ... Order...</h3><hr><br>
		Order #[rand(30000,90000)]<br>
		[picked.name] crate<br>
		The destination is too faded to make out.<br>
		PACKAGES IN .... SHIPMENT<br>
		CONTENTS:<br><ul>"}
	//random crates have a different method of picking their contents
	if(istype(picked,/datum/supply_packs/randomised))
		var/datum/supply_packs/randomised/random_picked = picked
		for(var/i = 0, i < random_picked.num_contained, i++)
			var/atom/picked_inside = pick(picked.contains)
			new picked_inside(src)
			slip.info += "<li>[picked_inside.name]</li>"
	else
		for(var/picked_inside in picked.contains)
			new picked_inside(src)
			var/atom/picked_name_reader = picked_inside
			slip.info += "<li>[picked_name_reader.name]</li>"
	slip.info += {"</ul><br>
	CHECK CONTENTS ... BELOW THE LINE TO ...<hr>"}
	//cleanup
	QDEL_NULL(picked)

//perfect, some dude's old battery storage box! plenty of batteries for you to use.
//what? they're trash and even a generic cell is more useful? i can't believe this!
/obj/structure/closet/crate/secure/loot/vg_battery/New()
	..()
	new/obj/item/weapon/storage/fancy/battery_box(src)
	for(var/i = 0, i < 5, i++)
		var/picked = pick(typesof(/obj/item/weapon/cell/crap))
		new picked(src)

//lipstick
/obj/structure/closet/crate/secure/loot/vg_lipstick/New()
	..()
	for(var/i = 0, i < 12, i++)
		var/picked = pickweight(list(/obj/item/weapon/lipstick = 5,
									/obj/item/weapon/grenade/chem_grenade/teargas/lipstick = 1))
		new picked(src)

//pdas
/obj/structure/closet/crate/secure/loot/vg_pdas/New()
	..()
	for(var/i = 0, i < 12, i++)
		var/picked = pickweight(list(/obj/item/device/pda = 3,
									/obj/item/weapon/reagent_containers/food/drinks/flask/pdaflask = 2,
									/obj/item/weapon/gun/energy/taser/disguised_pda = 1))
		new picked(src)



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
	desc = "The NT Glock is a cheap, ubiquitous sidearm, produced by a NanoTrasen subsidiary. Uses .380AUTO rounds. Its subcompact frame can fit in your pocket."
	icon = 'icons/obj/gun.dmi'
	icon_state = "secglock"
	bullets = 10
	max_bullets = 10
	disguised = TRUE

/obj/item/toy/gun/glock/New()
	var/image/magazine_adjustment = image("icon" = 'icons/obj/gun_part.dmi', "icon_state" = "m380AUTO")
	magazine_adjustment.pixel_x -= 11
	magazine_adjustment.pixel_y -= 11
	overlays += magazine_adjustment

/obj/item/toy/gun/glock/examine(user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>On closer inspection, you realize that this actually uses... caps. This is a cap gun. The real thing is so cheap that you couldn't initially tell the difference between it and a toy.</span>")

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
	name = "\improper Crown of Many Hands"
	desc = "This crown menaces with a hand carved out of pure gold. It almost seems as though it's alive."
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
	amount = 28
	chance = 100

/obj/item/weapon/gun/energy/taser/disguised_pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by applications on ROM cartridge. Can download additional applications from PDA terminals."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	item_state = "electronic"
	charge_states = FALSE
	slot_flags = SLOT_ID | SLOT_BELT
	w_class = W_CLASS_TINY

/obj/item/weapon/gun/energy/taser/disguised_pda/examine(user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>On closer inspection, you realize that the screen and buttons are fake. This thing is actually a taser!</span>")

/obj/item/weapon/reagent_containers/food/drinks/flask/pdaflask
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by applications on ROM cartridge. Can download additional applications from PDA terminals."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	item_state = "electronic"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/pdaflask/examine(user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>On closer inspection, you realize that the screen and buttons are fake. This thing is actually a flask!</span>")

/obj/item/weapon/grenade/chem_grenade/teargas/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon_state = "lipstick"
	item_state = null //lipstick has no inhands...
	w_class = W_CLASS_TINY
	disguised = TRUE

/obj/item/weapon/grenade/chem_grenade/teargas/lipstick/examine(user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>On closer inspection, you realize that this is actually some form of grenade! The hidden label reads tear gas.</span>")
