//*******************Contains everything related to the flora on lavaland planetoids.*******************************

/obj/structure/flora/ash
	gender = PLURAL
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	var/harvested_name = "shortened mushrooms"
	var/harvested_desc = "Some quickly regrowing mushrooms, formerly known to be quite large."
	var/needs_sharp_harvest = TRUE
	var/harvest
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_time = 60
	var/harvest_message_low = "You pick a mushroom, but fail to collect many shavings from its cap."
	var/harvest_message_med = "You pick a mushroom, carefully collecting the shavings from its cap."
	var/harvest_message_high = "You harvest and collect shavings from several mushroom caps."
	var/harvested = FALSE
	var/base_icon
	var/regrowth_time_low = 8 MINUTES
	var/regrowth_time_high = 16 MINUTES
	var/num_sprites = 4 // WS edit - WS

/obj/structure/flora/ash/New()
	. = ..()
	if(num_sprites == 1) //stops unnecessary randomization of harvestable flora icons with only one variation. Remember to set num_sprites on your flora!
		base_icon = "[icon_state]"
		icon_state = base_icon
	else
		base_icon = "[icon_state][rand(1, num_sprites)]" //randomizing icons like this prevents the icon of the structure from loading properly in mapping tools. Works fine ingame.
		icon_state = base_icon

/obj/structure/flora/ash/proc/harvest(user)
	if(harvested)
		return 0

	var/rand_harvested = rand(harvest_amount_low, harvest_amount_high)
	if(rand_harvested)
		if(user)
			var/msg = harvest_message_med
			if(rand_harvested == harvest_amount_low)
				msg = harvest_message_low
			else if(rand_harvested == harvest_amount_high)
				msg = harvest_message_high
			to_chat(user, span_notice("[msg]"))
		for(var/i in 1 to rand_harvested)
			new harvest(get_turf(src))

	icon_state = "[base_icon]p"
	name = harvested_name
	desc = harvested_desc
	harvested = TRUE
	return 1

/obj/structure/flora/ash/attackby(obj/item/W, mob/user, params)
	if(!harvested && needs_sharp_harvest && (W.sharpness_flags & SHARP_BLADE))
		user.visible_message(span_notice("[user] starts to harvest from [src] with [W]."),span_notice("You begin to harvest from [src] with [W]."))
		if(do_after(user, harvest_time, target = src))
			harvest(user)
	else
		return ..()

/obj/structure/flora/ash/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!harvested && !needs_sharp_harvest)
		user.visible_message(span_notice("[user] starts to harvest from [src]."),span_notice("You begin to harvest from [src]."))
		if(do_after(user, harvest_time, target = src))
			harvest(user)

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things
	regrowth_time_low = 4200

/obj/structure/flora/ash/leaf_shroom
	icon_state = "s_mushroom"
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."
	harvested_name = "leafless mushrooms"
	harvested_desc = "A bunch of formerly-leafed mushrooms, with their sporangiums exposed. Scandalous?"
	needs_sharp_harvest = FALSE
	harvest_amount_high = 4
	harvest_time = 20
	harvest_message_low = "You pluck a single, suitable leaf."
	harvest_message_med = "You pluck a number of leaves, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable leaves."
	regrowth_time_low = 2400
	regrowth_time_high = 6000

/obj/structure/flora/ash/cap_shroom
	icon_state = "r_mushroom"
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."
	harvested_name = "small mushrooms"
	harvested_desc = "Several small mushrooms near the stumps of what likely were larger mushrooms."
	harvest_amount_high = 4
	harvest_time = 50
	harvest_message_low = "You slice the cap off a mushroom."
	harvest_message_med = "You slice off a few conks from the larger mushrooms."
	harvest_message_high = "You slice off a number of caps and conks from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 5400

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems. They're radiating light!"
	light_range = 1.5
	light_power = 2.1
	harvested_name = "tiny mushrooms"
	harvested_desc = "A few tiny mushrooms around larger stumps. You can already see them growing back."
	harvest_amount_high = 4
	harvest_time = 40
	harvest_message_low = "You pick and slice the cap off a mushroom, leaving the stem."
	harvest_message_med = "You pick and decapitate several mushrooms for their stems."
	harvest_message_high = "You acquire a number of stems from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 6000

/obj/structure/flora/ash/fern
	name = "cave fern"
	desc = "A species of fern with highly fibrous leaves."
	icon_state = "cavefern" //needs new sprites.
	harvested_name = "cave fern stems"
	harvested_desc = "A few cave fern stems, missing their leaves."
	harvest_amount_high = 4
	harvest_message_low = "You clip a single, suitable leaf."
	harvest_message_med = "You clip a number of leaves, leaving a few unsuitable ones."
	harvest_message_high = "You clip quite a lot of suitable leaves."
	regrowth_time_low = 3000
	regrowth_time_high = 5400
	num_sprites = 1

/obj/structure/flora/ash/fireblossom
	name = "fire blossom"
	desc = "An odd flower that grows commonly near bodies of lava. The leaves can be ground up for a substance resembling capsaicin."
	icon_state = "fireblossom"
	harvested_name = "fire blossom stems"
	harvested_desc = "A few fire blossom stems, missing their flowers."
	needs_sharp_harvest = FALSE
	harvest_amount_high = 3
	harvest_message_low = "You pluck a single, suitable flower."
	harvest_message_med = "You pluck a number of flowers, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable flowers."
	regrowth_time_low = 2500
	regrowth_time_high = 4000
	num_sprites = 2

/obj/structure/flora/ash/puce
	name = "Pucestal Growth"
	desc = "A collection of puce colored crystal growths."
	icon_state = "pucetal"
	harvested_name = "Pucestal fragments"
	harvested_desc = "A few pucestal fragments, slowly regrowing."
	harvest_amount_high = 6
	harvest_message_low = "You work a crystal free."
	harvest_message_med = "You cut a number of crystals free, leaving a few small ones."
	harvest_message_high = "You cut free quite a lot of crystals."
	regrowth_time_low = 10 MINUTES 				// Fast, for a crystal
	regrowth_time_high = 20 MINUTES
	num_sprites = 1

/obj/structure/flora/ash/glowshroom
	name = "glowshroom colony"
	desc = "A small, hardy patch of radiovoric glowshrooms, busying themselves in their attempts to decontaminate the soil."
	icon_state = "glowshroom"
	harvested_name = "glowshroom colony"
	harvested_desc = "A small, hardy patch of radiovoric glowshrooms. Someone seems to have come by and picked all the larger ones."
	harvest_amount_high = 6
	harvest_amount_low = 1
	harvest_message_low = "You only find a single intact stalk, discarding a number of stunted or rotted shrooms."
	harvest_message_med = "You collect a bundle of glowing fungi."
	harvest_message_high = "You manage to find several proudly-glowing shrooms of impressive size."
	regrowth_time_low = 10 MINUTES
	regrowth_time_high = 20 MINUTES
	num_sprites = 1
	light_power = 0.5
	light_range = 3
	light_color = "#11fa25"

//Gardens//
//these guys spawn a variety of seeds at random, slightly weighted. Intended as a stopgap until we can add more custom flora.
/obj/structure/flora/ash/garden
	name = "lush garden"
	gender = NEUTER
	desc = "In the soil and shade, something softly grows."
	icon_state = "garden"
	harvested_name = "lush garden"
	harvested_desc = "In the soil and shade, something softly grew. It seems some industrious scavenger already passed by."
	harvest_amount_high = 1
	harvest_amount_low = 1
	harvest_message_low = "You discover something nestled away in the growing bough."
	harvest_message_med = "You discover something nestled away in the growing bough."
	harvest_message_high = "You discover something nestled away in the growing bough."
	regrowth_time_low = 55 MINUTES
	regrowth_time_high = 60 MINUTES//good luck farming this
	num_sprites = 1
	light_power = 0.5
	light_range = 1
	needs_sharp_harvest = FALSE

/obj/structure/flora/ash/garden/arid
	name = "sandy garden"
	desc = "Beneath a bluff of soft silicate, a sheltered grove slumbers."
	icon_state = "gardenarid"
	harvested_name = "sandy garden"
	harvested_desc = "Beneath a bluff of soft silicate, a sheltered grove slumbered. Some desert wanderer seems to have picked it clean."
	harvest_amount_high = 1
	harvest_amount_low = 1
	harvest_message_low = "You brush sand away from a verdant prize, nestled in the leaves."
	harvest_message_med = "You brush sand away from a verdant prize, nestled in the leaves."
	harvest_message_high = "You brush sand away from a verdant prize, nestled in the leaves."

/obj/structure/flora/ash/garden/frigid
	name = "chilly garden"
	desc = "A delicate layer of frost covers hardy brush."
	icon_state = "gardencold"
	harvested_name = "chilly garden"
	harvested_desc = "A delicate layer of frost covers hardy brush. Someone came with the blizzard, and left with any prize this might contain."
	harvest_amount_high = 1
	harvest_amount_low = 1
	harvest_message_low = "You unearth a snow-covered treat."
	harvest_message_med = "You unearth a snow-covered treat."
	harvest_message_high = "You unearth a snow-covered treat."

/obj/structure/flora/ash/garden/waste
	name = "sickly garden"
	desc = "Polluted water wells up from the cracked earth, feeding a patch of something curious."
	icon_state = "gardensick"
	harvested_name = "sickly garden"
	harvested_desc = "Polluted water wells up from the cracked earth, where it once fed a patch of something curious. Now only wilted leaves remain."
	harvest_amount_high = 1
	harvest_amount_low = 1
	harvest_message_low = "You pry something odd from the poisoned soil."
	harvest_message_med = "You pry something odd from the poisoned soil."
	harvest_message_high = "You pry something odd from the poisoned soil."

/obj/structure/flora/ash/garden/seaweed //yea, i code :)
	name = "seaweed patch"
	gender = NEUTER
	desc = "A patch of seaweed, floating on the surface of the water"
	icon_state = "seaweed"
	harvested_name = "seaweed patch"
	harvested_desc = "A patch of seaweed, floating on the surface of the water. It seems someone has already searched through this"
	harvest_amount_high = 1
	harvest_amount_low = 1
	harvest_message_low = "You discover some edible weeds within the patch."
	harvest_message_med = "You discover some edible weeds within the patch."
	harvest_message_high = "You discover some edible weeds within the patch."

/obj/structure/flora/rock/hell
	name = "rock"
	desc = "A volcanic rock, one of the few familiar things on this planet."
	icon_state = "basalt1"
	var/base_icon_state = "basalt"
	icon = 'icons/obj/flora/rocks.dmi'
