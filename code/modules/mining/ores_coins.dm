/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_type = RECYK_MISC
	var/material=null
	var/datum/geosample/geologic_data

/obj/item/weapon/ore/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 1)
	return w_type

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = Tc_MATERIALS + "=5"
	material=MAT_URANIUM
	melt_temperature = 1070+T0C

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = Tc_MATERIALS + "=1"
	material=MAT_IRON
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = Tc_MATERIALS + "=1"
	material=MAT_GLASS
	melt_temperature = MELTPOINT_GLASS
	slot_flags = SLOT_POCKET
	throw_range = 1 //It just scatters to the ground as soon as you throw it.

/obj/item/weapon/ore/glass/cave
	name = "cave sand"
	icon_state = "cavesand"

/obj/item/weapon/ore/glass/throw_impact(atom/hit_atom)
	//Intentionally not calling ..()
	if(isturf(hit_atom))
		if(!locate(/obj/effect/decal/cleanable/scattered_sand) in hit_atom)
			new/obj/effect/decal/cleanable/scattered_sand(hit_atom)
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

/obj/item/weapon/ore/glass/attack_self(mob/living/user as mob) //It's magic I ain't gonna explain how instant conversion with no tool works. -- Urist
	var/location = get_turf(user)
	for(var/obj/item/weapon/ore/glass/sandToConvert in location)
		drop_stack(/obj/item/stack/sheet/mineral/sandstone, location, 1, user)
		qdel(sandToConvert)

	drop_stack(/obj/item/stack/sheet/mineral/sandstone, location, 1, user)
	qdel(src)

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = Tc_MATERIALS + "=2"
	material=MAT_PLASMA
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = Tc_MATERIALS + "=3"
	material=MAT_SILVER
	melt_temperature = 961+T0C

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = Tc_MATERIALS + "=4"
	material=MAT_GOLD
	melt_temperature = 1064+T0C

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = Tc_MATERIALS + "=6"
	material=MAT_DIAMOND

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = Tc_MATERIALS + "=4"
	material=MAT_CLOWN
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/phazon
	name = "Phazite"
	desc = "What the fuck?"
	icon_state = "Phazon ore"
	origin_tech = Tc_MATERIALS + "=7"
	material=MAT_PHAZON
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless unless recycled."
	icon_state = "slag"
	melt_temperature=MELTPOINT_PLASTIC

	// melt_temperature is automatically adjusted.

	var/datum/materials/mats=new

/obj/item/weapon/ore/slag/recycle(var/datum/materials/rec)
	if(mats.getVolume() == 1)
		return NOT_RECYCLABLE

	rec.addFrom(mats) // NOT removeFrom.  Some things just check for the return value.
	return RECYK_MISC

/obj/item/weapon/ore/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"
	material="mauxite"
/obj/item/weapon/ore/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"
	material="molitz"
/obj/item/weapon/ore/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"
	material="pharosium"
// Common Cluster Ores

/obj/item/weapon/ore/cobryl
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	material="cobryl"
/obj/item/weapon/ore/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	material="char"
// Rare Vein Ores

/obj/item/weapon/ore/claretine
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"
	material="claretine"
/obj/item/weapon/ore/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"
	material="bohrum"
/obj/item/weapon/ore/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	material="syreline"
// Rare Cluster Ores

/obj/item/weapon/ore/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"
	material="erebite"
/obj/item/weapon/ore/erebite/ex_act()
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/weapon/ore/erebite/bullet_act(var/obj/item/projectile/P)
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/weapon/ore/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	icon_state = "cerenkite"
	material="cerenkite"

/obj/item/weapon/ore/cerenkite/ex_act()
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/weapon/ore/cerenkite/attack_hand(mob/user as mob)
	var/L = get_turf(user)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/weapon/ore/cerenkite/bullet_act(var/obj/item/projectile/P)
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_radiation((rand(10, 50)), RAD_EXTERNAL)
	qdel(src)

/obj/item/weapon/ore/cytine
	name = "cytine"
	desc = "A glowing Cytine gemstone, somewhat valuable but not paticularly useful."
	icon_state = "cytine"
	material="cytine"
/obj/item/weapon/ore/cytine/New()
	..()
	color = pick("#FF0000","#0000FF","#008000","#FFFF00")

/obj/item/weapon/ore/cytine/attack_hand(mob/user as mob)
	var/obj/item/weapon/glowstick/G = new /obj/item/weapon/glowstick(user.loc)
	G.color = color
	G.light_color = color
	qdel(src)

/obj/item/weapon/ore/uqill
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	icon_state = "uqill"
	material="uqill"
/obj/item/weapon/ore/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"
	material="telecrystal"

/obj/item/weapon/ore/mythril
	name = "mythril ore"
	desc = "A naturally-occuring silver steel alloy."
	icon_state = "cobryl"
	material=MAT_MYTHRIL

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



/obj/item/weapon/ore/New()
	. = ..()
	pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8, 0) * PIXEL_MULTIPLIER

/obj/item/weapon/ore/ex_act()
	return

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()

/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT
	siemens_coefficient = 1
	force = 0.0
	throwforce = 0.0
	w_class = W_CLASS_TINY
	var/string_attached
	var/material=MAT_IRON // Ore ID, used with coinbags.
	var/credits = 0 // How many credits is this coin worth?

/obj/item/weapon/coin/New()
	. = ..()
	pixel_x = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_y = rand(-8, 0) * PIXEL_MULTIPLIER

/obj/item/weapon/coin/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 0.2) // 5 coins per sheet.
	return w_type

/obj/item/weapon/coin/gold
	material=MAT_GOLD
	name = "Gold coin"
	icon_state = "coin_gold"
	credits = 5
	melt_temperature=1064+T0C

/obj/item/weapon/coin/silver
	material=MAT_SILVER
	name = "Silver coin"
	icon_state = "coin_silver"
	credits = 1
	melt_temperature=961+T0C

/obj/item/weapon/coin/diamond
	material=MAT_DIAMOND
	name = "Diamond coin"
	icon_state = "coin_diamond"
	credits = 25

/obj/item/weapon/coin/iron
	material=MAT_IRON
	name = "Iron coin"
	icon_state = "coin_iron"
	credits = 0.01
	melt_temperature=MELTPOINT_STEEL

/obj/item/weapon/coin/plasma
	material=MAT_PLASMA
	name = "Solid plasma coin"
	icon_state = "coin_plasma"
	credits = 0.1
	melt_temperature=MELTPOINT_STEEL+500

/obj/item/weapon/coin/uranium
	material=MAT_URANIUM
	name = "Uranium coin"
	icon_state = "coin_uranium"
	credits = 25
	melt_temperature=1070+T0C

/obj/item/weapon/coin/clown
	material=MAT_CLOWN
	name = "Bananaium coin"
	icon_state = "coin_clown"
	credits = 1000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/phazon
	material=MAT_PHAZON
	name = "Phazon coin"
	icon_state = "coin_phazon"
	credits = 2000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/adamantine
	material="adamantine"
	name = "Adamantine coin"
	icon_state = "coin_adamantine"

/obj/item/weapon/coin/mythril
	material="mythril"
	name = "Mythril coin"
	icon_state = "coin_mythril"

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='notice'>There already is a string attached to this coin.</span>")
			return

		if(CC.amount <= 0)
			to_chat(user, "<span class='notice'>This cable coil appears to be empty.</span>")
			qdel(CC)
			CC = null
			return

		overlays += image('icons/obj/items.dmi',"coin_string_overlay")
		string_attached = 1
		to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		CC.use(1)
	else if(istype(W,/obj/item/weapon/wirecutters) )
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	else
		..()
