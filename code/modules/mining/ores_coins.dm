/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	singular_name = "piece of "
	irregular_plural = "pieces of "
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_type = RECYK_MISC
	max_amount = 100
	var/datum/geosample/geologic_data
	var/can_orebox = TRUE

/obj/item/stack/ore/New()
	singular_name += name
	irregular_plural += name
	..()

/obj/item/stack/ore/recycle(var/datum/materials/rec)
	if(!materials)
		return NOT_RECYCLABLE

	return ..()

/obj/item/stack/ore/uranium
	name = "\improper uranium ore"
	icon_state = "Uranium ore"
	origin_tech = Tc_MATERIALS + "=5"
	melt_temperature = 1070+T0C
	starting_materials = list(MAT_URANIUM = CC_PER_SHEET_URANIUM)

/obj/item/stack/ore/iron
	name = "\improper iron ore"
	icon_state = "Iron ore"
	origin_tech = Tc_MATERIALS + "=1"
	melt_temperature = MELTPOINT_STEEL
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)

/obj/item/stack/ore/glass
	name = "\improper sand"
	icon_state = "Glass ore"
	origin_tech = Tc_MATERIALS + "=1"
	melt_temperature = MELTPOINT_GLASS
	slot_flags = SLOT_POCKET
	throw_range = 1 //It just scatters to the ground as soon as you throw it.
	starting_materials = list(MAT_GLASS = CC_PER_SHEET_GLASS)

/obj/item/stack/ore/glass/cave
	name = "cave sand"
	icon_state = "cavesand"

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom)
	//Intentionally not calling ..()
	var/turf/T //turf to extinguish
	if(isturf(hit_atom))
		if(!locate(/obj/effect/decal/cleanable/scattered_sand) in hit_atom)
			new/obj/effect/decal/cleanable/scattered_sand(hit_atom)
		T = hit_atom
		qdel(src)
	else if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if (H.check_body_part_coverage(EYES))
			to_chat(H, "<span class='warning'>Your eyewear protects you from \the [src]!</span>")
		else
			H.visible_message("<span class='warning'>[H] is blinded by the [src]!</span>", \
				"<span class='warning'>\The [src] flies into your eyes!</span>")
			H.eye_blurry = max(H.eye_blurry, rand(3,8))
			H.eye_blind = max(H.eye_blind, rand(1,3))
			H.drop_hands(get_turf(H))
		log_attack("<font color='red'>[hit_atom] ([H ? H.ckey : "what"]) was pocketsanded by ([src.fingerprintslast])</font>")
	else
		T = get_turf(hit_atom)

	if(T)
		for(var/atom/atm in T) //extinguishing things
			if(isliving(atm)) // For extinguishing mobs on fire
				var/mob/living/M = atm
				M.extinguish()
			if(atm.on_fire) // For extinguishing objects on fire
				atm.extinguish()

/obj/item/stack/ore/glass/New(var/loc, var/amount=null)
	recipes = sand_recipes
	..()

/obj/item/stack/ore/plasma
	name = "\improper plasma ore"
	icon_state = "Plasma ore"
	origin_tech = Tc_MATERIALS + "=2"
	melt_temperature = MELTPOINT_STEEL+500
	starting_materials = list(MAT_PLASMA = CC_PER_SHEET_PLASMA)

/obj/item/stack/ore/nanotrasite
	name = "\improper nanotrasite ore"
	icon_state = "Nanotrasite ore"
	origin_tech = Tc_MATERIALS + "=3"
	melt_temperature = MELTPOINT_STEEL+700
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL/2, MAT_PLASMA = CC_PER_SHEET_PLASMA/2)

/obj/item/stack/ore/silver
	name = "\improper silver ore"
	icon_state = "Silver ore"
	origin_tech = Tc_MATERIALS + "=3"
	starting_materials = list(MAT_SILVER = CC_PER_SHEET_SILVER)
	melt_temperature = 961+T0C

/obj/item/stack/ore/gold
	name = "\improper gold ore"
	icon_state = "Gold ore"
	origin_tech = Tc_MATERIALS + "=4"
	starting_materials = list(MAT_GOLD = CC_PER_SHEET_GOLD)
	melt_temperature = 1064+T0C

/obj/item/stack/ore/electrum
	name = "\improper electrum ore"
	icon_state = "Electrum ore"
	starting_materials = list(MAT_GOLD = CC_PER_SHEET_MISC*0.6, MAT_SILVER = CC_PER_SHEET_MISC*0.4)
	origin_tech = Tc_MATERIALS + "=4"
	melt_temperature = 1023.22+T0C //60% gold, 40% silver

/obj/item/stack/ore/diamond
	name = "\improper diamond ore"
	icon_state = "Diamond ore"
	origin_tech = Tc_MATERIALS + "=6"
	starting_materials = list(MAT_DIAMOND = CC_PER_SHEET_DIAMOND)

/obj/item/stack/ore/clown
	name = "\improper bananium ore"
	icon_state = "Clown ore"
	origin_tech = Tc_MATERIALS + "=4"
	melt_temperature = MELTPOINT_POTASSIUM
	starting_materials = list(MAT_CLOWN = CC_PER_SHEET_CLOWN)

/obj/item/stack/ore/phazon
	name = "\improper phazite"
	desc = "What the fuck?"
	icon_state = "Phazon ore"
	origin_tech = Tc_MATERIALS + "=7"
	melt_temperature = MELTPOINT_GLASS
	starting_materials = list(MAT_PHAZON = CC_PER_SHEET_PHAZON)

/obj/item/stack/ore/slag
	name = "\improper slag"
	desc = "Completely useless unless recycled."
	icon_state = "slag"
	melt_temperature=MELTPOINT_PLASTIC
	can_orebox = FALSE

	// melt_temperature is automatically adjusted.

	var/datum/materials/mats=new

/obj/item/stack/ore/slag/recycle(var/datum/materials/rec)
	if(mats.getVolume() == 1)
		return NOT_RECYCLABLE

	rec.addFrom(mats) // NOT removeFrom.  Some things just check for the return value.
	return RECYK_MISC

/obj/item/stack/ore/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"
	starting_materials = list(MAT_MAUXITE = CC_PER_SHEET_MAUXITE)

/obj/item/stack/ore/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"
	starting_materials = list(MAT_MOLITZ = CC_PER_SHEET_MOLITZ)

/obj/item/stack/ore/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"
	starting_materials = list(MAT_PHAROSIUM = CC_PER_SHEET_PHAROSIUM)

// Common Cluster Ores

/obj/item/stack/ore/cobryl
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	starting_materials = list(MAT_COBRYL = CC_PER_SHEET_COBRYL)

/obj/item/stack/ore/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	starting_materials = list(MAT_CHAR = CC_PER_SHEET_CHAR)
// Rare Vein Ores

/obj/item/stack/ore/claretine
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"
	starting_materials = list(MAT_CLARETINE = CC_PER_SHEET_CLARETINE)
/obj/item/stack/ore/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"
	starting_materials = list(MAT_BOHRUM = CC_PER_SHEET_BOHRUM)
/obj/item/stack/ore/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	starting_materials = list(MAT_SYRELINE = CC_PER_SHEET_SYRELINE)
// Rare Cluster Ores

/obj/item/stack/ore/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"
	starting_materials = list(MAT_EREBITE = CC_PER_SHEET_EREBITE)
/obj/item/stack/ore/erebite/ex_act()
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/stack/ore/erebite/bullet_act(var/obj/item/projectile/P)
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/stack/ore/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	icon_state = "cerenkite"
	starting_materials = list(MAT_CERENKITE = CC_PER_SHEET_CERENKITE)

/obj/item/stack/ore/cerenkite/ex_act()
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/stack/ore/cerenkite/attack_hand(mob/user as mob)
	var/L = get_turf(user)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/stack/ore/cerenkite/bullet_act(var/obj/item/projectile/P)
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/stack/ore/cytine
	name = "cytine"
	desc = "A glowing Cytine gemstone, somewhat valuable but not paticularly useful."
	icon_state = "cytine"
	starting_materials = list(MAT_CYTINE = CC_PER_SHEET_CYTINE)
/obj/item/stack/ore/cytine/New()
	..()
	color = pick("#FF0000","#0000FF","#008000","#FFFF00")

/obj/item/stack/ore/cytine/attack_hand(mob/user as mob)
	var/obj/item/weapon/glowstick/G = new /obj/item/weapon/glowstick(user.loc)
	G.color = color
	G.light_color = color
	qdel(src)

/obj/item/stack/ore/uqill
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	icon_state = "uqill"
	starting_materials = list(MAT_UQILL = CC_PER_SHEET_UQILL)

/obj/item/stack/ore/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"
	starting_materials = list(MAT_TELECRYSTAL = CC_PER_SHEET_TELECRYSTAL)

/obj/item/stack/ore/mythril
	name = "\improper mythril ore"
	desc = "A naturally-occuring silver steel alloy."
	icon_state = "cobryl"
	starting_materials = list(MAT_MYTHRIL = CC_PER_SHEET_MYTHRIL)

/obj/item/weapon/gibtonite
	name = "Gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = W_CLASS_LARGE
	throw_range = 0
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	var/primed = 0
	var/det_time = 100
	var/det_quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher shipping_value = better

/obj/item/weapon/gibtonite/can_be_pulled()
	return FALSE

/obj/item/weapon/gibtonite/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator))
		GibtoniteReaction(user)
		return
	if(istype(I, /obj/item/device/mining_scanner) && primed)
		primed = 0
		user.visible_message("<span class='notice'>The chain reaction was stopped! ...The ore's quality went down.</span>")
		icon_state = "Gibtonite ore"
		det_quality = 1
		return
	..()

/obj/item/weapon/gibtonite/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/bullet))
		GibtoniteReaction(P.firer)
	..()

/obj/item/weapon/gibtonite/ex_act()
	GibtoniteReaction(triggered_by_explosive = 1)

/obj/item/weapon/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by_explosive = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/notify_admins = 0
		if(z != map.zAsteroid)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1
		if(notify_admins)
			if(triggered_by_explosive)
				message_admins("An explosion has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
		if(triggered_by_explosive)
			log_game("An explosion has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		else
			user.visible_message("<span class='warning'>[user] strikes the [src], causing a chain reaction!</span>")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		spawn(det_time)
			if(primed)
				switch(det_quality)
					if(1)
						explosion(src.loc,-1,1,3,adminlog = notify_admins)
					if(2)
						explosion(src.loc,1,2,5,adminlog = notify_admins)
					if(3)
						explosion(src.loc,2,4,9,adminlog = notify_admins)
				qdel(src)



/obj/item/stack/ore/New(var/loc, var/amount=null)
	. = ..()
	pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8, 0) * PIXEL_MULTIPLIER

/obj/item/stack/ore/ex_act()
	return

/obj/item/stack/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()

/obj/item/stack/ore/attempt_heating(atom/A, mob/user)
	var/temperature = A.is_hot()
	if(temperature && temperature > melt_temperature)
		var/list/recipes = list()
		for(var/recipe in typesof(/datum/smelting_recipe) - /datum/smelting_recipe)
			recipes += new recipe()
		for(var/datum/smelting_recipe/R in recipes)
			while(R.checkIngredients(materials)) //While we have materials for this
				for(var/ore_id in R.ingredients)
					materials.removeAmount(ore_id, R.ingredients[ore_id]) //arg1 = ore name, arg2 = how much per sheet
					score.oremined += 1 //Count this ore piece as processed for the scoreboard
					if(istype(loc,/obj/structure/forge))
						drop_stack(R.yieldtype,loc.loc)
					else
						drop_stack(R.yieldtype,loc)
		qdel(src)

/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/coins.dmi'
	name = "coin"
	desc = "Long phased out in favor of galactic credits."
	icon_state = "coin"
	flags = FPRINT
	siemens_coefficient = 1
	force = 1
	throwforce = 1
	w_class = W_CLASS_TINY
	w_type = RECYK_METAL
	quick_equip_priority = list(slot_wear_id)
	var/string_attached
	var/material=MAT_IRON // Ore ID, used with coinbags.
	var/credits = 0 // How many credits is this coin worth?

/obj/item/weapon/coin/New()
	. = ..()
	pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8, 0) * PIXEL_MULTIPLIER
	add_component(/datum/component/coinflip)
	if (prob(1))
		// Something about this coin stands out...
		luckiness_validity = LUCKINESS_WHEN_GENERAL_RECURSIVE
		overlays += image('icons/obj/items.dmi', "shine")
		if (prob(20))
			// Sometimes it's very lucky!
			luckiness = 500 * credits
		else
			// But most of the time, it's just our imagination.
			luckiness = 0


/obj/item/weapon/coin/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 0.2 * get_material_cc_per_sheet(material)) // 5 coins per sheet.
	return w_type

/obj/item/weapon/coin/is_screwdriver(var/mob/user)
	if(user.a_intent == I_HURT)
		to_chat(user, "<span class='warning'>You forcefully press with \the [src]!</span>")
	return user.a_intent == I_HURT

/obj/item/weapon/coin/gold
	material=MAT_GOLD
	name = "gold coin"
	desc = "Worth its weight in gold!"
	icon_state = "coin_gold"
	credits = 0.4
	melt_temperature=1064+T0C
	siemens_coefficient = 1.3

/obj/item/weapon/coin/silver
	material=MAT_SILVER
	name = "silver coin"
	desc = "Not worth a lot, but it sure is shiny."
	icon_state = "coin_silver"
	credits = 0.3
	melt_temperature=961+T0C
	siemens_coefficient = 1

/obj/item/weapon/coin/diamond
	material=MAT_DIAMOND
	name = "diamond coin"
	desc = "A girl's second-best friend!"
	icon_state = "coin_diamond"
	credits = 1
	siemens_coefficient = 0.1

/obj/item/weapon/coin/iron
	material=MAT_IRON
	name = "iron coin"
	desc = "Practically worthless, even for a coin."
	icon_state = "coin_iron"
	credits = 0.01
	melt_temperature=MELTPOINT_STEEL
	siemens_coefficient = 1

/obj/item/weapon/coin/plasma
	material=MAT_PLASMA
	name = "solid plasma coin"
	desc = "Not worth a lot, but safer to handle than raw plasma."
	icon_state = "coin_plasma"
	credits = 0.04
	melt_temperature=MELTPOINT_STEEL+500
	siemens_coefficient = 0.6

/obj/item/weapon/coin/uranium
	material=MAT_URANIUM
	name = "uranium coin"
	desc = "A heavy coin that is always warm to the touch."
	icon_state = "coin_uranium"
	force = 2
	throwforce = 2
	credits = 0.2
	melt_temperature=1070+T0C
	siemens_coefficient = 0.5

/obj/item/weapon/coin/clown
	material=MAT_CLOWN
	name = "bananium coin"
	desc = "A funny, rare coin minted from pure banana essence. Honk!"
	icon_state = "coin_clown"
	credits = 10
	melt_temperature=MELTPOINT_GLASS
	siemens_coefficient = 0.5

/obj/item/weapon/coin/phazon
	material=MAT_PHAZON
	name = "phazon coin"
	icon_state = "coin_phazon"
	desc = "You're not sure how much this is worth, considering the constantly warping engravings."
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/phazon/New()
	siemens_coefficient = rand(0,200) / 100
	credits = rand(1,1000)

/obj/item/weapon/coin/adamantine
	material="adamantine"
	name = "adamantine coin"
	icon_state = "coin_adamantine"
	desc = "An expensive coin minted long ago from extremely rare, hard, super-conductive metal."
	force = 3
	throwforce = 3
	siemens_coefficient = 3
	credits = 1000

/obj/item/weapon/coin/mythril
	material=MAT_MYTHRIL
	name = "mythril coin"
	desc = "An expensive coin minted long ago from extremely rare, light, non-conductive metal."
	icon_state = "coin_mythril"
	credits = 1000
	siemens_coefficient = 0

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='notice'>There already is a string attached to this [name].</span>")
			return

		if(CC.amount <= 0)
			to_chat(user, "<span class='notice'>This cable coil appears to be empty.</span>")
			QDEL_NULL(CC)
			return

		overlays += image('icons/obj/coins.dmi',"coin_string_overlay")
		string_attached = 1
		to_chat(user, "<span class='notice'>You attach a string to \the [name].</span>")
		CC.use(1)
	else if(W.is_wirecutter(user))
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from \the [name].</span>")
	else
		..()

/obj/item/weapon/coin/examine(mob/user)
	..()
	if(!isnull(luckiness))
		to_chat(user, "<span class='notice'>Something is [pick("peculiar", "exceptional", "interesting")] about it...</span>")

///////////////////////////////////////////////////////////

/obj/item/weapon/coin/pomf
	material="pomf"
	name = "pomf coin"
	desc = "A platinum coin featuring the effigy of a white chicken. Few know of its true value. Fewer still can make use of it."
	icon_state = "coin_pomf"
	credits = 2525
	siemens_coefficient = 1
	melt_temperature=1768+T0C
	force = 4
	throwforce = 4

/obj/item/weapon/coin/pumf
	material="pumf"
	name = "pumf coin"
	desc = "A slade coin featuring the effigy of an angry chicken. If it comes into your possession that means you've been a naughty boy. Whatever you've been doing stop it."
	icon_state = "coin_pumf"
	credits = -2525 // that's probably a very bad idea but I want to see what happens
	siemens_coefficient = 1
	melt_temperature=9999+T0C
	force = 4
	throwforce = 4

///////////////////////////////////////////////////////////

/obj/item/weapon/coin/nuka
	material=MAT_IRON
	name = "bottle cap"
	desc = "Standard Nuka-Cola bottle cap featuring 21 crimps and ridges, and somehow more or less matching the shape of a coin."
	icon_state = "bottle_cap"
	credits = 0.01
	siemens_coefficient = 1
	melt_temperature=MELTPOINT_STEEL
	force = 0
	throwforce = 0
	throw_range = 3
