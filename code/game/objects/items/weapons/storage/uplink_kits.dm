/obj/item/weapon/storage/box/syndicate/New(var/loc, var/list/conditions, var/forced_bundle)
	..()
	var/tagname
	if(!forced_bundle)
		tagname = pickweight(list("bloodyspai" = 100, "stealth" = 100, "screwed" = 25, "guns" = 100, "murder" = 100, "freedom" = 100, "hacker" = 100, "lordsingulo" = 25, "smoothoperator" = 100, "psycho" = 100, "hotline" = 100, "ocelot" = 100, "sith" = 100, "anarchist" = 50, "emagsandglue" = 10, "balloon" = 10, "bangerboy" = 100, "highlander" = 100, "clown" = 50, "druid" = 50, "actor" = 100, "jackpot" = 7, "Eugenics" = 50, "Alchemist" = 50))
	else
		tagname = forced_bundle

	switch (tagname)
		if("bloodyspai")//2+5+2+2+4+4+4=23
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			new /obj/item/weapon/dnascrambler(src)
			new /obj/item/weapon/dnascrambler(src)
			new /obj/item/weapon/dnascrambler(src)

		if("stealth")//12+8+6+1=27
			new /obj/item/weapon/gun/energy/crossbow(src)
			new /obj/item/weapon/pen/paralysis(src)
			new /obj/item/device/chameleon(src)
			new /obj/item/weapon/soap/syndie(src)

		if("screwed")//6?+6?+10+4=26
			new /obj/effect/spawner/newbomb/timer(src)
			new /obj/effect/spawner/newbomb/timer(src)
			new /obj/item/device/powersink(src)
			new /obj/item/clothing/suit/space/syndicate(src)
			new /obj/item/clothing/head/helmet/space/syndicate(src)

		if("guns")//13+4+6+4=27
			new /obj/item/weapon/gun/projectile/revolver(src)
			new /obj/item/ammo_storage/box/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/c4(src)

		if("murder")//8+6+6+2+4=26
			new /obj/item/weapon/melee/energy/sword(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			new /obj/item/weapon/storage/belt/skull(src)

		if("freedom")//18+5=23
			var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
			O.imp = new /obj/item/weapon/implant/freedom(O)
			O.update()
			O.name= "Freedom"
			var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
			U.imp = new /obj/item/weapon/implant/uplink(U)
			U.update()
			U.name = "Uplink"

		if("hacker")//14+6+5+3=28
			new /obj/item/weapon/aiModule/freeform/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			new /obj/item/device/multitool/ai_detect(src)

		if("lordsingulo")//14+4+6=24
			new /obj/item/beacon/syndicate(src)
			new /obj/item/clothing/suit/space/syndicate(src)
			new /obj/item/clothing/head/helmet/space/syndicate(src)
			new /obj/item/weapon/card/emag(src)

		if("smoothoperator")//6?+2+2?+1+1?+1?+4+4=21
			new /obj/item/weapon/gun/projectile/pistol(src)
			new /obj/item/gun_part/silencer(src)
			new /obj/item/clothing/gloves/knuckles/spiked(src)
			new /obj/item/weapon/soap/syndie(src)
			new /obj/item/weapon/storage/bag/trash(src)
			new /obj/item/bodybag(src)
			new /obj/item/clothing/under/suit_jacket(src)
			new /obj/item/clothing/shoes/laceup(src)
			new /obj/item/weapon/soap/syndie(src)
			new /obj/item/device/chameleon(src)
			new /obj/item/device/encryptionkey/syndicate/hacked(src)
			new /obj/item/weapon/c4(src)

		if("psycho")//1+1+5+2+6+(fireaxe, 6?)+2=23
			new /obj/item/clothing/suit/raincoat(src)
			new /obj/item/clothing/under/suit_jacket(src)
			new /obj/item/weapon/soap/syndie(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/newspaper(src)
			new /obj/item/weapon/fireaxe(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)

		if("hotline")//5+10+2+(hyperzine pills, 2x2?)=22
			new /obj/item/clothing/under/bikersuit(src)
			new /obj/item/clothing/head/helmet/biker(src)
			new /obj/item/clothing/shoes/mime/biker(src)
			new /obj/item/clothing/gloves/bikergloves(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver(src)
			new /obj/item/weapon/storage/pill_bottle/hyperzine(src)
			new /obj/item/weapon/storage/pill_bottle/hyperzine(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/soap/syndie(src)

		if("balloon")//20+20+20+20+20+20+20+20=160
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)
			new /obj/item/toy/syndicateballoon(src)

		if("ocelot")
			new /obj/item/weapon/gun/projectile/colt(src)
			new /obj/item/weapon/gun/projectile/colt(src)
			new /obj/item/ammo_storage/speedloader/a357(src)
			new /obj/item/clothing/mask/scarf/red(src)
			new /obj/item/clothing/under/color/black(src)
			new /obj/item/clothing/shoes/jackboots(src)
			new /obj/item/clothing/head/beret/sec/ocelot(src)
			new /obj/item/clothing/gloves/red(src)
			new /obj/item/clothing/accessory/storage/bandolier(src)

		if ("sith")
			if("plasmaman" in conditions) //General Veers, you're too close to me
				new /obj/item/weapon/melee/energy/sword/red(src)
				new /obj/item/weapon/spellbook/oneuse/bound_object(src)
				new /obj/item/clothing/head/helmet/space/plasmaman/sith(src)
				new /obj/item/clothing/suit/space/plasmaman/sith(src)
			else // It's treason then (8 + 8 + ? + ? + ? + ? + ? + ?)
				new /obj/item/weapon/melee/energy/sword/red(src) //He had like one saber when he went ballistic but you get it
				new /obj/item/weapon/melee/energy/sword/red(src) //Combine these into a double e-sword
				new /obj/item/weapon/dnainjector/nofail/telemut(src)
				new /obj/item/weapon/dnainjector/nofail/jumpy(src)
				new /obj/item/weapon/spellbook/oneuse/bound_object(src)
				new /obj/item/weapon/spellbook/oneuse/lightning/sith(src) //UNLIMITED POWER, requires wizard garb
				new /obj/item/clothing/head/sith(src)
				new /obj/item/clothing/suit/sith(src)
				new /obj/item/clothing/shoes/sandal(src)

		if("anarchist")//14+14+6=34, plus molotovs
			new /obj/item/weapon/implanter/traitor(src)
			new /obj/item/weapon/implanter/traitor(src)
			new /obj/item/clothing/mask/bandana/red(src)
			new /obj/item/clothing/mask/bandana/red(src)
			new /obj/item/clothing/mask/bandana/red(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/storage/box/syndie_kit/molotovs(src)

		if("emagsandglue")//(4+6+4+6+4+6+4)*5=memes
			new /obj/item/weapon/storage/box/syndie_kit/emags_and_glue(src)
			new /obj/item/weapon/storage/box/syndie_kit/emags_and_glue(src)
			new /obj/item/weapon/storage/box/syndie_kit/emags_and_glue(src)
			new /obj/item/weapon/storage/box/syndie_kit/emags_and_glue(src)
			new /obj/item/weapon/storage/box/syndie_kit/emags_and_glue(src)

		if("bangerboy")//5?*6+12+0+3?=45
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/grenade/flashbang/clusterbang(src)
			new /obj/item/weapon/gun/grenadelauncher(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/headset_earmuffs(src)

		if("highlander")//SCOTLAND
			new /obj/item/clothing/head/beret/highlander(src)
			new /obj/item/clothing/suit/highlanderkilt(src)
			new /obj/item/clothing/shoes/jackboots/highlander(src)
			new /obj/item/weapon/claymore(src)
			new /obj/item/weapon/glue(src)
			new /obj/item/weapon/vinyl/scotland(src)
			new /obj/item/weapon/spellbook/oneuse/mutate/highlander(src)

		if("clown") //4 + 4 + 6 + 14 + 6 + ? = 34?
			new /obj/item/weapon/invisible_spray/permanent(src)
			new /obj/item/weapon/glue(src)
			new /obj/item/weapon/glue(src)
			new /obj/item/weapon/gun/hookshot/whip/windup_box/clownbox(src)
			new /obj/item/weapon/dnainjector/nofail/clumsymut(src)
			for(var/i = 1 to 7)
				new /obj/item/toy/balloon/long/living(src)
			new /obj/item/weapon/spellbook/oneuse/shoesnatch(src)

		if("druid")	//bear*viscerator to the power of carp
			var/list/druidSummon = list(
					/obj/item/weapon/grenade/spawnergrenade/spesscarp,
					/obj/item/weapon/grenade/spawnergrenade/beenade,
					/obj/item/weapon/grenade/spawnergrenade/bearnade
					)
			for(var/i = 1 to 6)
				var/obj/item/dS = pick(druidSummon)
				new dS(src)
				new /obj/item/weapon/reagent_containers/food/snacks/egg/chaos(src)
			new /obj/item/clothing/suit/storage/wintercoat/druid(src)

		if("actor")	//6*5 + 1 + 5 + 2 + 6 + mask = 44^mask
			for(var/i = 1 to 5)
				new /obj/item/device/reportintercom(src)
			new /obj/item/device/megaphone/madscientist(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/mask/morphing/amorphous(src)
			new /obj/item/device/chameleon(src)


		if("jackpot") //14*2 = 28
			new /obj/item/weapon/storage/box/syndicate(src)
			new /obj/item/weapon/storage/box/syndicate(src)

		if("Eugenics")
			new /obj/item/weapon/dnainjector/nofail/hulkmut(src)
			new /obj/item/weapon/dnainjector/nofail/xraymut(src)
			new /obj/item/weapon/dnainjector/nofail/telemut(src)
			new /obj/item/weapon/dnainjector/nofail/nobreath(src)
			new /obj/item/weapon/dnainjector/nofail/regenerate(src)
			new /obj/item/weapon/dnainjector/nofail/runfast(src)
			new /obj/item/weapon/dnainjector/nofail/jumpy(src)
			new /obj/item/weapon/dnainjector/nofail/strong(src)

		if("Alchemist")
			new /obj/item/weapon/storage/bag/potion/lesser_predicted_potion_bundle(src)
			new /obj/item/weapon/storage/bag/potion/lesser_bundle(src)
			new /obj/item/weapon/storage/box/mystery_vial(src)
			new /obj/item/weapon/storage/box/mystery_vial(src)

	tag = tagname



/obj/item/weapon/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box."
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"
	items_to_spawn = list(/obj/item/weapon/implanter/freedom)

/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "box (C)"
	items_to_spawn = list(/obj/item/weapon/implanter/compressed)

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"
	items_to_spawn = list(/obj/item/weapon/implanter/explosive)

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"
	items_to_spawn = list(/obj/item/weapon/implanter/uplink)

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"
	items_to_spawn = list(
		/obj/item/clothing/suit/space/syndicate,
		/obj/item/clothing/head/helmet/space/syndicate,
	)

/obj/item/weapon/storage/box/syndie_kit/surveillance
	name = "box (S)"
	items_to_spawn = list(
		/obj/item/device/handtv,
		/obj/item/weapon/storage/box/surveillance,
	)

/obj/item/weapon/storage/box/syndie_kit/conversion
	name = "box (CK)"
	items_to_spawn = list(
		/obj/item/weapon/conversion_kit,
		/obj/item/ammo_storage/box/a357,
	)

/obj/item/weapon/storage/box/syndie_kit/greytide
	name = "box (GT)"
	items_to_spawn = list(
		/obj/item/weapon/implanter/traitor = 2,
		/obj/item/clothing/glasses/sunglasses/sechud/syndishades,
	)

/obj/item/weapon/storage/box/syndie_kit/boolets
	name = "Shotgun shells"
	items_to_spawn = list(/obj/item/ammo_casing/shotgun/fakebeanbag = 6)

/obj/item/weapon/storage/box/syndie_kit/ammo
	name = "box (spare ammo)"
	items_to_spawn = list(/obj/item/ammo_storage/speedloader/a357)

/obj/item/weapon/storage/box/syndie_kit/cheaptide
	name = "box (CT)"
	items_to_spawn = list(
		/obj/item/weapon/implanter/traitor,
		/obj/item/clothing/glasses/sunglasses/sechud/syndishades,
	)

/obj/item/weapon/storage/box/syndie_kit/flaregun
	name = "box (modified flare gun)"
	items_to_spawn = list(
		/obj/item/weapon/gun/projectile/flare/syndicate,
		/obj/item/ammo_storage/box/flare,
	)

/obj/item/weapon/storage/box/syndie_kit/explosive_hug
	name = "box (C)"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antisocial,
		/obj/item/weapon/reagent_containers/syringe,
	)

/obj/item/weapon/storage/box/syndie_kit/lethal_hyperzine
	name = "box (C)"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/glass/bottle/hypozine,
		/obj/item/weapon/reagent_containers/syringe,
	)

/obj/item/weapon/storage/box/syndie_kit/smokebombs
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	can_add_storageslots = TRUE
	can_only_hold = list("/obj/item/toy/snappop")
	items_to_spawn = list(/obj/item/toy/snappop/smokebomb = 8)

/obj/item/weapon/storage/box/syndie_kit/molotovs/
	name = "box (molotovs)"
	items_to_spawn = list(
		/obj/item/weapon/reagent_containers/food/drinks/molotov = 6,
		/obj/item/weapon/lighter/red,
	)

/obj/item/weapon/storage/box/syndie_kit/emags_and_glue/ //Exactly what it sounds like.
	name = "box (E&G)"
	items_to_spawn = list(
		/obj/item/weapon/glue = 4,
		/obj/item/weapon/card/emag = 3,
	)


//Syndicate Experimental Gear
//Contains unique gear not found anywhere else
/obj/item/weapon/storage/box/syndicate_experimental/New()
	..()
	var/selection = pick("damocles", "bomber vest", "bike horn")
	switch(selection)
		if("damocles")
			new /obj/item/weapon/damocles(src)
		if("bomber vest")
			new /obj/item/clothing/suit/bomber_vest(src)
		if("bike horn")
			new /obj/item/weapon/bikehorn/syndicate(src)

/obj/item/weapon/storage/box/syndie_kit/cratesender
	name = "box (CS)"
	items_to_spawn = list(
		/obj/item/device/telepad_beacon,
		/obj/item/weapon/rcs/salvage/syndicate,
	)


//Elite Syndicate Bundles
//for all of the team bundles

/obj/item/weapon/storage/box/syndie_kit/sniper
	name = "Sniper"
	items_to_spawn = list(
		/obj/item/device/radio/headset/headset_earmuffs/syndie,
		/obj/item/weapon/gun/projectile/hecate,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/ammo_storage/box/BMG50 = 3,
		/obj/item/clothing/glasses/thermal/syndi,
	)

/obj/item/weapon/storage/box/syndie_kit/spotter
	name = "Spotter"
	items_to_spawn = list(
		/obj/item/device/radio/headset/headset_earmuffs/syndie,
		/obj/item/binoculars,
		/obj/item/weapon/gun/projectile/deagle/camo,
		/obj/item/clothing/accessory/holster/handgun,
		/obj/item/ammo_storage/box/a50,
		/obj/item/clothing/glasses/thermal/syndi,
	)

/obj/item/weapon/storage/box/syndie_kit/scammer
	name = "Legitimate Businessman"
	items_to_spawn = list(
		/obj/item/clothing/mask/gas/voice,
		/obj/item/weapon/storage/briefcase/false_bottomed/smg,
		/obj/item/clothing/under/chameleon,
		/obj/item/clothing/shoes/syndigaloshes,
		/obj/item/weapon/card/id/syndicate,
		/obj/item/clothing/glasses/sunglasses/sechud/syndishades,
		/obj/item/device/reportintercom,
	)

/obj/item/weapon/storage/box/syndie_kit/scammer/New()
	..()
	dispense_cash(10000, src)

/obj/item/weapon/storage/box/syndie_kit/shootershotty
	name = "Shotgun"
	items_to_spawn = list(
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/gloves/neorussian/fingerless,
		/obj/item/clothing/under/sl_suit/armored,
		/obj/item/clothing/suit/armor/hos/jensen,
		/obj/item/clothing/glasses/sunglasses/prescription,
		/obj/item/clothing/head/beanie/black,
		/obj/item/clothing/accessory/storage/bandolier,
		/obj/item/weapon/gun/projectile/shotgun/pump/combat,
		/obj/item/weapon/storage/box/buckshotshells = 2,
		/obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel = 4,
	)

/obj/item/weapon/storage/box/syndie_kit/shooteruzis
	name = "Dual Uzis"
	items_to_spawn = list(
		/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/gloves/neorussian/fingerless,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/suit/armor/hos/jensen,
		/obj/item/clothing/glasses/sunglasses/prescription,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/weapon/gun/projectile/automatic/microuzi = 2,
		/obj/item/ammo_storage/box/c9mm = 4,
		/obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel = 4,
	)

/obj/item/weapon/storage/box/syndicate_team/New()
	..()
	var/team_kit = pick("sniperspotter", "scammers", "workplaceshooter")
	switch(team_kit)
		if("sniperspotter")
			new /obj/item/weapon/storage/box/syndie_kit/sniper(src)
			new /obj/item/weapon/storage/box/syndie_kit/spotter(src)

		if("scammers")
			new /obj/item/weapon/storage/box/syndie_kit/scammer(src)
			new /obj/item/weapon/storage/box/syndie_kit/scammer(src)

		if("workplaceshooter")
			new /obj/item/weapon/storage/box/syndie_kit/shootershotty(src)
			new /obj/item/weapon/storage/box/syndie_kit/shooteruzis(src)
