//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Xenoarchaeological finds

/datum/find
	var/find_ID //What the ID of this find is. EG ARCHAEO_CLAYMORE, ARCHAEO_FOSSIL, etc.
	var/excavation_required = 0		//random 5-95%
	var/view_range = 20				//how close excavation has to come to show an overlay on the turf
	var/clearance_range = 3			//how close excavation has to come to extract the item
									//if excavation hits var/excavation_required exactly, it's contained find is extracted cleanly without the ore
	var/responsive_reagent = PLASMA
	var/apply_material_decorations = FALSE
	var/apply_image_decorations = FALSE
	var/material_descriptor = ""
	var/apply_prefix = TRUE
	var/talkative = FALSE
	var/additional_desc = FALSE
	var/anomaly_factor = 1
	var/item_type

/datum/find/New(var/exc_req)
	excavation_required = exc_req
	clearance_range = rand(2,6)

/datum/find/proc/create_find(var/atom/loc) //Makes the item. Applies strangeness to it. Returns item
	if(prob(5))
		talkative = TRUE
	var/obj/item/weapon/I = spawn_item()
	if(apply_prefix)
		apply_prefix(I)
	if(apply_material_decorations)
		apply_material_decorations(I)
	if(apply_image_decorations)
		apply_image_decorations(I)
	if(additional_desc)
		additional_description(I)
	if(anomaly_factor && !findtext(I.origin_tech, Tc_ANOMALY))
		I.origin_tech += "[I.origin_tech ? ";" : ""]"+Tc_ANOMALY+"=[anomaly_factor]"

	if(talkative && istype(I, /obj/item/weapon))
		I.listening_to_players = TRUE
		if(prob(25))
			if(!I.heard_words)
				I.heard_words = list()
			I.speaking_to_players = TRUE
			processing_objects.Add(I)
	I.forceMove(loc)
	return I


/datum/find/proc/spawn_item() //Makes the item. Returns item.
	log_admin("/datum/find/spawn_item() parent proc was called, that should never happen. Find type is [type]")
	message_admins("/datum/find/spawn_item() parent proc was called, that should never happen. Find type is [type]")
	return

/datum/find/proc/apply_prefix(var/obj/item/I)
	I.name = "[pick("strange","ancient","alien","")] [item_type?"[item_type]":"[initial(I.name)]"]"

/datum/find/proc/apply_image_decorations(var/obj/item/I) //Applies murals to the object
	var/engravings = "[pick("Engraved","Carved","Etched")] on the item is [pick("an image of","a frieze of","a depiction of")] \
	[pick("an alien humanoid","an amorphic blob","a short, hairy being","a rodent-like creature","a robot","a primate","a reptilian alien","an unidentifiable object","a statue","a starship","unusual devices","a structure")] \
	[pick("surrounded by","being held aloft by","being struck by","being examined by","communicating with")] \
	[pick("alien humanoids","amorphic blobs","short, hairy beings","rodent-like creatures","robots","primates","reptilian aliens")]"
	if(prob(50))
		engravings += ", [pick("they seem to be enjoying themselves","they seem extremely angry","they look pensive","they are making gestures of supplication","the scene is one of subtle horror","the scene conveys a sense of desperation","the scene is completely bizarre")]"
	engravings += "."

	anomaly_factor++

	if(I.desc)
		I.desc += " "
	I.desc += engravings

/datum/find/proc/additional_description(var/obj/item/I) //Applies additional description. Usually find-specific

/datum/find/proc/apply_material_decorations(var/obj/item/I) //Applies interesting decor to the object. Overrides current description
	var/decorations = ""
	if(prob(40))
		material_descriptor = pick("rusted ","dusty ","archaic ","fragile ")
	var/source_material = pick("cordite","quadrinium","steel","titanium","aluminium","ferritic-alloy","plasteel","duranium")
	I.desc = "A [material_descriptor ? "[material_descriptor] " : ""][item_type] made of [source_material], all craftsmanship is of [pick("the lowest","low","average","high","the highest")] quality."

	var/list/descriptors = list()
	if(prob(30))
		descriptors.Add("is encrusted with [pick("","synthetic ","multi-faceted ","uncut ","sparkling ") + pick("rubies","emeralds","diamonds","opals","lapiz lazuli")]")
	if(prob(30))
		descriptors.Add("is studded with [pick("gold","silver","aluminium","titanium")]")
	if(prob(30))
		descriptors.Add("is encircled with bands of [pick("quadrinium","cordite","ferritic-alloy","plasteel","duranium")]")
	if(prob(30))
		descriptors.Add("menaces with spikes of [pick("solid plasma","uranium","white pearl","black steel")]")
	if(descriptors.len > 0)
		decorations = "It "
		for(var/index=1, index <= descriptors.len, index++)
			if(index > 1)
				if(index == descriptors.len)
					decorations += " and "
				else
					decorations += ", "
			decorations += descriptors[index]
		decorations += "."
	if(decorations)
		I.desc += " " + decorations


/datum/find/bowl
	find_ID = ARCHAEO_BOWL
	apply_image_decorations = TRUE
	anomaly_factor = 0
	additional_desc = TRUE
	responsive_reagent = MERCURY
	item_type = "bowl"

/datum/find/bowl/spawn_item()
	var/glass_type = pick(200;/obj/item/weapon/reagent_containers/glass, 25;/obj/item/weapon/reagent_containers/glass/replenishing, 25;/obj/item/weapon/reagent_containers/glass/xenoviral)
	var/obj/item/weapon/new_item = new glass_type
	new_item.name = "bowl"
	new_item.icon_state = "bowl"
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	return new_item

/datum/find/bowl/additional_description(var/obj/item/I)
	if(prob(20))
		I.desc += "There appear to be [pick("dark","faintly glowing","pungent","bright")] [pick("red","purple","green","blue")] stains inside."


/datum/find/urn
	find_ID = ARCHAEO_URN
	item_type = "urn"
	apply_image_decorations = TRUE
	additional_desc = TRUE
	responsive_reagent = MERCURY
	anomaly_factor = 0

/datum/find/urn/spawn_item()
	var/glass_type = pick(200;/obj/item/weapon/reagent_containers/glass, 25;/obj/item/weapon/reagent_containers/glass/replenishing, 25;/obj/item/weapon/reagent_containers/glass/xenoviral)
	var/obj/item/weapon/new_item = new glass_type
	new_item.name = "urn"
	new_item.icon_state = "urn"
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	return new_item

/datum/find/urn/additional_description(var/obj/item/I)
	if(prob(20))
		I.desc += "It [pick("whispers faintly","makes a quiet roaring sound","whistles softly","thrums quietly","throbs")] if you put it to your ear."
		anomaly_factor = 1

/datum/find/cutlery
	find_ID = ARCHAEO_CUTLERY
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/cutlery/spawn_item()
	item_type = "[pick("fork","spoon","knife")]"
	if(prob(25))
		return new /obj/item/weapon/kitchen/utensil/fork
	else if(prob(50))
		return new /obj/item/weapon/kitchen/utensil/knife
	else
		return new /obj/item/weapon/kitchen/utensil/spoon

/datum/find/cutlery/additional_description(var/obj/item/I)
	I.desc += "[pick("It's like no [item_type] you've ever seen before",\
	"It's a mystery how anyone is supposed to eat with this",\
	"You wonder what the creator's mouth was shaped like")]."

/datum/find/statuette
	find_ID = ARCHAEO_STATUETTE
	item_type = "statuette"
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/statuette/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	new_item.icon_state = "statuette"
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	return new_item

/datum/find/statuette/additional_description(var/obj/item/I)
	additional_desc = "It depicts a [pick("small","ferocious","wild","pleasing","hulking")] \
	[pick("alien figure","rodent-like creature","reptilian alien","primate","unidentifiable object")] \
	[pick("performing unspeakable acts","posing heroically","in a fetal position","cheering","sobbing","making a plaintive gesture","making a rude gesture")]."


/datum/find/instrument
	find_ID = ARCHAEO_INSTRUMENT
	item_type = "instrument"
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/instrument/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	new_item.icon_state = "instrument"
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	if(prob(30))
		apply_image_decorations = TRUE
	return new_item

/datum/find/instrument/additional_description(var/obj/item/I)
	if(apply_image_decorations)
		additional_desc = "[pick("You're not sure how anyone could have played this",\
		"You wonder how many mouths the creator had",\
		"You wonder what it sounds like",\
		"You wonder what kind of music was made with it")]."

/datum/find/knife
	find_ID = ARCHAEO_KNIFE
	additional_desc = TRUE
	responsive_reagent = IRON

/datum/find/knife/spawn_item()
	var/obj/item/new_item = new /obj/item/weapon/kitchen/utensil/knife/large
	item_type = "[pick("double-bladed knife","serrated blade","sharp cutting implement")]"
	new_item.icon = 'icons/obj/weapons.dmi'
	switch(item_type)
		if ("double-bladed knife")
			new_item.icon_state = "double_bladed"
		if ("serrated blade")
			new_item.icon_state = "serrated_blade"
		if ("sharp cutting implement")
			new_item.icon_state = "cutting_implement"
	return new_item

/datum/find/knife/additional_description(var/obj/item/I)
	I.desc += "[pick("It doesn't look safe.",\
			"It looks wickedly jagged",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along the edges")]."

/datum/find/ritualknife
	find_ID = ARCHAEO_RITUALKNIFE
	additional_desc = TRUE
	apply_material_decorations = TRUE
	responsive_reagent = IRON

/datum/find/ritualknife/spawn_item()
	var/obj/item/new_item = new /obj/item/weapon/kitchen/utensil/knife/large/ritual
	return new_item

/datum/find/ritualknife/additional_description(var/obj/item/I)
	I.desc += "[pick("It doesn't look safe.",\
			"It looks wickedly jagged",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along the edges")]."

/datum/find/coin
	find_ID = ARCHAEO_COIN
	apply_prefix = FALSE
	apply_material_decorations = FALSE
	apply_image_decorations = TRUE
	responsive_reagent = IRON
	anomaly_factor = 0

/datum/find/coin/spawn_item()
	var/choice = pick(subtypesof(/obj/item/weapon/coin) - /obj/item/weapon/coin/pomf - /obj/item/weapon/coin/pumf)
	var/obj/item/I = new choice
	item_type = I.name
	return I

/datum/find/handcuffs
	find_ID = ARCHAEO_HANDCUFFS
	item_type = "handcuffs"
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/handcuffs/spawn_item()
	return new /obj/item/weapon/handcuffs

/datum/find/handcuffs/additional_description(var/obj/item/I)
	I.desc += "[pick("They appear to be for securing two things together","Looks kinky","Doesn't seem like a children's toy")]."

/datum/find/beartrap
	find_ID = ARCHAEO_BEARTRAP
	apply_prefix = FALSE
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/beartrap/spawn_item()
	item_type = "[pick("wicked","evil","byzantine","dangerous")] looking [pick("device","contraption","thing","trap")]"
	return new /obj/item/weapon/beartrap

/datum/find/beartrap/additional_description(var/obj/item/I)
	I.desc += "[pick("It looks like it could take a limb off",\
			"Could be some kind of animal trap",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains along part of it")]."

/datum/find/lighter
	find_ID = ARCHAEO_LIGHTER
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/lighter/spawn_item()
	item_type = "[pick("cylinder","tank","chamber")]"
	if(prob(30))
		apply_image_decorations = TRUE
	return new /obj/item/weapon/lighter/random


/datum/find/lighter/additional_description(var/obj/item/I)
	I.desc += "There is a tiny device attached."

/datum/find/box
	find_ID = ARCHAEO_BOX
	item_type = "box"
	responsive_reagent = MERCURY

/datum/find/box/spawn_item()
	var/obj/item/weapon/storage/box/new_item = new /obj/item/weapon/storage/box
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	new_item.icon_state = "box"
	new_item.foldable = null
	if(prob(30))
		apply_image_decorations = TRUE
	return new_item

/datum/find/gastank
	find_ID = ARCHAEO_GASTANK
	additional_desc = TRUE
	responsive_reagent = MERCURY

/datum/find/gastank/spawn_item()
	var/obj/item/new_item
	item_type = "[pick("cylinder","tank","chamber")]"
	if(prob(25))
		new_item = new /obj/item/weapon/tank/air
	else if(prob(50))
		new_item = new /obj/item/weapon/tank/anesthetic
	else
		new_item = new /obj/item/weapon/tank/plasma
	new_item.icon_state = pick("oxygen","oxygen_fr","oxygen_f","plasma","anesthetic")
	return new_item

/datum/find/gastank/additional_description(var/obj/item/I)
	I.desc += "It [pick("gloops","sloshes")] slightly when you shake it."

/datum/find/tool
	find_ID = ARCHAEO_TOOL
	item_type = "tool"
	additional_desc = TRUE
	responsive_reagent = IRON

/datum/find/tool/spawn_item()
	if(prob(25))
		return new /obj/item/tool/wrench
	else if(prob(25))
		return new /obj/item/tool/crowbar
	else
		return new /obj/item/tool/screwdriver

/datum/find/tool/additional_description(var/obj/item/I)
	I.desc += "[pick("It doesn't look safe.",\
			"You wonder what it was used for",\
			"There appear to be [pick("dark red","dark purple","dark green","dark blue")] stains on it")]."

/datum/find/metal
	find_ID = ARCHAEO_METAL
	apply_material_decorations = FALSE
	responsive_reagent = IRON

/datum/find/metal/spawn_item()
	var/obj/item/stack/sheet/new_item
	var/list/possible_spawns = list()
	possible_spawns += /obj/item/stack/sheet/metal
	possible_spawns += /obj/item/stack/sheet/plasteel
	possible_spawns += /obj/item/stack/sheet/glass/glass
	possible_spawns += /obj/item/stack/sheet/glass/rglass
	possible_spawns += /obj/item/stack/sheet/mineral/plasma
	possible_spawns += /obj/item/stack/sheet/mineral/mythril
	possible_spawns += /obj/item/stack/sheet/mineral/gold
	possible_spawns += /obj/item/stack/sheet/mineral/silver
	possible_spawns += /obj/item/stack/sheet/mineral/uranium
	possible_spawns += /obj/item/stack/sheet/mineral/sandstone
	possible_spawns += /obj/item/stack/sheet/mineral/silver

	var/new_type = pick(possible_spawns)
	if(new_type == /obj/item/stack/sheet/metal)
		new_item = new /obj/item/stack/sheet/metal(get_turf(src))
	else
		new_item = new new_type(get_turf(src))
	new_item.amount = rand(5,45)
	return new_item

/datum/find/pen
	find_ID = ARCHAEO_PEN
	responsive_reagent = MERCURY

/datum/find/pen/spawn_item()
	if(prob(30))
		apply_image_decorations = TRUE
	if(prob(75))
		return new /obj/item/weapon/pen
	else
		anomaly_factor = 2
		return new /obj/item/weapon/pen/sleepypen



/datum/find/crystal
	find_ID = ARCHAEO_CRYSTAL
	apply_prefix = FALSE
	apply_material_decorations = FALSE
	additional_desc = TRUE
	anomaly_factor = 3
	responsive_reagent = NITROGEN

/datum/find/crystal/spawn_item()
	var/obj/item/weapon/archaeological_find/new_find = new()
	if(prob(25))
		new_find.name = "smooth green crystal"
		new_find.icon_state = "Green lump"
	else if(prob(33))
		new_find.name = "irregular purple crystal"
		new_find.icon_state = "Phazon"
	else if(prob(50))
		new_find.name = "rough red crystal"
		new_find.icon_state = "changerock"
	else
		new_find.name = "smooth red crystal"
		new_find.icon_state = "smoothrock"

	if(prob(10))
		apply_image_decorations = TRUE

	return new_find

/datum/find/crystal/additional_description(var/obj/item/I)
	I.desc += pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")

/datum/find/cultblade
	find_ID = ARCHAEO_CULTBLADE
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	anomaly_factor = 2
	apply_prefix = FALSE
	responsive_reagent = POTASSIUM

/datum/find/cultblade/spawn_item()
	return new /obj/item/weapon/melee/cultblade/nocult

/datum/find/telebeacon
	find_ID = ARCHAEO_TELEBEACON
	anomaly_factor = 3
	responsive_reagent = POTASSIUM

/datum/find/telebeacon/spawn_item()
	var/obj/item/new_item = new /obj/item/beacon
	talkative = FALSE
	new_item.icon_state = "unknown[rand(1,4)]"
	new_item.icon = 'icons/obj/xenoarchaeology.dmi'
	new_item.desc = ""
	return new_item

/datum/find/claymore
	find_ID = ARCHAEO_CLAYMORE
	apply_material_decorations = FALSE
	apply_prefix = FALSE
	responsive_reagent = IRON

/datum/find/claymore/spawn_item()
	var/list/possible_spawns=list(/obj/item/weapon/claymore, /obj/item/weapon/melee/morningstar, /obj/item/weapon/spear/wooden)

	var/new_type = pick(possible_spawns)

	var/obj/item/weapon/new_item = new new_type
	if(istype(new_item, /obj/item/weapon/claymore))
		new_item.force = pick(50;10,40;20,10;40)
		switch(new_item.force)
			if(10)
				new_item.icon_state += "-rust"
				new_item.name = "rusted claymore"
			if(20)
				new_item.icon_state += "-dull"
				new_item.name = "dull claymore"

	item_type = new_item.name
	return new_item

/datum/find/cultrobes
	find_ID = ARCHAEO_CULTROBES
	apply_prefix = FALSE
	anomaly_factor = 2
	responsive_reagent = POTASSIUM

/datum/find/cultrobes/spawn_item()

	//75% chance to get a headgear
	//25% chance to get a suit

	//33% chance to get current cult hood/robes
	//26.6% chance to get red cult hood/robes
	//20% chance to get magus hood/robes
	//13% chance to get current cult helmet/armor
	//6.6% chance to get legacy cult helmet/armor

	var/choice = pick(
	75;/obj/item/clothing/head/culthood,
	25;/obj/item/clothing/suit/cultrobes,
	60;/obj/item/clothing/head/culthood/old,
	20;/obj/item/clothing/suit/cultrobes/old,
	45;/obj/item/clothing/head/magus,
	15;/obj/item/clothing/suit/magusred,
	30;/obj/item/clothing/head/helmet/space/cult,
	10;/obj/item/clothing/suit/space/cult,
	15;/obj/item/clothing/head/helmet/space/legacy_cult,
	5;/obj/item/clothing/suit/space/legacy_cult)
	return new choice

/datum/find/soulstone
	find_ID = ARCHAEO_SOULSTONE
	anomaly_factor = 4
	apply_prefix = FALSE
	apply_material_decorations = FALSE
	item_type = "soulstone"
	responsive_reagent = NITROGEN

/datum/find/soulstone/spawn_item()
	return new /obj/item/soulstone

/datum/find/shard
	find_ID = ARCHAEO_SHARD
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = NITROGEN

/datum/find/shard/spawn_item()
	if(prob(50))
		return new /obj/item/weapon/shard
	else
		return new /obj/item/weapon/shard/plasma

/datum/find/rods
	find_ID = ARCHAEO_RODS
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = IRON

/datum/find/rods/spawn_item()
	return new /obj/item/stack/rods

/datum/find/stock_parts //Tier 4 parts
	find_ID = ARCHAEO_STOCKPARTS
	apply_material_decorations = FALSE
	responsive_reagent = IRON
	anomaly_factor = 2

/datum/find/stock_parts/spawn_item()
	var/list/possible_spawns = list(
//			/obj/item/weapon/stock_parts/console_screen/reinforced/plasma/rplasma,
			/obj/item/weapon/stock_parts/capacitor/adv/super/ultra,
			/obj/item/weapon/stock_parts/micro_laser/high/ultra/giga,
			/obj/item/weapon/stock_parts/manipulator/nano/pico/femto,
			/obj/item/weapon/stock_parts/scanning_module/adv/phasic/bluespace,
			/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace)
	var/new_type = pick(possible_spawns)
	var/obj/item/new_item = new new_type
	item_type = new_item.name
	return new_item

/datum/find/katana
	find_ID = ARCHAEO_KATANA
	apply_prefix = FALSE
	responsive_reagent = IRON
	anomaly_factor = 0

/datum/find/katana/spawn_item()
	var/obj/item/weapon/new_item = new /obj/item/weapon/katana
	new_item.force = pick(50;10,40;20,10;40)
	switch(new_item.force)
		if(10)
			new_item.icon_state += "-rust"
			new_item.name = "rusted katana"
		if(20)
			new_item.icon_state += "-dull"
			new_item.name = "dull katana"
	item_type = new_item.name
	return new_item


/datum/find/laser
	find_ID = ARCHAEO_LASER
	anomaly_factor = 2
	item_type = "gun"
	additional_desc = TRUE
	responsive_reagent = IRON

/datum/find/laser/spawn_item()

	var/gun_base = pickweight(list(
		/obj/item/weapon/gun/energy/laser/alien				=	75,		//75% chance to be a normal gun
		/obj/item/weapon/gun/energy/laser/captain/alien	=	20,		//20% chance to be self-recharging
		/obj/item/weapon/gun/energy/bison/alien			= 	5,		//5% chance to be pump-charge
	))
	var/obj/item/weapon/gun/energy/new_gun = new gun_base
	new_gun.icon = 'icons/obj/xenoarchaeology.dmi'
	new_gun.icon_state = "egun[rand(1,6)]"
	new_gun.item_state = new_gun.icon_state
	new_gun.inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	new_gun.charge_states = 0 //let's prevent it from losing that great icon if we charge it
	new_gun.desc = ""

	//Randomize it!

	new_gun.projectile_type = pickweight(list(		//Randomize the beam it fires. Standard laser deals 30 burn.

		/obj/item/projectile/beam 							= 250,
		/obj/item/projectile/beam/captain					= 80,	//40 damage
		/obj/item/projectile/beam/retro						= 120,
		/obj/item/projectile/beam/practice					= 130,	//Deals no damage.
		/obj/item/projectile/beam/lightlaser				= 120,	//25 damage
		/obj/item/projectile/beam/weaklaser					= 130,	//15 damage
		/obj/item/projectile/beam/veryweaklaser				= 140,	//5 damage
		/obj/item/projectile/beam/heavylaser				= 40,	//60 damage
		/obj/item/projectile/beam/heavylaser/lawgiver		= 80,	//40 damage
		/obj/item/projectile/beam/xray						= 80,	//Shoots through walls.
		/obj/item/projectile/beam/bison						= 110,	//15 damage, pierces
		/obj/item/projectile/beam/white						= 100 ,	//Injects HONK serum and spacedrugs
		/obj/item/projectile/beam/combustion				= 70,	//Creates a small explosion on impact, not all that powerful really
		/obj/item/projectile/energy/declone					= 70,	//Decloner bolts
		/obj/item/projectile/energy/bolt					= 70 ,	//Ebow bolts
		/obj/item/projectile/energy/buster					= 120,	//20 damage
		/obj/item/projectile/kinetic						= 100,	//KA bolts
		/obj/item/projectile/ricochet						= 100,	//Richochet lasers
		/obj/item/projectile/spur/polarstar					= 100,	//Polar star
		/obj/item/weapon/gun/energy/polarstar/spur			= 80,	//Spur
		//ION BOLTS
		/obj/item/projectile/ion							= 120,	//Its an ion bolt.
		/obj/item/projectile/ion/small						= 110,	//Its a small ion bolt.
		//PLASMA BOLTS
		/obj/item/projectile/energy/plasma/light			= 90,	//35 damage, contaminates
		/obj/item/projectile/energy/plasma/rifle			= 50,	//50 damage, contaminates
		/obj/item/projectile/energy/plasma/pistol			= 120,	//25 damage, contaminates
		//TASERS
		/obj/item/projectile/energy/electrode				= 180,	//Its a taser electrode
		/obj/item/projectile/energy/electrode/fast			= 80,	//fast tasers
		/obj/item/projectile/energy/electrode/scatter		= 80,	//3-way tasers
		//DUMB SHIT
		/obj/item/projectile/energy/osipr					= 10,	//oh no
		/obj/item/projectile/energy/rad						= 50,	//30 damage, irradiates
		/obj/item/projectile/gravitywell					= 10,	//uh oh
		/obj/item/projectile/beam/pulse						= 40,	//50 damage, destroys walls
//		/obj/item/projectile/energy/electrode/scatter/sun 	= 10,	//holy christ
		/obj/item/projectile/swap							= 50,	//swap staff bolts
		/obj/item/projectile/forcebolt						= 50,	//mental focus bolts
		/obj/item/projectile/beam/mindflayer				= 50,	//deals brain damage
	))

	var/delay = rand(1, 20)
	new_gun.fire_delay = delay		//Randomize the fire delay
	new_gun.attack_delay = delay
	new_gun.charge_cost = rand(25, 225)		//Randomize the cost-per-fire (how many shots it has)

	if(istype(new_gun.projectile_type, /obj/item/projectile/gravitywell))	//If its a gravity gun set the charge to 200 so the game doesnt break.
		new_gun.charge_cost = 200

	new_gun.fire_sound = pick(list(				//Randomize the sound it makes
		'sound/weapons/alien_laser1.ogg',
		'sound/weapons/alien_laser2.ogg',
		'sound/weapons/blaster.ogg',
		'sound/weapons/electriczap.ogg',
		'sound/weapons/hivehand.ogg',
		'sound/weapons/kinetic_accelerator.ogg',
		'sound/weapons/Laser.ogg',
		'sound/weapons/Laser2.ogg',
		'sound/weapons/laser3.ogg',
		'sound/weapons/lasercannonfire.ogg',
		'sound/weapons/ion.ogg',
		'sound/weapons/megabuster.ogg',
		'sound/weapons/pulse.ogg',
		'sound/weapons/pulse2.ogg',
		'sound/weapons/pulse3.ogg',
		'sound/weapons/Taser.ogg',
		'sound/weapons/Taser2.ogg'
	))


	//5% chance to explode when first fired
	//10% chance to have an unchargeable cell
	//15% chance to gain a random amount of starting energy, otherwise start with an empty cell
	if(prob(5))
		new_gun.power_supply.rigged = TRUE
	if(prob(10))
		new_gun.power_supply.maxcharge = 0
	if(prob(15))
		new_gun.power_supply.charge = rand(0, new_gun.power_supply.maxcharge)
	else
		new_gun.power_supply.charge = 0

	return new_gun

/datum/find/laser/additional_description(var/obj/item/I)
	I.desc += "Looks like an antique energy weapon, you're not sure if it will fire or not."
	if(istype(I, /obj/item/weapon/gun/energy/bison))
		I.desc += "There seems to be some sort of pump on the back of the stock."
	if(prob(10)) // 10% chance to be a smart gun
		I.can_take_pai = TRUE
		I.desc += " There seems to be some sort of slot in the handle."

/datum/find/gun
	find_ID = ARCHAEO_GUN
	anomaly_factor = 2
	item_type = "gun"
	responsive_reagent = IRON
	additional_desc = TRUE

/datum/find/gun/spawn_item()
	// use subtypes to change icon_state.
	// because gun code relies on initial(icon_state)
	var/gun_type = pick(subtypesof(/obj/item/weapon/gun/projectile/xenoarch))
	var/obj/item/weapon/gun/projectile/new_gun = new gun_type

	//let's get some ammunition in this gun : weighted to pick available ammo
	new_gun.caliber = pick(50;list(POINT357 = 1),
						   10;list(POINT75 = 1),
						   30;list(POINT38 = 1),
						   10;list(MM12 = 1))

	//33% chance to fill it with a random amount of bullets
	new_gun.max_shells = rand(1,12)
	if(prob(33))
		var/num_bullets = rand(1,new_gun.max_shells)
		if(num_bullets < new_gun.loaded.len)
			new_gun.loaded.len = 0
			for(var/i = 1, i <= num_bullets, i++)
				var/A = text2path(new_gun.ammo_type)
				new_gun.loaded += new A(new_gun)
		else
			for(var/obj/item/I in new_gun)
				if(new_gun.loaded.len > num_bullets)
					if(I in new_gun.loaded)
						new_gun.loaded.Remove(I)
						I.forceMove(null)
				else
					break
	else
		for(var/obj/item/I in new_gun)
			if(I in new_gun.loaded)
				new_gun.loaded.Remove(I)
				I.forceMove(null)

	return new_gun

/obj/item/weapon/gun/projectile/xenoarch
	icon = 'icons/obj/xenoarchaeology.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/xenoarch.dmi', "right_hand" = 'icons/mob/in-hand/right/xenoarch.dmi')
	desc = ""

/obj/item/weapon/gun/projectile/xenoarch/gun1
	icon_state = "gun1"
	item_state = "gun1"

/obj/item/weapon/gun/projectile/xenoarch/gun2
	icon_state = "gun2"
	item_state = "gun2"

/obj/item/weapon/gun/projectile/xenoarch/gun3
	icon_state = "gun3"
	item_state = "gun3"

/obj/item/weapon/gun/projectile/xenoarch/gun4
	icon_state = "gun4"
	item_state = "gun4"

/datum/find/gun/additional_description(var/obj/item/I)
	I.desc += "Looks like an antique projectile weapon, you're not sure if it will fire or not."
	if(prob(10)) // 10% chance to be a smart gun
		I.can_take_pai = TRUE
		I.desc += " There seems to be some sort of slot in the handle."


/datum/find/unknown
	find_ID = ARCHAEO_UNKNOWN
	anomaly_factor = 2
	responsive_reagent = MERCURY

/datum/find/unknown/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	if(prob(50))
		qdel(new_item)
		new_item = new /obj/item/weapon/glow_orb
	if(prob(50))
		apply_image_decorations = FALSE
	return new_item

/datum/find/fossil
	find_ID = ARCHAEO_FOSSIL
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	apply_prefix = FALSE
	additional_desc = TRUE
	responsive_reagent = CARBON


/datum/find/fossil/spawn_item()
	var/list/candidates = list("/obj/item/weapon/fossil/bone"=9,"/obj/item/weapon/fossil/skull"=3,
	"/obj/item/weapon/fossil/skull/horned"=2)
	var/spawn_type = pickweight(candidates)
	return new spawn_type()

/datum/find/fossil/additional_description(var/obj/item/I)
	I.desc += "A fossilised part of an alien, long dead."

/datum/find/shell
	find_ID = ARCHAEO_SHELL
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = CARBON

/datum/find/shell/spawn_item()
	var/obj/item/new_item = new /obj/item/weapon/fossil/shell
	if(prob(10))
		apply_image_decorations = TRUE
	return new_item

/datum/find/shell/additional_description(var/obj/item/I)
	I.desc += "A fossilised, pre-Stygian alien crustacean."

/datum/find/plant
	find_ID = ARCHAEO_PLANT
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	apply_prefix = FALSE
	responsive_reagent = CARBON

/datum/find/plant/spawn_item()
	var/obj/item/new_item = new /obj/item/weapon/fossil/plant
	item_type = new_item.name
	return new_item

/datum/find/plant/additional_description(var/obj/item/I)
	I.desc += "A fossilised shred of alien plant matter."

/datum/find/egg
	find_ID = ARCHAEO_EGG
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	apply_prefix = FALSE
	responsive_reagent = CARBON

/datum/find/egg/spawn_item()
	var/obj/item/new_item = new /obj/item/weapon/fossil/egg
	item_type = new_item.name
	return new_item

/datum/find/remains_human
	find_ID = ARCHAEO_REMAINS_HUMANOID
	anomaly_factor = 2
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = CARBON

/datum/find/remains_human/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	item_type = "humanoid [pick("remains","skeleton")]"
	new_item.icon = 'icons/effects/blood.dmi'
	new_item.icon_state = "remains"
	return new_item

/datum/find/remains_human/additional_description(var/obj/item/I)
	I.desc = pick("They appear almost human.",
	"They are contorted in a most gruesome way.",
	"They look almost peaceful.",
	"The bones are yellowing and old, but remarkably well preserved.",
	"The bones are scored by numerous burns and partially melted.",
	"The are battered and broken, in some cases less than splinters are left.",
	"The mouth is wide open in a death rictus, the victim would appear to have died screaming.")

/datum/find/remains_robot
	find_ID = ARCHAEO_REMAINS_ROBOT
	anomaly_factor = 2
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = IRON

/datum/find/remains_robot/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	item_type = "[pick("mechanical","robotic","cyborg")] [pick("remains","chassis","debris")]"
	new_item.icon = 'icons/mob/robots.dmi'
	new_item.icon_state = "remainsrobot"
	return new_item

/datum/find/remains_robot/additional_description(var/obj/item/I)
	I.desc = pick("Almost mistakeable for the remains of a modern cyborg.",
	"They are barely recognisable as anything other than a pile of waste metals.",
	"It looks like the battered remains of an ancient robot chassis.",
	"The chassis is rusting and old, but remarkably well preserved.",
	"The chassis is scored by numerous burns and partially melted.",
	"The chassis is battered and broken, in some cases only chunks of metal are left.",
	"A pile of wires and crap metal that looks vaguely robotic.")


/datum/find/remains_xeno
	find_ID = ARCHAEO_REMAINS_XENO
	anomaly_factor = 2
	apply_prefix = FALSE
	apply_image_decorations = FALSE
	apply_material_decorations = FALSE
	responsive_reagent = CARBON

/datum/find/remains_xeno/spawn_item()
	var/obj/item/weapon/archaeological_find/new_item = new()
	item_type = "alien [pick("remains","skeleton")]"
	new_item.icon = 'icons/effects/blood.dmi'
	new_item.icon_state = "remainsxeno"
	return new_item

/datum/find/remains_xeno/additional_description(var/obj/item/I)
	I.desc = pick("It looks vaguely reptilian, but with more teeth.",\
			"They are faintly unsettling.",\
			"There is a faint aura of unease about them.",\
			"The bones are yellowing and old, but remarkably well preserved.",\
			"The bones are scored by numerous burns and partially melted.",\
			"The are battered and broken, in some cases less than splinters are left.",\
			"This creature would have been twisted and monstrous when it was alive.",\
			"It doesn't look human.")

/datum/find/mask
	find_ID = ARCHAEO_MASK
	anomaly_factor = 4
	apply_material_decorations = FALSE
	responsive_reagent = MERCURY

/datum/find/mask/spawn_item()
	var/list/possible_spawns = list()
	possible_spawns += /obj/item/clothing/mask/morphing
	possible_spawns += /obj/item/clothing/mask/morphing/amorphous
	possible_spawns += /obj/item/clothing/mask/happy
	var/new_type = pick(possible_spawns)
	return new new_type

/datum/find/dice
	find_ID =ARCHAEO_DICE
	anomaly_factor = 4
	apply_material_decorations = FALSE
	responsive_reagent = MERCURY

/datum/find/dice/spawn_item()
	return new /obj/item/weapon/dice/d20/cursed

/datum/find/spacesuit
	find_ID = ARCHAEO_SPACESUIT
	anomaly_factor = 2
	apply_material_decorations = FALSE
	responsive_reagent = POTASSIUM

/datum/find/spacesuit/spawn_item()
	var/result = pick(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/head/helmet/space/ancient)
	return new result

/datum/find/excasuit
	find_ID = ARCHAEO_EXCASUIT
	anomaly_factor = 2
	apply_material_decorations = FALSE
	responsive_reagent = POTASSIUM

/datum/find/excasuit/spawn_item()
	var/result = pick(/obj/item/clothing/suit/space/anomaly, /obj/item/clothing/head/helmet/space/anomaly)
	return new result

/datum/find/anomsuit
	find_ID = ARCHAEO_ANOMSUIT
	anomaly_factor = 2
	apply_material_decorations = FALSE
	responsive_reagent = POTASSIUM

/datum/find/anomsuit/spawn_item()
	var/result = pick(/obj/item/clothing/suit/bio_suit/anomaly/old, /obj/item/clothing/head/bio_hood/anomaly/old)
	return new result

/datum/find/lance
	find_ID = ARCHAEO_LANCE
	anomaly_factor = 0
	apply_material_decorations = TRUE
	apply_image_decorations = TRUE
	responsive_reagent = IRON
	item_type = "lance"

/datum/find/lance/spawn_item()
	return new /obj/item/weapon/melee/lance

/datum/find/roulette
	find_ID = ARCHAEO_ROULETTE
	anomaly_factor = 2
	apply_material_decorations = FALSE
	responsive_reagent =  IRON

/datum/find/roulette/spawn_item()
	return new /obj/item/weapon/gun/projectile/roulette_revolver


/datum/find/robot
	find_ID = ARCHAEO_ROBOT
	item_type = "machine"
	anomaly_factor = 2
	apply_prefix = FALSE
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	responsive_reagent = IRON

/datum/find/robot/spawn_item()
	var/result = pick(/obj/item/weapon/robot_spawner/strange/ball, /obj/item/weapon/robot_spawner/strange/egg)
	return new result

/datum/find/sash
	find_ID = ARCHAEO_SASH
	anomaly_factor = 2
	apply_material_decorations = FALSE
	responsive_reagent = POTASSIUM

/datum/find/sash/spawn_item()
	return new /obj/item/red_ribbon_arm

/datum/find/toy
	find_ID = ARCHAEO_TOY
	apply_material_decorations = TRUE
	apply_image_decorations = FALSE
	apply_prefix = TRUE
	responsive_reagent = POTASSIUM

/datum/find/toy/spawn_item()
	if(prob(50))
		anomaly_factor = 0
		return new /obj/item/weapon/bikehorn/rubberducky/quantum
	else
		anomaly_factor = 1
		var/result = pick(existing_typesof(/obj/item/toy))
		return new result

/datum/find/toybox
	find_ID = ARCHAEO_TOYBOX
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	apply_prefix = FALSE
	responsive_reagent = POTASSIUM

/datum/find/toybox/spawn_item()
	return new /obj/item/weapon/butterflyknife/viscerator/bunny

/datum/find/largecrystal
	find_ID = ARCHAEO_LARGE_CRYSTAL
	apply_material_decorations = FALSE
	apply_image_decorations = TRUE
	responsive_reagent = NITROGEN

/datum/find/largecrystal/spawn_item()
	return new/obj/structure/crystal

/datum/find/chaosblade
	find_ID = ARCHAEO_CHAOS
	item_type = "blade"
	apply_prefix = TRUE
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	anomaly_factor = 4
	responsive_reagent = IRON

/datum/find/chaosblade/spawn_item()
	return new /obj/item/weapon/nullrod/sword/chaos

/datum/find/guitar
	find_ID = ARCHAEO_GUITAR
	item_type = "instrument"
	apply_prefix = TRUE
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	anomaly_factor = 3
	responsive_reagent = PLASMA

/datum/find/guitar/spawn_item()
	return new /obj/item/device/instrument/guitar/magical

/datum/find/supershard
	find_ID = ARCHAEO_SUPERSHARD
	item_type = "shard fragment"
	apply_prefix = FALSE
	apply_material_decorations = FALSE
	apply_image_decorations = FALSE
	anomaly_factor = 0
	responsive_reagent = PLASMA

/datum/find/supershard/spawn_item()
	return new /obj/item/supermatter_splinter

/datum/find/pocketwatch
	find_ID = ARCHAEO_POCKETWATCH
	apply_prefix = FALSE
	apply_material_decorations = TRUE
	apply_image_decorations = TRUE
	anomaly_factor = 1 // image decorations mean +1
	responsive_reagent = IRON

/datum/find/pocketwatch/spawn_item()
	if(prob(5))
		anomaly_factor++
		return new /obj/item/pocketwatch/luna_dial
	else
		return new /obj/item/pocketwatch

/datum/find/mirror
	find_ID = ARCHAEO_MIRROR
	anomaly_factor = 4
	apply_material_decorations = FALSE
	responsive_reagent = MERCURY

/datum/find/mirror/spawn_item()
	return new /obj/item/weapon/pocket_mirror/arcane

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Strange rocks

//have all strange rocks be cleared away using welders for now
/obj/item/weapon/strangerock
	name = "strange rock"
	desc = "Seems to have some unusal strata evident throughout it."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "strange"
	var/obj/item/weapon/inside
	var/method = 0// 0 = fire, 1 = brush, 2 = pick
	var/datum/geosample/geologic_data
	origin_tech = Tc_MATERIALS + "=5"

/obj/item/weapon/strangerock/New(loc, var/datum/find/F)
	..()
	//method = rand(0,2)
	if(F)
		inside = F.spawn_item(src)

/obj/item/weapon/strangerock/Destroy()
	..()
	QDEL_NULL(inside)

/*/obj/item/weapon/strangerock/ex_act(var/severity)
	if(severity && prob(30))
		src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")*/

/obj/item/weapon/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/pickaxe/brush))
		if(inside)
			inside.forceMove(get_turf(src))
			visible_message("\The [src] is brushed away revealing \the [inside].")
			inside = null
		else
			visible_message("<span class='info'>\The [src] reveals nothing!</span>")
		qdel(src)

	else if(istype(W,/obj/item/device/core_sampler/))
		var/obj/item/device/core_sampler/S = W
		S.sample_item(src, user)
		return

	..()
	if(prob(33))
		src.visible_message("<span class='warning'>\The [src] crumbles away, leaving some dust and gravel behind.</span>")
		qdel(src)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Basic archaeological find

/obj/item/weapon/archaeological_find
	name = "object"
	desc = "This object is completely alien."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "unknown1"

/obj/item/weapon/archaeological_find/New(loc)
	..()
	icon_state = "unknown[rand(1,4)]"
