/obj/item/weapon/storage/box/syndicate/New(var/loc, var/list/conditions, var/forced_bundle)
	..()
	var/tagname
	if(!forced_bundle)
		tagname = pickweight(list("bloodyspai" = 100, "stealth" = 100, "screwed" = 100, "guns" = 100, "murder" = 100, "freedom" = 100, "hacker" = 100, "lordsingulo" = 100, "smoothoperator" = 100, "psycho" = 100, "hotline" = 100, "ocelot" = 100, "sith" = 100, "anarchist" = 50, "emagsandglue" = 10, "balloon" = 10, "bangerboy" = 100, "highlander" = 100))
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

	tag = tagname


/obj/item/weapon/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box."
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"

/obj/item/weapon/storage/box/syndie_kit/imp_explosive/New()
	new /obj/item/weapon/implanter/explosive(src)
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()
	return

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	return

/obj/item/weapon/storage/box/syndie_kit/surveillance
	name = "box (S)"

/obj/item/weapon/storage/box/syndie_kit/surveillance/New()
	..()
	new /obj/item/device/handtv(src)
	new /obj/item/weapon/storage/box/surveillance(src)
	return

/obj/item/weapon/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/weapon/storage/box/syndie_kit/conversion/New()
	..()
	new /obj/item/weapon/conversion_kit(src)
	new /obj/item/ammo_storage/box/a357(src)
	return

/obj/item/weapon/storage/box/syndie_kit/greytide
	name = "box (GT)"

/obj/item/weapon/storage/box/syndie_kit/greytide/New()
	..()
	new /obj/item/weapon/implanter/traitor(src)
	new /obj/item/weapon/implanter/traitor(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/syndishades(src)

/obj/item/weapon/storage/box/syndie_kit/boolets
	name = "Shotgun shells"

/obj/item/weapon/storage/box/syndie_kit/boolets/New()
	..()
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
	new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/weapon/storage/box/syndie_kit/ammo
	name = "box (spare ammo)"

/obj/item/weapon/storage/box/syndie_kit/ammo/New()
	..()
	new /obj/item/ammo_storage/speedloader/a357(src)
	return

obj/item/weapon/storage/box/syndie_kit/cheaptide
	name = "box (CT)"

/obj/item/weapon/storage/box/syndie_kit/cheaptide/New()
	..()
	new /obj/item/weapon/implanter/traitor(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/syndishades(src)

/obj/item/weapon/storage/box/syndie_kit/flaregun
	name = "box (modified flare gun)"

/obj/item/weapon/storage/box/syndie_kit/flaregun/New()
	..()
	new /obj/item/weapon/gun/projectile/flare/syndicate(src)
	new /obj/item/ammo_storage/box/flare(src)
	return

/obj/item/weapon/storage/box/syndie_kit/explosive_hug
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/explosive_hug/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/antisocial(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	return

/obj/item/weapon/storage/box/syndie_kit/lethal_hyperzine
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/lethal_hyperzine/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/hypozine(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	return

/obj/item/weapon/storage/box/syndie_kit/smokebombs
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_only_hold = list("/obj/item/toy/snappop")

/obj/item/weapon/storage/box/syndie_kit/smokebombs/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/toy/snappop/smokebomb(src)

/obj/item/weapon/storage/box/syndie_kit/molotovs/
	name = "box (molotovs)"

/obj/item/weapon/storage/box/syndie_kit/molotovs/New()
	..()
	for(var/i = 1 to 6)
		new /obj/item/weapon/reagent_containers/food/drinks/molotov(src)
	new /obj/item/weapon/lighter/red(src)

/obj/item/weapon/storage/box/syndie_kit/emags_and_glue/ //Exactly what it sounds like.
	name = "box (E&G)"

/obj/item/weapon/storage/box/syndie_kit/emags_and_glue/New()
	..()
	new /obj/item/weapon/glue(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/weapon/glue(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/weapon/glue(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/weapon/glue(src)
	return


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

/obj/item/weapon/storage/box/syndie_kit/cratesender/New()
	..()
	new /obj/item/device/telepad_beacon(src)
	new /obj/item/weapon/rcs/salvage/syndicate(src)


//Elite Syndicate Bundles
//for all of the team bundles

/obj/item/weapon/storage/box/syndie_kit/sniper
	name = "Sniper"

/obj/item/weapon/storage/box/syndie_kit/sniper/New()
	..()
	new /obj/item/device/radio/headset/headset_earmuffs/syndie(src)
	new /obj/item/weapon/gun/projectile/hecate(src)
	new /obj/item/clothing/accessory/storage/webbing(src)
	new /obj/item/ammo_storage/box/BMG50(src)
	new /obj/item/ammo_storage/box/BMG50(src)
	new /obj/item/ammo_storage/box/BMG50(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)
	
/obj/item/weapon/storage/box/syndie_kit/spotter
	name = "Spotter"

/obj/item/weapon/storage/box/syndie_kit/spotter/New()
	..()
	new /obj/item/device/radio/headset/headset_earmuffs/syndie(src)
	new /obj/item/binoculars(src)
	new /obj/item/weapon/gun/projectile/deagle/camo(src)
	new /obj/item/clothing/accessory/holster/handgun(src)
	new /obj/item/ammo_storage/box/a50(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)

/obj/item/weapon/storage/box/syndie_kit/scammer
	name = "Legitimate Businessman"

/obj/item/weapon/storage/box/syndie_kit/scammer/New()
	..()
	new /obj/item/clothing/mask/gas/voice(src)
	new /obj/item/weapon/storage/briefcase/false_bottomed/smg(src)
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/shoes/syndigaloshes(src)
	new /obj/item/weapon/card/id/syndicate(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/syndishades(src)
	new /obj/item/device/reportintercom(src)
	dispense_cash(10000, src)
	
/obj/item/weapon/storage/box/syndie_kit/shootershotty
	name = "Shotgun"

/obj/item/weapon/storage/box/syndie_kit/shootershotty/New()
	..()
	new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/gloves/neorussian/fingerless(src)
	new /obj/item/clothing/under/sl_suit/armored(src)
	new /obj/item/clothing/suit/armor/hos/jensen(src)
	new /obj/item/clothing/glasses/sunglasses/prescription(src)
	new /obj/item/clothing/head/beanie/black(src)
	new /obj/item/clothing/accessory/storage/bandolier(src)
	new /obj/item/weapon/gun/projectile/shotgun/pump/combat(src)
	new /obj/item/weapon/storage/box/buckshotshells(src)
	new /obj/item/weapon/storage/box/buckshotshells(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)

/obj/item/weapon/storage/box/syndie_kit/shooteruzis
	name = "Dual Uzis"

/obj/item/weapon/storage/box/syndie_kit/shooteruzis/New()
	..()
	new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/gloves/neorussian/fingerless(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/suit/armor/hos/jensen(src)
	new /obj/item/clothing/glasses/sunglasses/prescription(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/clothing/accessory/storage/webbing(src)
	new /obj/item/weapon/gun/projectile/automatic/microuzi(src)
	new /obj/item/weapon/gun/projectile/automatic/microuzi(src)
	new /obj/item/ammo_storage/box/c9mm(src)
	new /obj/item/ammo_storage/box/c9mm(src)
	new /obj/item/ammo_storage/box/c9mm(src)
	new /obj/item/ammo_storage/box/c9mm(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)
	new /obj/item/weapon/grenade/iedcasing/preassembled/withshrapnel(src)

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
