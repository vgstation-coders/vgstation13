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
	HONKSERUM,
	AMINOMICIN,
	AMINOBLATELLA,
)

var/static/list/badstuff2putin = list(
	SACID,
	PACID,
	RADIUM,
	CHLORALHYDRATE,
	STOXIN,
	TOXIN,
	URANIUM,
	PHAZON,
	SIMPOLINOL,
	WATER,
	INSECTICIDE,
	PLANTBGONE,
	CONDENSEDCAPSAICIN,
	CAPSAICIN,
	ETHANOL,
	MERCURY,
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
	HEARTBREAKER,
	LEXORIN,
	PLASMA,
	ZAMSPICYTOXIN,
	CHARCOAL,
	SALTWATER,
	VOMIT,
	LIQUIDPCP,
	CYANIDE,
	NANITES,
	AUTISTNANITES,
	MUTAGEN,
	UNTABLE_MUTAGEN,
	ZOMBIEPOWDER,
	AMINOCYPRINIDOL,
	BICARODYNE,
	HYPOZINE,
)

// Mysterious vending machines, inspired by SCP-261: https://scp-wiki.wikidot.com/scp-261

/obj/machinery/vending/artifact
	name = "mysterious snack vendor"
	desc = "A vending machine containing snacks, drinks and other assorted products. Insert coin to activate."
	icon_state = "artifact"
	icon_vend = "artifact-vend"
	vend_delay = 50
	mech_flags = MECH_SCAN_FAIL
	use_power = MACHINE_POWER_USE_NONE // works unpowered
	var/total_uses = 0
	var/time_active = 0
	var/insulted = FALSE
	var/list/safeStock = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy = 5,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating = 5,
		/obj/item/weapon/reagent_containers/food/snacks/chips = 5,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 5,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 5,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 5,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 5,
		/obj/item/weapon/reagent_containers/food/snacks/magbites = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grandpatiks = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bustanuts = 1,
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating = 1,
		/obj/item/weapon/cell/crap/worse = 1, // shows up in the SCP so why not here too sometimes
		/obj/item/weapon/storage/fancy/cigarettes/gum = 5,
		/obj/item/weapon/storage/pill_bottle/lollipops = 5,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine = 1,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins = 3,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable = 5,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar = 5,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno = 3,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear = 3,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist = 3,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 5,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 5,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb = 5,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist = 5,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up = 5,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola = 3,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink = 3,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink = 3,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko = 1,
	)
	var/list/dubiousStock = list(
		/obj/item/weapon/reagent_containers/food/snacks/danitos = 1,
		/obj/item/weapon/reagent_containers/food/drinks/discount_ramen = 1,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito = 1,
		/obj/item/weapon/reagent_containers/food/snacks/pie/discount = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zamitos = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/wrapped = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zambiscuit = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/wrapped = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins = 1,
		/obj/item/weapon/reagent_containers/food/snacks/zamitos_stokjerky = 1,
		/obj/item/weapon/reagent_containers/food/snacks/oldempirebar = 1,
		/obj/item/weapon/reagent_containers/food/snacks/syndicake = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown = 1,
		/obj/item/weapon/reagent_containers/food/drinks/groans = 1,
		/obj/item/weapon/reagent_containers/food/drinks/filk = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_humanhydrator = 1,
		/obj/item/weapon/reagent_containers/food/drinks/zam_nitrofreeze = 1,
		/obj/item/weapon/reagent_containers/glass/bottle/pcp = 1,
		/obj/item/weapon/reagent_containers/food/snacks/artifact = 12,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact = 12,
	)
	var/list/dangerousStock = list(
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy = 1,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_polytrinicpalooza = 1,
		/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 1,
		/obj/item/weapon/reagent_containers/food/snacks/artifact/bad = 4,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/bad = 4,
	)
	var/list/insultingStock = list(
		/obj/item/weapon/grenade/iedcasing/preassembled/artifact = 4,
		/obj/item/weapon/grenade/chem_grenade/artifact = 2,
		/obj/item/weapon/reagent_containers/food/snacks/egg/chaos/instahatch = 1,
		/obj/machinery/apiary/wild/angry/hornet = 1,
		/obj/machinery/apiary/wild/angry = 4,
	)

/obj/machinery/vending/artifact/New()
	..()
	build_inventories()

/obj/machinery/vending/artifact/vend(datum/data/vending_product/R, mob/user, by_voucher = 0)
	total_uses++
	..()
	build_inventories()

/obj/machinery/vending/artifact/throw_item()
	total_uses++
	..()
	build_inventories()

/obj/machinery/vending/artifact/emag_act(mob/user)
	. = ..()
	build_inventories()

/obj/machinery/vending/artifact/arcane_act(mob/user)
	. = ..()
	build_inventories()

/obj/machinery/vending/artifact/malfunction()
	var/lost_inventory = rand(1,12)
	insulted = TRUE
	while(lost_inventory>0)
		throw_item()
		lost_inventory--
	stat |= BROKEN
	update_icon()

/obj/machinery/vending/artifact/process()
	..()
	if(total_uses)
		time_active++
		if(time_active % 30 == 0)
			total_uses-- // usage cooldown, one every minute or so
			time_active = 0
			if(total_uses < 3)
				insulted = FALSE
			build_inventories()
	else if(insulted)
		insulted = FALSE

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
		var/path2use = pickweight(insultingStock)
		if(arcanetampered && prob(90))
			path2use = /obj/item/weapon/bikehorn/rubberducky  // BONUS DUCKS! refunds
		new path2use(get_turf(src))
		src.vend_ready = 1
		update_icon()
		src.updateUsrDialog()
	return 1

/obj/machinery/vending/artifact/build_inventories()
	premium.Cut()
	for(var/i in 1 to rand(6, 18))
		if(extended_inventory || emagged || arcanetampered || insulted)
			if(prob(50)/(total_uses+1))
				premium.Add(pickweight(dangerousStock))
			else
				premium.Add(pickweight(insultingStock))
		else
			switch(total_uses)
				if(0 to 2)
					if(!powered(power_check_anyways = TRUE))
						premium.Add(pickweight(dubiousStock))
					else
						premium.Add(pickweight(safeStock))
				if(3 to 6)
					if(powered(power_check_anyways = TRUE) && prob(50/(total_uses-2)))
						premium.Add(pickweight(safeStock))
					else if(!powered(power_check_anyways = TRUE) && prob(50/(total_uses-2)))
						premium.Add(pickweight(dangerousStock))
					else
						premium.Add(pickweight(dubiousStock))
				if(7 to INFINITY)
					if(powered(power_check_anyways = TRUE) && prob(50/(total_uses-2)))
						premium.Add(pickweight(safeStock))
					else if(powered(power_check_anyways = TRUE) && prob(50/(total_uses-6)))
						premium.Add(pickweight(dubiousStock))
					else
						premium.Add(pickweight(dangerousStock))
	..()
	for(var/datum/data/vending_product/R in coin_records)
		R.product_name = "Unknown" //obscure it a lil

/obj/machinery/vending/artifact/crowbarDestroy(mob/user, obj/item/tool/crowbar/C)
	to_chat(user,"<span class='warning'>There is no circuitboard to pry out???</span>")
	if(!extended_inventory)
		extended_inventory = TRUE
		build_inventories()

/obj/item/weapon/reagent_containers/food/snacks/artifact
	name = "alien snack"
	desc = "A strange long lost brand of snack. You're not sure if this even ever existed."
	var/list/stuff2putin = list()
	var/list/objs2putin = list(
		/obj/item/toy/gasha = 0,
		/obj/item/weapon/coin = 0,
		/obj/item/weapon/cartridge = 0,
		/obj/item/weapon/spacecash = 0,
		/obj/item/tool = 0,
		/obj/item/weapon/kitchen/utensil = 0,
		/mob/living/simple_animal/mouse/common = 1,
		/mob/living/simple_animal/cockroach = 1,
		/mob/living/simple_animal/cricket = 1,
	)
	var/objprob = 10
	flags = FPRINT  | NOREACT | SILENTCONTAINER

/obj/item/weapon/reagent_containers/food/snacks/artifact/New(loc)
	..(loc)
	if(!stuff2putin || !stuff2putin.len)
		stuff2putin = okstuff2putin.Copy()
	var/type = /obj/item/weapon/reagent_containers/food/drinks/soda_cans
	var/static/list/picks = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy,
		/obj/item/weapon/reagent_containers/food/snacks/chips,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/weapon/reagent_containers/food/snacks/magbites,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger,
		/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins,
		/obj/item/weapon/reagent_containers/food/snacks/danitos,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito,
		/obj/item/weapon/reagent_containers/food/snacks/pie/discount,
		/obj/item/weapon/reagent_containers/food/snacks/zamitos,
		/obj/item/weapon/reagent_containers/food/snacks/zam_mooncheese/wrapped,
		/obj/item/weapon/reagent_containers/food/snacks/zambiscuit,
		/obj/item/weapon/reagent_containers/food/snacks/zam_spiderslider/wrapped,
		/obj/item/weapon/reagent_containers/food/snacks/zam_notraisins,
		/obj/item/weapon/reagent_containers/food/snacks/zamitos_stokjerky,
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate,
	)
	if(prob(75))
		var/desc_string = ""
		var/name_string = ""
		for(var/pick in picks)
			var/obj/item/weapon/reagent_containers/food/snacks/S = pick
			name_string += "[initial(S.name)] "
			desc_string += "[initial(S.desc)] "
		name = prob(50) ? generate_weird_stock_name() : "\improper [markov_chain(name_string, rand(2,3), rand(8,16))]"
		desc = prob(75) ? "[capitalize(markov_chain(desc_string, rand(2,5), rand(10,30)))]." : desc
	type = pick(picks)
	var/obj/item/weapon/reagent_containers/food/snacks/icon2build = type
	icon_state = initial(icon2build.icon_state)
	var/divisor = rand(1,10)
	for(var/i in 1 to divisor)
		reagents.add_reagent(pick(stuff2putin), volume/divisor)
	if(prob(objprob))
		for(var/i in rand(objprob/10,(objprob*3)/10))
			var/objpath = pick(objs2putin)
			objpath = objs2putin[objpath] ? pick(existing_typesof(objpath)) : pick(subtypesof(objpath))
			new objpath(src)

/obj/item/weapon/reagent_containers/food/snacks/artifact/bad
	objs2putin = list(
		/mob/living/simple_animal/hostile/giant_spider/spiderling = 1,
		/mob/living/simple_animal/hostile/carp/baby = 1,
		/mob/living/simple_animal/bee/angry = 1,
		/mob/living/simple_animal/bee/hornetgun = 1,
		/mob/living/simple_animal/hostile/viscerator = 1,
		/obj/item/supermatter_splinter = 1,
	)
	objprob = 20

/obj/item/weapon/reagent_containers/food/snacks/artifact/bad/New()
	stuff2putin = badstuff2putin.Copy()
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact
	name = "alien drink"
	desc = "A strange long lost brand of drink. You're not sure if this even ever existed."
	var/list/stuff2putin = list()
	flags = FPRINT  | OPENCONTAINER | NOREACT | SILENTCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/New(loc)
	volume = rand(1,6)*50 // 50-300
	..(loc)
	if(!stuff2putin || !stuff2putin.len)
		stuff2putin = okstuff2putin.Copy()
	var/type = /obj/item/weapon/reagent_containers/food/drinks/soda_cans
	var/static/list/picks = list(
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/mannsdrink,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_humanhydrator,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy,
		/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_polytrinicpalooza,
	)
	if(prob(75))
		var/desc_string = ""
		var/name_string = ""
		for(var/pick in picks)
			var/obj/item/weapon/reagent_containers/food/drinks/soda_cans/S = pick
			name_string += "[initial(S.name)] "
			desc_string += "[initial(S.desc)] "
		name = prob(50) ? generate_weird_stock_name() : "\improper [markov_chain(name_string, rand(2,3), rand(8,16))]"
		desc = prob(75) ? "[capitalize(markov_chain(desc_string, rand(2,5), rand(10,30)))]." : desc
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
		things2add += list(initial(R.id))
	var/divisor = rand(1,10)
	for(var/i in 1 to divisor)
		reagents.add_reagent(pick(stuff2putin), (volume-1)/(divisor*2))
		if(prob(75))
			reagents.add_reagent(pick(things2add), volume/(divisor*2))
	reagents.add_reagent(BLACKCOLOR,1)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/artifact/bad/New()
	stuff2putin = badstuff2putin.Copy()
	..()

/obj/item/weapon/grenade/chem_grenade/artifact
	path = PATH_STAGE_CONTAINER_INSERTED
	stage = GRENADE_STAGE_COMPLETE

/obj/item/weapon/grenade/chem_grenade/artifact/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	switch(rand(1,10))
		if(1)
			B1.reagents.add_reagent(POTASSIUM,50) // boom
			B2.reagents.add_reagent(WATER,50)
		if(2)
			var/thing2smoke = pick(SACID,PACID,CAPSAICIN,CONDENSEDCAPSAICIN,WATER,PLANTBGONE,MUTAGEN,INSECTICIDE,UNTABLE_MUTAGEN) // smonkd
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
		if(10)
			B1.reagents.add_reagent(NOTHING,0) // dud

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
	var/name = capitalize(pick(pick(first_names_male,first_names_female,last_names)))
	var/adjective = capitalize(pick(adjectives))
	var/alliterative = ""
	if(uppertext(copytext(name,1,2)) != "X") // only letter not in adjectives
		while(uppertext(copytext(alliterative,1,2)) != uppertext(copytext(name,1,2)))
			alliterative = capitalize(pick(adjectives))
	var/verb1 = capitalize(pick(verbs))
	var/verb2 = pick(verbs)
	var/verb3 = capitalize(pick(verbs))
	return "\improper \
		[prob(50) ? "[prob(10) && alliterative != "" ? "[alliterative] " : ""][name][prob(80) ? "'s" : pick("Co","Corp","Pro","Mart","More","Way"," Bro's"," & Co")] " : ""]\
		[prob(50) ? "[adjective] " : ""][verb1][prob(20) ? verb2 : ""][prob(20) ? " of [verb3]" : ""][prob(5) ? "!" : ""]"
