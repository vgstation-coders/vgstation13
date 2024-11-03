/*
READ ME
The "slime_mutation[X]" list should include all of the possible colors it can split into and it's own color as the LAST color. This is for when it generates it's mutations on split.
The "maxcolorcount" var should be set to the greatest number in "slime_mutation[X]". This number must be less than or equal to 5 however.
Upon splitting it will generate 4 offspring in the following order:
1st and 2nd ones are a random chance between all of the "slime_mutation[X]"s, 3rd is made from the "primarytype", and the 4th is made from "slime_mutation[X]"s but from 1 to ("maxcolorcount"-1).
This allows two random colors of slimes, one of it's own color for sure, and finally one different color for sure. Tier 5 and up breaks this rule kind of since they split into their own color always.
*/

//Tier 2

/mob/living/carbon/slime/purple
	colour = "purple"
	primarytype = /mob/living/carbon/slime/purple
	adulttype = /mob/living/carbon/slime/purple/adult
	coretype = /obj/item/slime_extract/purple

/mob/living/carbon/slime/purple/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/purple/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/darkpurple
	slime_mutation[2] = /mob/living/carbon/slime/darkblue
	slime_mutation[3] = /mob/living/carbon/slime/green
	slime_mutation[4] = /mob/living/carbon/slime/purple


/mob/living/carbon/slime/metal
	colour = "metal"
	primarytype = /mob/living/carbon/slime/metal
	adulttype = /mob/living/carbon/slime/metal/adult
	coretype = /obj/item/slime_extract/metal

/mob/living/carbon/slime/metal/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/metal/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/silver
	slime_mutation[2] = /mob/living/carbon/slime/yellow
	slime_mutation[3] = /mob/living/carbon/slime/gold
	slime_mutation[4] = /mob/living/carbon/slime/metal


/mob/living/carbon/slime/orange
	colour = "orange"
	primarytype = /mob/living/carbon/slime/orange
	adulttype = /mob/living/carbon/slime/orange/adult
	coretype = /obj/item/slime_extract/orange

/mob/living/carbon/slime/orange/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/orange/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/red
	slime_mutation[2] = /mob/living/carbon/slime/darkpurple
	slime_mutation[3] = /mob/living/carbon/slime/yellow
	slime_mutation[4] = /mob/living/carbon/slime/orange


/mob/living/carbon/slime/blue
	colour = "blue"
	primarytype = /mob/living/carbon/slime/blue
	adulttype = /mob/living/carbon/slime/blue/adult
	coretype = /obj/item/slime_extract/blue

/mob/living/carbon/slime/blue/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/blue/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/darkblue
	slime_mutation[2] = /mob/living/carbon/slime/pink
	slime_mutation[3] = /mob/living/carbon/slime/silver
	slime_mutation[4] = /mob/living/carbon/slime/blue

//Tier 3

/mob/living/carbon/slime/darkblue
	colour = "dark blue"
	primarytype = /mob/living/carbon/slime/darkblue
	adulttype = /mob/living/carbon/slime/darkblue/adult
	coretype = /obj/item/slime_extract/darkblue

/mob/living/carbon/slime/darkblue/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/darkblue/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/purple
	slime_mutation[2] = /mob/living/carbon/slime/cerulean
	slime_mutation[3] = /mob/living/carbon/slime/blue
	slime_mutation[4] = /mob/living/carbon/slime/darkblue


/mob/living/carbon/slime/darkpurple
	colour = "dark purple"
	primarytype = /mob/living/carbon/slime/darkpurple
	adulttype = /mob/living/carbon/slime/darkpurple/adult
	coretype = /obj/item/slime_extract/darkpurple

/mob/living/carbon/slime/darkpurple/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/darkpurple/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/purple
	slime_mutation[2] = /mob/living/carbon/slime/sepia
	slime_mutation[3] = /mob/living/carbon/slime/orange
	slime_mutation[4] = /mob/living/carbon/slime/darkpurple


/mob/living/carbon/slime/yellow
	colour = "yellow"
	primarytype = /mob/living/carbon/slime/yellow
	adulttype = /mob/living/carbon/slime/yellow/adult
	coretype = /obj/item/slime_extract/yellow

/mob/living/carbon/slime/yellow/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/yellow/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/metal
	slime_mutation[2] = /mob/living/carbon/slime/bluespace
	slime_mutation[3] = /mob/living/carbon/slime/orange
	slime_mutation[4] = /mob/living/carbon/slime/yellow


/mob/living/carbon/slime/silver
	colour = "silver"
	primarytype = /mob/living/carbon/slime/silver
	adulttype = /mob/living/carbon/slime/silver/adult
	coretype = /obj/item/slime_extract/silver

/mob/living/carbon/slime/silver/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 4

/mob/living/carbon/slime/silver/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/metal
	slime_mutation[2] = /mob/living/carbon/slime/pyrite
	slime_mutation[3] = /mob/living/carbon/slime/blue
	slime_mutation[4] = /mob/living/carbon/slime/silver


/mob/living/carbon/slime/pink
	colour = "pink"
	primarytype = /mob/living/carbon/slime/pink
	adulttype = /mob/living/carbon/slime/pink/adult
	coretype = /obj/item/slime_extract/pink

/mob/living/carbon/slime/pink/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/pink/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/lightpink
	slime_mutation[2] = /mob/living/carbon/slime/pink


/mob/living/carbon/slime/red
	colour = "red"
	primarytype = /mob/living/carbon/slime/red
	adulttype = /mob/living/carbon/slime/red/adult
	coretype = /obj/item/slime_extract/red

/mob/living/carbon/slime/red/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/red/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/oil
	slime_mutation[2] = /mob/living/carbon/slime/red

/mob/living/carbon/slime/gold
	colour = "gold"
	primarytype = /mob/living/carbon/slime/gold
	adulttype = /mob/living/carbon/slime/gold/adult
	coretype = /obj/item/slime_extract/gold

/mob/living/carbon/slime/gold/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/gold/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/adamantine
	slime_mutation[2] = /mob/living/carbon/slime/gold

/mob/living/carbon/slime/green
	colour = "green"
	primarytype = /mob/living/carbon/slime/green
	adulttype = /mob/living/carbon/slime/green/adult
	coretype = /obj/item/slime_extract/green

/mob/living/carbon/slime/green/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/green/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/black
	slime_mutation[2] = /mob/living/carbon/slime/green

// Tier 4

/mob/living/carbon/slime/lightpink
	colour = "light pink"
	primarytype = /mob/living/carbon/slime/lightpink
	adulttype = /mob/living/carbon/slime/lightpink/adult
	coretype = /obj/item/slime_extract/lightpink

/mob/living/carbon/slime/lightpink/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/lightpink/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/lightpink
	slime_mutation[2] = /mob/living/carbon/slime/lightpink

/mob/living/carbon/slime/oil
	colour = "oil"
	primarytype = /mob/living/carbon/slime/oil
	adulttype = /mob/living/carbon/slime/oil/adult
	coretype = /obj/item/slime_extract/oil

/mob/living/carbon/slime/oil/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/oil/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/oil
	slime_mutation[2] = /mob/living/carbon/slime/oil


/mob/living/carbon/slime/black
	colour = "black"
	primarytype = /mob/living/carbon/slime/black
	adulttype = /mob/living/carbon/slime/black/adult
	coretype = /obj/item/slime_extract/black

/mob/living/carbon/slime/black/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/black/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/black
	slime_mutation[2] = /mob/living/carbon/slime/black


/mob/living/carbon/slime/adamantine
	colour = "adamantine"
	primarytype = /mob/living/carbon/slime/adamantine
	adulttype = /mob/living/carbon/slime/adamantine/adult
	coretype = /obj/item/slime_extract/adamantine

/mob/living/carbon/slime/adamantine/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/adamantine/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/adamantine
	slime_mutation[2] = /mob/living/carbon/slime/adamantine


/mob/living/carbon/slime/bluespace
	colour = "bluespace"
	primarytype = /mob/living/carbon/slime/bluespace
	adulttype = /mob/living/carbon/slime/bluespace/adult
	coretype = /obj/item/slime_extract/bluespace

/mob/living/carbon/slime/bluespace/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/bluespace/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/bluespace
	slime_mutation[2] = /mob/living/carbon/slime/bluespace


/mob/living/carbon/slime/pyrite
	colour = "pyrite"
	primarytype = /mob/living/carbon/slime/pyrite
	adulttype = /mob/living/carbon/slime/pyrite/adult
	coretype = /obj/item/slime_extract/pyrite

/mob/living/carbon/slime/pyrite/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/pyrite/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/pyrite
	slime_mutation[2] = /mob/living/carbon/slime/pyrite


/mob/living/carbon/slime/cerulean
	colour = "cerulean"
	primarytype = /mob/living/carbon/slime/cerulean
	adulttype = /mob/living/carbon/slime/cerulean/adult
	coretype = /obj/item/slime_extract/cerulean

/mob/living/carbon/slime/cerulean/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/cerulean/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/cerulean
	slime_mutation[2] = /mob/living/carbon/slime/cerulean


/mob/living/carbon/slime/sepia
	colour = "sepia"
	primarytype = /mob/living/carbon/slime/sepia
	adulttype = /mob/living/carbon/slime/sepia/adult
	coretype = /obj/item/slime_extract/sepia

/mob/living/carbon/slime/sepia/adult
	slime_lifestage = SLIME_ADULT
	maxcolorcount = 2

/mob/living/carbon/slime/sepia/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/sepia
	slime_mutation[2] = /mob/living/carbon/slime/sepia

////////////////Other

/mob/living/carbon/slime/pygmy
	colour = "pygmy"
	primarytype = /mob/living/carbon/slime/pygmy
	adulttype = null
	coretype = /obj/item/slime_extract/grey

/mob/living/carbon/slime/pygmy/iconstate_color()
	return "rainbow"