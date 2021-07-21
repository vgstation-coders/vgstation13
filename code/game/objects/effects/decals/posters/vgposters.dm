// /vg/ posters.
/datum/poster/vg_1//serial_number ends up 40
	name = "Pristine Beach"
	desc = "A beautiful beach that reminds you of cool breezes, soft waves, and greys screaming in pain."
	icon_state="vgposter1"

/datum/poster/vg_2//41
	name = "Beach Star Yamamoto!"
	desc = "A wall scroll depicting an old swimming anime with girls in small swim suits. You feel more weebish the longer you look at it."
	icon_state="vgposter2"

/datum/poster/vg_3//42
	name = "Kill Catbeasts"
	desc = "This poster has large text reading \"KILL CAT BEAST\", as well as two small images of freaks of nature. The official Nanotrasen seal can be seen at the bottom."
	icon_state="vgposter3"

/datum/poster/vg_4//43
	name = "Nuclear Device Informational"
	desc = "This poster depicts an image of an old style nuclear explosive device, as well as some helpful information on what to do if one has been set. It suggests lying on the floor and crying."
	icon_state="vgposter4"

/datum/poster/vg_5//44
	name = "High Effect Engineering"
	desc = "There are 3 shards and a singularity.  The shards are singing.  The engineers are crying."
	icon_state="vgposter5"

/datum/poster/vg_6//45
	name = "Termination Of The Self"
	desc = "A portrait of a famous philospher who challenged the boundaries of mortality."
	icon_state="vgposter6"

/datum/poster/vg_7//46
	name = "Forgotten Dunes"
	desc = "A famous piece that always seems oddly familiar, yet its name seems to easily slip from memory."
	icon_state="vgposter7"

//Special poster designs will not appear randomly
/datum/poster/special/cargoflag
	name = "Cargonian flag"
	desc = "All hail Cargonia."
	icon_state = "cargoposter-flag"

/datum/poster/special/cargofull
	name = "Cargonian seal"
	desc = "The majestic seal of the Cargonian people. The crossed guns represent honor, loyalty, and emittered crates."
	icon_state = "cargoposter-full"

/datum/poster/special/goldstar
	name = "Award of Sufficiency"
	desc = "The mere sight of it makes you very proud."
	icon_state = "goldstar"

/datum/poster/special/ninja
	name = "machinery poster"
	desc = "A poster depicting a wall-mounted structure."
	icon_state = "poster-apc"
	var/list/poster_designs = list("poster-apc","poster-extinguisher","poster-firealarm","poster-oxycloset","poster-nosmoking")

/datum/poster/special/ninja/anime
	name = "anime poster"
	desc = "It's everybody's favorite anime."
	icon_state = "animeposter1"
	poster_designs = list("animeposter1","animeposter2","animeposter3","animeposter4","animeposter5","animeposter6")
