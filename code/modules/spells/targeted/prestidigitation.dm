/spell/targeted/spark
	name = "Spark"
	desc = "Creates a spark in the targeted location."
	abbreviation = "SP"

	school = "evocation"
	invocation = "M'tch st'ck"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "sparks"

/spell/targeted/spark/cast(var/list/targets, mob/user)
	for(var/A in targets)
		var/turf/T = get_turf(A)
		spark(T)

/spell/targeted/clean
	name = "Clean item"
	desc = "Applies magic soap to a piece of clothing."
	abbreviation = "CI"

	school = "evocation"
	invocation = "s'ap s'ds"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "soap"

/spell/targeted/clean/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.clean_blood()
		if(isitem(A))
			var/obj/item/I = A
			I.decontaminate()


/spell/targeted/unclean
	name = "Bloody item"
	desc = "Drops an item into the realm of blood for just a moment, covering it in ichor."
	abbreviation = "BI"

	school = "evocation"
	invocation = "bl'odso'k"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "blood"

/spell/targeted/unclean/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.add_blood(user)


/spell/targeted/color_change
	name = "Change color"
	desc = "Applies magic coloration to an item or surface."
	abbreviation = "CC"

	school = "evocation"
	invocation = "Wh't 'f 't w's p'rpl'?!"
	invocation_type = SpI_WHISPER
	range = 6
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "color_change"

/spell/targeted/color_change/cast(var/list/targets, mob/user)
	var/color_hex = pick("#FF0000", "#FF6A00", "#FFD800", "#B6FF00", "#4CFF00", "#00FF21", "#00FF90", "#00FFFF", "#0094FF", "#0026FF", "#4800FF", "#B200FF", "#FF00DC", "#FF006E", "#FF7F7F", "#FFB27F", "#FFE97F", "#DAFF7F", "#A5FF7F", "#7FFF8E", "#7FFFC5", "#7FFFFF", "#7FC9FF", "#7F92FF", "#A17FFF", "#D67FFF", "#FF7FED", "#FF7FB6", "null")
	for(var/atom/A in targets)
		A.color = color_hex

/spell/targeted/create_trinket
	name = "Create temporary trinket"
	desc = "Creates a small trinket for a duration."
	abbreviation = "CT"

	school = "evocation"
	invocation = "Id'e h'nds m'k' l'ght w'rk"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER
	level_max = list()
	hud_state = "coin"

/spell/targeted/create_trinket/cast(var/list/targets, mob/user) // Sorry for what I must yabba dabba do
	var/static/list/trinkets_coin = existing_typesof(/obj/item/weapon/coin)-list(/obj/item/weapon/coin/trader, /obj/item/weapon/coin/adamantine)
	var/static/list/trinkets_card = existing_typesof(/obj/item/weapon/card)+existing_typesof(/obj/item/toy/singlecard)-list(/obj/item/weapon/card/id/admin, /obj/item/weapon/card/id/centcom/nt_supreme, /obj/item/weapon/card/emag)
	var/static/list/trinkets_grenade = existing_typesof(/obj/item/weapon/grenade)-list(/obj/item/weapon/grenade, /obj/item/weapon/grenade/spawnergrenade, /obj/item/weapon/grenade/iedcasing)
	var/static/list/trinkets_toy = list(/obj/item/clothing/mask/facehugger/toy, /obj/item/toy/waterballoon, /obj/item/toy/syndicateballoon, /obj/item/toy/syndicateballoon/ntballoon, /obj/item/toy/spinningtoy, /obj/item/toy/gun, /obj/item/toy/ammo/gun, /obj/item/toy/ammo/crossbow, /obj/item/toy/crossbow, /obj/item/toy/bomb, /obj/item/toy/snappop, /obj/item/toy/snappop/smokebomb, /obj/item/toy/waterflower, /obj/item/toy/minimeteor, /obj/item/toy/canary, /obj/item/toy/balloon, /obj/item/toy/crayon/rainbow, /obj/item/weapon/toy/xmas_cracker, /obj/item/weapon/boomerang/toy, /obj/item/toy/gasha/wizard, /obj/item/toy/figure/wizard)
	var/static/list/trinkets_bullet = existing_typesof(/obj/item/ammo_casing)-list(/obj/item/ammo_casing)
	var/static/list/trinkets_accessory = existing_typesof(/obj/item/clothing/accessory/medal)+existing_typesof(/obj/item/clothing/accessory/tie)+existing_typesof(/obj/item/clothing/accessory/armband)-list(/obj/item/clothing/accessory/tie, /obj/item/clothing/accessory/armband)
	var/static/list/trinkets_gadget = list(/obj/item/device/radio, /obj/item/device/radio/headset, /obj/item/device/pda, /obj/item/device/t_scanner, /obj/item/device/t_scanner/advanced, /obj/item/device/healthanalyzer, /obj/item/device/gps, /obj/item/device/lightreplacer, /obj/item/device/flash, /obj/item/device/flash/synthetic, /obj/item/device/analyzer, /obj/item/device/antibody_scanner, /obj/item/device/camera, /obj/item/device/robotanalyzer, /obj/item/device/taperecorder, /obj/item/device/reagent_scanner/adv, /obj/item/device/megaphone, /obj/item/device/device_analyser, /obj/item/device/flashlight, /obj/item/device/multitool, /obj/item/device/hailer, /obj/item/weapon/hand_tele, /obj/item/weapon/pinpointer, /obj/item/weapon/cell/crap, /obj/item/weapon/barcodescanner, /obj/item/weapon/autopsy_scanner, /obj/item/beacon, /obj/item/device/debugger, /obj/item/device/mining_scanner, /obj/item/device/detective_scanner, /obj/item/device/instrument/instrument_synth, /obj/item/device/geiger_counter)
	var/static/list/trinkets_widget = list(/obj/item/tool/wirecutters, /obj/item/tool/wirecutters/clippers, /obj/item/weapon/switchtool, /obj/item/weapon/switchtool/engineering, /obj/item/weapon/switchtool/surgery, /obj/item/weapon/switchtool/switchblade, /obj/item/tool/solder, /obj/item/tool/scalpel, /obj/item/tool/screwdriver, /obj/item/weapon/pen, /obj/item/weapon/razor, /obj/item/weapon/minihoe, /obj/item/weapon/match/strike_anywhere, /obj/item/weapon/lipstick, /obj/item/weapon/lighter/random, /obj/item/weapon/lighter/zippo, /obj/item/weapon/hair_dye, /obj/item/weapon/hand_labeler, /obj/item/weapon/handcuffs, /obj/item/tool/FixOVein, /obj/item/weapon/legcuffs, /obj/item/weapon/legcuffs/bolas, /obj/item/weapon/paper, /obj/item/taperoll/atmos, /obj/item/airbag, /obj/item/weapon/chisel, /obj/item/weapon/bananapeel, /obj/item/weapon/thermometer)+existing_typesof(/obj/item/key)-list(/obj/item/key, /obj/item/key/lightcycle)
	var/static/list/trinkets_bauble = list(/obj/item/weapon/vectorreceiver, /obj/item/weapon/virusdish, /obj/item/weapon/shard, /obj/item/weapon/shard/plasma, /obj/item/weapon/ribbon, /obj/item/weapon/pai_cable, /obj/item/weapon/gavelblock, /obj/item/weapon/dart_cartridge, /obj/item/stack/chains, /obj/item/stack/teeth, /obj/item/stack/teeth/gold, /obj/item/gun_part/silencer, /obj/item/ice_crystal, /obj/item/claypot, /obj/item/cross_guard, /obj/item/sword_handle, /obj/item/weapon/dice/d00, /obj/item/weapon/dice/d10, /obj/item/weapon/dice/d12, /obj/item/weapon/dice/d2, /obj/item/weapon/dice/d20, /obj/item/weapon/dice/d4, /obj/item/weapon/dice/d8, /obj/item/weapon/dice/loaded/d20)+existing_typesof(/obj/item/stack/ore)+existing_typesof(/obj/item/ornament)-list(/obj/item/stack/ore)
	var/list/categories = list("Coin", "Card", "Toy", "Accessory", "Gadget", "Grenade", "Widget", "Bauble", "Bullet")
	var/item_choice = null
	var/duration = 300
	var/cat_choice = input("Select a kind of 'trinket'.") in categories | null
	switch(cat_choice)
		if(null)
			return 0
		if("Coin")
			item_choice = pick(trinkets_coin)
		if("Card")
			item_choice = pick(trinkets_card)
			duration = 200
		if("Grenade")
			item_choice = pick(trinkets_grenade)
			duration = 100
		if("Toy")
			item_choice = pick(trinkets_toy)
			duration = 600
		if("Bullet")
			item_choice = pick(trinkets_bullet)
			duration = 200
		if("Accessory")
			item_choice = pick(trinkets_accessory)
			duration = 1800
		if("Gadget")
			item_choice = pick(trinkets_gadget)
			duration = 1200
		if("Widget")
			item_choice = pick(trinkets_widget)
			duration = 1200
		if("Bauble")
			item_choice = pick(trinkets_bauble)
			duration = 1800
	var/obj/item/I = new item_choice
	user.put_in_hands(I)
	spawn(duration)
		if(istype(I.loc, /mob/living))
			var/mob/living/L = I.loc
			L.drop_item(I, force_drop = 1)
		qdel(I)

/spell/targeted/warm_object
	name = "Warm object"
	desc = "Warms an object."
	abbreviation = "WO"

	school = "evocation"
	invocation = "sp'cy k'ych'in"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "gen_immolate"

/spell/targeted/warm_object/cast(var/list/targets, mob/user)
	for(var/obj/item/I in targets)
		var/atom/fake_heater/FH = new /atom/fake_heater()
		I.attempt_heating(FH, user)
		I.process_temperature()
		qdel(FH)

/atom/fake_heater
	name = "fake heater"

/atom/fake_heater/is_hot()
	return 250

/atom/fake_heater/thermal_energy_transfer()
	return 3500

/spell/targeted/cool_object
	name = "Cool object"
	desc = "Cools an object."
	abbreviation = "WO"

	school = "evocation"
	invocation = "I'ce c'ld!"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "gen_ice"

/spell/targeted/cool_object/cast(var/list/targets, mob/user)
	for(var/obj/item/I in targets)
		var/atom/fake_cooler/FH = new /atom/fake_cooler()
		I.attempt_heating(FH, user)
		qdel(FH)

/atom/fake_cooler
	name = "fake cooler"

/atom/fake_cooler/is_hot()
	return -50

/atom/fake_cooler/thermal_energy_transfer()
	return -1500

/spell/targeted/extinguish
	name = "Extinguish"
	desc = "Extinguishes an object."
	abbreviation = "EO"

	school = "evocation"
	invocation = "Splash"
	invocation_type = SpI_WHISPER
	range = 4
	spell_flags = INCLUDEUSER|WAIT_FOR_CLICK
	level_max = list()
	hud_state = "extinguisher"

/spell/targeted/extinguish/cast(var/list/targets, mob/user)
	for(var/atom/A in targets)
		A.extinguish()
