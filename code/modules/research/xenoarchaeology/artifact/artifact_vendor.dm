var/static/list/okstuff2putin = list(
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
)

var/static/list/badstuff2putin = list(
	SACID,
	PACID,
	RADIUM,
	CHLORALHYDRATE,
	STOXIN,
	TOXIN,
	PHAZON,
	SIMPOLINOL,
	WATER,
	INSECTICIDE,
	PLANTBGONE,
	CONDENSEDCAPSAICIN,
	CAPSAICIN,
	ETHANOL,
	IMPEDREZENE,
	DIAMONDDUST,
	MOONROCKS,
	IRRADIATEDBEANS,
	TOXICWASTE,
	MUTATEDBEANS,
	MOONROCKS,
	GLOWINGRAMEN,
	CHEESYGLOOP,
	MINDBREAKER,
	ZAMSPICYTOXIN,
	CHARCOAL,
	SALTWATER,
	VOMIT,
	LIQUIDPCP,
	CYANIDE,
)

/obj/machinery/vending/artifact
	name = "mysterious snack vendor"
	desc = "A vending machine containing snacks, drinks and other assorted products."
	icon_state = "Cola_Machine"
	icon_vend = "Cola_Machine-vend"
	vend_delay = 50
	mech_flags = MECH_SCAN_FAIL
	var/total_uses = 0
	var/time_active = 0
	var/list/safeStock = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy = 8,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating = 10,
		/obj/item/weapon/reagent_containers/food/snacks/chips = 20,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 30,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 35,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 8,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 30,
		/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped = 75,
		/obj/item/weapon/reagent_containers/food/snacks/magbites = 110,
		/obj/item/weapon/storage/fancy/cigarettes/gum = 10,
		/obj/item/weapon/storage/pill_bottle/lollipops = 10,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine = 100,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola = 50,
	)
	var/list/insultingStock = list(
		/obj/item/weapon/grenade/iedcasing/preassembled/artifact,
		/obj/item/weapon/grenade/chem_grenade/artifact,
		/obj/item/weapon/reagent_containers/food/snacks/egg/chaos/instahatch,
		/obj/machinery/apiary/wild/angry/hornet,
		/obj/machinery/apiary/wild/angry,
	)

/obj/machinery/vending/artifact/New()
	..()
	decideStock()

/obj/machinery/vending/artifact/proc/decideStock()
	products.Cut()
	prices.Cut()
	if(extended_inventory || emagged || arcanetampered)
		if(prob(50)/(total_uses+1))
			buildDangerousStock()
		else
			buildInsultingStock()
	else
		switch(total_uses)
			if(0 to 2)
				buildSafeStock()
			if(3 to 6)
				if(prob(50/(total_uses-2)))
					buildSafeStock()
				else
					buildDubiousStock()
			if(7 to INFINITY)
				if(prob(50/(total_uses-2)))
					buildSafeStock()
				else if(prob(50/(total_uses-6)))
					buildDubiousStock()
				else
					buildDangerousStock()
	build_inventories()

/obj/machinery/vending/artifact/vend(datum/data/vending_product/R, mob/user, by_voucher = 0)
	..()
	total_uses++
	decideStock()

/obj/machinery/vending/artifact/process()
	..()
	if(total_uses)
		time_active++
		if(time_active % 30 == 0)
			total_uses-- // usage cooldown, one every minute or so
			time_active = 0
			decideStock()

/obj/machinery/vending/artifact/on_return_coin_detect(mob/user)
	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			speak(vend_reply, user)
			last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	src.updateUsrDialog()
	visible_message("\The [src.name] whirrs as it vends.", "You hear a whirr.")
	spawn(vend_delay)
		var/path2use = pick(insultingStock)
		if(arcanetampered && prob(90))
			path2use = /obj/item/weapon/bikehorn/rubberducky  // BONUS DUCKS! refunds
		new path2use(get_turf(src))
		src.vend_ready = 1
		update_vicon()
		src.updateUsrDialog()
	return 1

/obj/machinery/vending/artifact/build_inventories()
	..()
	for(var/datum/data/vending_product/R in product_records)
		R.product_name = "Unknown" //obscure it a lil

/obj/machinery/vending/artifact/proc/buildSafeStock()
	for(var/i in 1 to rand(6, 18))
		var/theStock = rand(1, safeStock.len)
		var/chosenStock = prob(67) ? safeStock[theStock] : pick(subtypesof(/obj/item/weapon/reagent_containers/food/snacks/chips))
		products.Add(chosenStock)
		prices.Add(chosenStock)
		prices[chosenStock] = (chosenStock in safeStock) ? rand(safeStock[chosenStock] * 0.7, safeStock[chosenStock] * 1.3) : rand(5,35)

/obj/machinery/vending/artifact/proc/buildDubiousStock()
	for(var/i in 1 to rand(6, 18))
		var/chosenStock = pick(/obj/item/weapon/reagent_containers/food/snacks/artifact,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact)
		products.Add(chosenStock)
		prices.Add(chosenStock)
		prices[chosenStock] = rand(10,70)

/obj/machinery/vending/artifact/proc/buildDangerousStock()
	for(var/i in 1 to rand(6, 18))
		var/chosenStock = pick(/obj/item/weapon/reagent_containers/food/snacks/artifact/bad,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/bad)
		products.Add(chosenStock)
		prices.Add(chosenStock)
		prices[chosenStock] = rand(20,140)

/obj/machinery/vending/artifact/proc/buildInsultingStock()
	for(var/i in 1 to rand(6, 18))
		var/chosenStock = pick(insultingStock)
		products.Add(chosenStock)
		prices.Add(chosenStock)
		prices[chosenStock] = rand(70,130)

/obj/machinery/vending/artifact/crowbarDestroy(mob/user, obj/item/tool/crowbar/C)
	to_chat(user,"<span class='warning'>There is no circuitboard to pry out???</span>")
	extended_inventory = TRUE

/obj/item/weapon/reagent_containers/food/snacks/artifact
	name = "alien snack"
	desc = "A strange long lost brand of snack. You're not sure if this even ever existed."
	var/list/stuff2putin = list()

/obj/item/weapon/reagent_containers/food/snacks/artifact/New(loc)
	..(loc)
	name = generate_weird_stock_name()
	if(!stuff2putin || !stuff2putin.len)
		stuff2putin = okstuff2putin.Copy()
	var/type = /obj/item/weapon/reagent_containers/food/drinks/soda_cans
	var/static/list/picks = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating,
		/obj/item/weapon/reagent_containers/food/snacks/chips,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped,
		/obj/item/weapon/reagent_containers/food/snacks/magbites,
	)
	type = pick(picks)
	var/obj/item/weapon/reagent_containers/food/snacks/icon2build = type
	icon_state = initial(icon2build.icon_state)
	var/divisor = rand(1,10)
	for(var/i in 1 to divisor)
		reagents.add_reagent(pick(stuff2putin), volume/divisor)

/obj/item/weapon/reagent_containers/food/snacks/artifact/bad/New()
	stuff2putin = badstuff2putin.Copy()
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact
	name = "alien drink"
	desc = "A strange long lost brand of drink. You're not sure if this even ever existed."
	var/list/stuff2putin = list()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/New(loc)
	volume = rand(1,6)*50 // 50-300
	..(loc)
	name = generate_weird_stock_name()
	if(!stuff2putin || !stuff2putin.len)
		stuff2putin = okstuff2putin.Copy()
	var/type = /obj/item/weapon/reagent_containers/food/snacks
	var/static/list/picks = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola,
	)
	type = pick(picks)
	var/obj/item/weapon/reagent_containers/food/drinks/soda_cans/icon2build = type
	icon_state = initial(icon2build.icon_state)
	var/static/list/blocked = list(
		/datum/reagent/drink,
		/datum/reagent/drink/cold,
	)
	var/list/things_can_add = existing_typesof(/datum/reagent/drink) - blocked
	var/list/things2add
	for(var/addtype in things_can_add)
		var/datum/reagent/R = addtype
		things2add += list(list(initial(R.id)))
	var/divisor = rand(1,10)
	for(var/i in 1 to divisor)
		reagents.add_reagent(pick(stuff2putin), volume/(divisor*2))
		if(prob(75))
			reagents.add_reagent(pick(things2add), volume/(divisor*2))

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/bad/New()
	stuff2putin = badstuff2putin.Copy()
	..()

/obj/item/weapon/grenade/chem_grenade/artifact/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	switch(rand(1,10))
		if(1)
			B1.reagents.add_reagent(POTASSIUM,50) // boom
			B2.reagents.add_reagent(WATER,50)
		if(2)
			var/thing2smoke = pick(SACID,PACID,CAPSAICIN,CONDENSEDCAPSAICIN,WATER,PLANTBGONE,MUTAGEN,INSECTICIDE) // smonkd
			B1.reagents.add_reagent(SUGAR,5)
			B1.reagents.add_reagent(POTASSIUM,5)
			B1.reagents.add_reagent(thing2smoke,40)
			B2.reagents.add_reagent(PHOSPHORUS,5)
			B2.reagents.add_reagent(thing2smoke,45)
		if(3)
			B1.reagents.add_reagent(IRON,50) // emp
			B2.reagents.add_reagent(URANIUM,50)
		if(4)
			B1.reagents.add_reagent(VAPORSALT, 50) // plasmaflubb
			B2.reagents.add_reagent(OXYGEN, 25)
			B2.reagents.add_reagent(PLASMA, 25)
		if(5)
			B1.reagents.add_reagent(FLUOROSURFACTANT, 40) // slip
			B1.reagents.add_reagent(LUBE, 10)
			B2.reagents.add_reagent(WATER, 40)
			B2.reagents.add_reagent(LUBE, 10)
		if(6)
			B1.reagents.add_reagent(pick(FLOUR,RADIUM,BLOOD,CARBON,FUEL), 50) // mess
			B2.reagents.add_reagent(pick(FLOUR,RADIUM,BLOOD,CARBON,FUEL), 50)
		if(7)
			B1.reagents.add_reagent(ALUMINUM, 25) // fire
			B2.reagents.add_reagent(PLASMA, 25)
			B2.reagents.add_reagent(SACID, 25)
		if(8)
			B1.reagents.add_reagent(ALUMINUM, 25) // flash
			B2.reagents.add_reagent(POTASSIUM, 25)
			B2.reagents.add_reagent(SULFUR, 25)
		if(9)
			B1.reagents.add_reagent(BLEACH,50) // a good idea
			B2.reagents.add_reagent(AMMONIA,50)
		//if(10)
		//  be a dud and do nothing

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"
	activate()

/obj/item/weapon/grenade/iedcasing/preassembled/artifact/New()
	..()
	active = 1
	overlays -= image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
	icon_state = initial(icon_state) + "_active"
	assembled = 3
	for(var/i = 1 to rand(3,8))
		var/list/possibleShrapnel = list(
			/obj/item/trash/plate,
			/obj/item/weapon/shard/plasma,
			/obj/item/weapon/shard/shrapnel,
			/obj/item/weapon/shard,
			/obj/item/weapon/kitchen/utensil/fork,
			/obj/item/weapon/kitchen/utensil/fork/plastic,
			/obj/item/weapon/kitchen/utensil/knife,
			/obj/item/weapon/kitchen/utensil/knife/plastic,
			/obj/item/weapon/kitchen/utensil/knife/large,
			/obj/item/stack/rods,
			/obj/item/stack/tile/metal,
			/obj/item/stack/tile/metal/plasteel,
		)
		var/item2shrapnel = pick(possibleShrapnel)
		var/atom/movable/A = new item2shrapnel(src)
		shrapnel_list.Add(A)
		current_shrapnel++
		if(current_shrapnel >= max_shrapnel)
			break //More of a safety, already sometimes breaking the laws of IED
	spawn(det_time)
		if(!gcDestroyed)
			prime()

/proc/generate_weird_stock_name()
	var/name = capitalize(pick(pick(first_names_male,first_names_female,wizard_first,ninja_names,last_names,ai_names,hologram_names)))
	var/adjective = capitalize(pick(adjectives))
	var/alliterative_adjective = "Discount"
	while(uppertext(copytext(alliterative_adjective,1,2)) != uppertext(copytext(name,1,2)))
		alliterative_adjective = capitalize(pick(adjectives))
	var/verb1 = capitalize(pick(verbs))
	var/verb2 = pick(verbs)
	var/verb3 = capitalize(pick(verbs))
	return "\improper \
		[prob(50) ? "[prob(10) ? "[alliterative_adjective] " : ""][name][prob(80) ? "'s" : pick("Co","Corp","Pro","Mart","More","Way"," Bro's"," & Co")] " : ""]\
		[prob(50) ? "[adjective] " : ""][verb1][prob(20) ? verb2 : ""][prob(20) ? " of [verb3]" : ""][prob(5) ? "!" : ""]"
