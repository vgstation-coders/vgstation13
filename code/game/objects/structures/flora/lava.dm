//*******************Contains everything related to the flora on lavaland planets.*******************************

/obj/structure/flora/ash
	gender = PLURAL
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	var/base_icon
	var/num_sprites = 4

/obj/structure/flora/ash/New()
	. = ..()
	if(num_sprites == 1) //stops unnecessary randomization of harvestable flora icons with only one variation. Remember to set num_sprites on your flora!
		base_icon = "[icon_state]"
		icon_state = base_icon
	else
		base_icon = "[icon_state][rand(1, num_sprites)]" //randomizing icons like this prevents the icon of the structure from loading properly in mapping tools. Works fine ingame.
		icon_state = base_icon

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things

/obj/structure/flora/ash/leaf_shroom
	icon_state = "s_mushroom"
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."

/obj/structure/flora/ash/cap_shroom
	icon_state = "r_mushroom"
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems. They're radiating light!"
	light_range = 1.5
	light_power = 2.1

/obj/structure/flora/ash/fern
	name = "cave fern"
	desc = "A species of fern with highly fibrous leaves."
	icon_state = "cavefern" //needs new sprites.
	num_sprites = 1

/obj/structure/flora/ash/fireblossom
	name = "fire blossom"
	desc = "An odd flower that grows commonly near bodies of lava. The leaves can be ground up for a substance resembling capsaicin."
	icon_state = "fireblossom"
	num_sprites = 2

/obj/structure/flora/ash/puce
	name = "Pucestal Growth"
	desc = "A collection of puce colored crystal growths."
	icon_state = "pucetal"
	num_sprites = 1

/obj/structure/flora/ash/glowshroom
	name = "glowshroom colony"
	desc = "A small, hardy patch of radiovoric glowshrooms, busying themselves in their attempts to decontaminate the soil."
	icon_state = "glowshroom"
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
	num_sprites = 1
	light_power = 0.5
	light_range = 1

/obj/structure/flora/ash/garden/arid
	name = "sandy garden"
	desc = "Beneath a bluff of soft silicate, a sheltered grove slumbers."
	icon_state = "gardenarid"

/obj/structure/flora/ash/garden/frigid
	name = "chilly garden"
	desc = "A delicate layer of frost covers hardy brush."
	icon_state = "gardencold"

/obj/structure/flora/ash/garden/waste
	name = "sickly garden"
	desc = "Polluted water wells up from the cracked earth, feeding a patch of something curious."
	icon_state = "gardensick"

/obj/structure/flora/ash/garden/seaweed //yea, i code :)
	name = "seaweed patch"
	gender = NEUTER
	desc = "A patch of seaweed, floating on the surface of the water"
	icon_state = "seaweed"

/obj/structure/flora/rock/hell
	name = "rock"
	desc = "A volcanic rock, one of the few familiar things on this planet."
	icon_state = "basalt1"
	var/base_icon_state = "basalt"
	icon = 'icons/obj/flora/rocks.dmi'
