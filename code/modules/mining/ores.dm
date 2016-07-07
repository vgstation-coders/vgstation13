/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_type = RECYK_MISC
	var/material=null
	var/datum/geosample/geologic_data

/obj/item/weapon/ore/New()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 0)

/obj/item/weapon/ore/ex_act()
	return

/obj/item/weapon/ore/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 1)
	return w_type

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	material=MAT_URANIUM
	melt_temperature = 1070+T0C

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	material=MAT_IRON
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	material=MAT_GLASS
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/glass/attack_self(mob/living/user as mob) //It's magic I ain't gonna explain how instant conversion with no tool works. -- Urist
		var/location = get_turf(user)
		for(var/obj/item/weapon/ore/glass/sandToConvert in location)
			new /obj/item/stack/sheet/mineral/sandstone(location)
			qdel(sandToConvert)
		new /obj/item/stack/sheet/mineral/sandstone(location)
		qdel(src)

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "materials=2"
	material=MAT_PLASMA
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	material=MAT_SILVER
	melt_temperature = 961+T0C

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	material=MAT_GOLD
	melt_temperature = 1064+T0C

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	material=MAT_DIAMOND

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	material=MAT_CLOWN
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/phazon
	name = "Phazite"
	desc = "What the fuck?"
	icon_state = "Phazon ore"
	origin_tech = "materials=7"
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
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
	qdel(src)

/obj/item/weapon/ore/cerenkite/attack_hand(mob/user as mob)
	var/L = get_turf(user)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
	qdel(src)

/obj/item/weapon/ore/cerenkite/bullet_act(var/obj/item/projectile/P)
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
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
/obj/item/weapon/gibtonite
	name = "Gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = W_CLASS_LARGE
	throw_range = 0
	anchored = 1 //Forces people to carry it by hand, no pulling!
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	var/primed = 0
	var/det_time = 100
	var/quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher shipping_value = better

/obj/item/weapon/gibtonite/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator))
		GibtoniteReaction(user)
		return
	if(istype(I, /obj/item/device/mining_scanner) && primed)
		primed = 0
		user.visible_message("<span class='notice'>The chain reaction was stopped! ...The ore's quality went down.</span>")
		icon_state = "Gibtonite ore"
		quality = 1
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
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
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
				switch(quality)
					if(1)
						explosion(src.loc,-1,1,3,adminlog = notify_admins)
					if(2)
						explosion(src.loc,1,2,5,adminlog = notify_admins)
					if(3)
						explosion(src.loc,2,4,9,adminlog = notify_admins)
				qdel(src)
