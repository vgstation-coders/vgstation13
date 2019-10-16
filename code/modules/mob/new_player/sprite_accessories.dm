/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/datum/sprite_accessory

	var/icon			// the icon file the accessory is located in
	var/icon_state		// the icon_state of the accessory
	var/preview_state	// a custom preview state for whatever reason

	var/name			// the preview name of the accessory

	// Determines if the accessory will be skipped or included in random hair generations
	var/gender = NEUTER

	// Restrict some styles to specific species
	var/list/species_allowed = list("Human","Manifested")

	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1

	// If the hair-style has parts that aren't affected by colouration (stored on a second sprite)
	var/additional_accessories = 0

	var/flags = 0


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/*
 * If you add a new hairstyle, remember to also add its "under helmet version".
 * You can easily make it by copy-pasting your hairstyle, surimposing the helmet sprite over it, and shaving off the pixels that sticks.
 * The icon_state for it should be named [yourhairstyle]_s2.
 */

/datum/sprite_accessory/hair

	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	gender = MALE
	species_allowed = list("Human","Manifested","Unathi","Grey","Plasmaman","Skellington","Diona","Muton","Golem","Skeletal Vox","Horror","Ghoul","Slime","Mushroom","Evolved Slime")

/datum/sprite_accessory/hair/short
	name = "Short Hair"	  // try to capatilize the names please~
	icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/longalt
	name = "Shoulder-length Hair Alt"
	icon_state = "hair_longfringe"

/*/datum/sprite_accessory/hair/longish
	name = "Longer Hair"
	icon_state = "hair_b2"*/

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longeralt
	name = "Long Hair Alt"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbangalt
	name = "Half-banged Hair Alt"
	icon_state = "hair_halfbang_alt"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail 1"
	icon_state = "hair_ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_pa"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/longpony
	name = "Long Ponytail"
	icon_state = "hair_longpony"

/datum/sprite_accessory/hair/highpony
	name = "High Ponytail"
	icon_state = "hair_highpony"

/datum/sprite_accessory/hair/sidepony1
	name = "Side Ponytail 1"
	icon_state = "hair_sidepony1"

/datum/sprite_accessory/hair/sidepony2
	name = "Side Ponytail 2"
	icon_state = "hair_sidepony2"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"
	gender = MALE
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"
	gender = MALE

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"
	gender = FEMALE
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"
	gender = FEMALE
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "hair_bobcut"
	gender = FEMALE
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"
	gender = MALE

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"
	gender = MALE
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"
	gender = MALE

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"
	gender = MALE

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Big Afro"
	icon_state = "hair_bigafro"
	gender = MALE

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"
	gender = MALE

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"
	gender = MALE

/datum/sprite_accessory/hair/jensen
	name = "Adam Jensen Hair"
	icon_state = "hair_jensen"
	gender = MALE

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"
	gender = FEMALE

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	gender = FEMALE

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"
	gender = FEMALE

/datum/sprite_accessory/hair/braid
	name = "Floorlength Braid"
	icon_state = "hair_braid"
	gender = FEMALE
	flags = HAIRSTYLE_CANTRIP

/datum/sprite_accessory/hair/kanade
	name = "Kanade"
	icon_state = "hair_kanade"
	gender = FEMALE

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	gender = FEMALE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"
	gender = FEMALE

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	gender = FEMALE

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"
	gender = MALE // turnoff!

/datum/sprite_accessory/hair/familyman
	name = "The Family Man"
	icon_state = "hair_thefamilyman"
	gender = MALE

/datum/sprite_accessory/hair/mahdrills
	name = "Drillruru"
	icon_state = "hair_drillruru"
	gender = FEMALE

/datum/sprite_accessory/hair/dandypomp
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"
	gender = MALE

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"
	gender = FEMALE

/datum/sprite_accessory/hair/poofy2
	name = "Poofy 2"
	icon_state = "hair_poofy2"
	gender = FEMALE

/datum/sprite_accessory/hair/crono
	name = "Toriyama"
	icon_state = "hair_toriyama"
	gender = MALE

/datum/sprite_accessory/hair/vegeta
	name = "Toriyama 2"
	icon_state = "hair_toriyama2"
	gender = MALE

/datum/sprite_accessory/hair/birdnest
	name = "Bird Nest"
	icon_state = "hair_birdnest"

/datum/sprite_accessory/hair/unkept
	name = "Unkempt"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/duelist
	name = "Duelist"
	icon_state = "hair_duelist"
	gender = MALE

/datum/sprite_accessory/hair/fastline
	name = "Fastline"
	icon_state = "hair_fastline"
	gender = MALE

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"
	gender = FEMALE

/datum/sprite_accessory/hair/unshavenmohawk
	name = "Unshaven Mohawk"
	icon_state = "hair_unshavenmohawk"
	gender = MALE

/datum/sprite_accessory/hair/drills
	name = "Twincurls"
	icon_state = "hair_twincurl"
	gender = FEMALE

/datum/sprite_accessory/hair/minidrills
	name = "Twincurls 2"
	icon_state = "hair_twincurl2"
	gender = FEMALE

/datum/sprite_accessory/hair/twintails
	name = "Twintails"
	icon_state = "hair_twintail"
	gender = FEMALE
	
/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"
	gender = MALE

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"
	gender = MALE

/datum/sprite_accessory/hair/scully
	name = "Scully"
	icon_state = "hair_scully"
	gender = FEMALE

/datum/sprite_accessory/hair/marisa
	name = "Marisa"
	icon_state = "hair_marisa"
	gender = FEMALE
	additional_accessories = 1

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	gender = FEMALE
	additional_accessories = 1

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	gender = MALE

/datum/sprite_accessory/hair/metal
	name = "Metal"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/edgeworth
	name = "Edgeworth"
	icon_state = "hair_edgeworth"
	gender = MALE

/datum/sprite_accessory/hair/objection
	name = "Objection!"
	icon_state = "hair_objection"
	gender = MALE

/datum/sprite_accessory/hair/dubs
	name = "Check 'Em"
	icon_state = "hair_dubs"
	gender = MALE

/datum/sprite_accessory/hair/swordsman
	name = "Black Swordsman"
	icon_state = "hair_blackswordsman"
	gender = MALE

/datum/sprite_accessory/hair/mentalist
	name = "Mentalist"
	icon_state = "hair_mentalist"
	gender = MALE

/datum/sprite_accessory/hair/fujisaki
	name = "Fujisaki"
	icon_state = "hair_fujisaki"
	gender = FEMALE

/datum/sprite_accessory/hair/schierke
	name = "Schierke"
	icon_state = "hair_schierke"
	gender = FEMALE

/datum/sprite_accessory/hair/akari
	name = "Akari"
	icon_state = "hair_akari"
	gender = FEMALE

/datum/sprite_accessory/hair/fujiyabashi
	name = "Fujuyabashi"
	icon_state = "hair_fujiyabashi"
	gender = FEMALE

/datum/sprite_accessory/hair/nia
	name = "Nia"
	icon_state = "hair_nia"
	gender = FEMALE

/datum/sprite_accessory/hair/shinobu
	name = "Shinobu"
	icon_state = "hair_shinobu"
	gender = FEMALE

/datum/sprite_accessory/hair/halfshave
	name = "Half-shave"
	icon_state = "hair_halfshave"

/datum/sprite_accessory/hair/nightcrawler
	name = "Nightcrawler"
	icon_state = "hair_nightcrawler"

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "hair_manbun"
	gender = MALE

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair

	icon = 'icons/mob/human_face.dmi'
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "bald"
	gender = NEUTER
	species_allowed = list("Human","Manifested","Unathi","Tajaran","Skrell","Vox","Grey","Plasmaman","Skellington","Diona","Muton","Golem","Skeletal Vox","Horror","Ghoul","Slime","Mushroom", "Evolved Slime")

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "facial_elvis"
	species_allowed = list("Human","Manifested","Unathi")

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/jensen
	name = "Adam Jensen Beard"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/britstache
	name = "Brit Stache"
	icon_state = "facial_britstache"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Martial Artist"
	icon_state = "facial_martialartist"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Moonshiner"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/tribeard
	name = "Tri-beard"
	icon_state = "facial_tribeard"

/datum/sprite_accessory/facial_hair/unshaven
	name = "Unshaven"
	icon_state = "facial_unshaven"

// Before Goon gets all hot and bothered for "stealing":
// A. It's property of SEGA in the first place
// B. I sprited this by hand, despite Steve's pleas to the contrary.  I've never played on your server and probably never will.
// - Nexypoo
/datum/sprite_accessory/facial_hair/robotnik
	name = "Robotnik Mustache"
	icon_state = "facial_robotnik"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair/una_spines_long
	name = "Long Unathi Spines"
	icon_state = "soghun_longspines"
	species_allowed = list("Unathi")
	do_colouration = 0

/datum/sprite_accessory/hair/una_spines_short
	name = "Short Unathi Spines"
	icon_state = "soghun_shortspines"
	species_allowed = list("Unathi")
	do_colouration = 0

/datum/sprite_accessory/hair/una_frills_long
	name = "Long Unathi Frills"
	icon_state = "soghun_longfrills"
	species_allowed = list("Unathi")
	do_colouration = 0

/datum/sprite_accessory/hair/una_frills_short
	name = "Short Unathi Frills"
	icon_state = "soghun_shortfrill"
	species_allowed = list("Unathi")
	do_colouration = 0

/datum/sprite_accessory/hair/una_horns
	name = "Unathi Horns"
	icon_state = "soghun_horns"
	species_allowed = list("Unathi")
	do_colouration = 0

/datum/sprite_accessory/hair/skr_tentacle_m
	name = "Skrell Male Tentacles"
	icon_state = "skrell_hair_m"
	species_allowed = list("Skrell")
	gender = MALE
	do_colouration = 0

/datum/sprite_accessory/hair/skr_tentacle_f
	name = "Skrell Female Tentacles"
	icon_state = "skrell_hair_f"
	species_allowed = list("Skrell")
	gender = FEMALE
	do_colouration = 0

/datum/sprite_accessory/hair/skr_gold_m
	name = "Gold plated Skrell Male Tentacles"
	icon_state = "skrell_goldhair_m"
	species_allowed = list("Skrell")
	gender = MALE
	do_colouration = 0

/datum/sprite_accessory/hair/skr_gold_f
	name = "Gold chained Skrell Female Tentacles"
	icon_state = "skrell_goldhair_f"
	species_allowed = list("Skrell")
	gender = FEMALE
	do_colouration = 0

/datum/sprite_accessory/hair/skr_clothtentacle_m
	name = "Cloth draped Skrell Male Tentacles"
	icon_state = "skrell_clothhair_m"
	species_allowed = list("Skrell")
	gender = MALE
	do_colouration = 0

/datum/sprite_accessory/hair/skr_clothtentacle_f
	name = "Cloth draped Skrell Female Tentacles"
	icon_state = "skrell_clothhair_f"
	species_allowed = list("Skrell")
	gender = FEMALE
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears
	name = "Tajaran Ears"
	icon_state = "ears_plain"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_black
	name = "Black Tajaran Ears"
	icon_state = "ears_black"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_clean
	name = "Tajara Clean"
	icon_state = "hair_clean"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_shaggy
	name = "Tajara Shaggy"
	icon_state = "hair_shaggy"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_mohawk
	name = "Tajaran Mohawk"
	icon_state = "hair_mohawk"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_plait
	name = "Tajara Plait"
	icon_state = "hair_plait"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_straight
	name = "Tajara Straight"
	icon_state = "hair_straight"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_long
	name = "Tajara Long"
	icon_state = "hair_long"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_rattail
	name = "Tajara Rat Tail"
	icon_state = "hair_rattail"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_spiky
	name = "Tajara Spiky"
	icon_state = "hair_tajspiky"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/taj_ears_messy
	name = "Tajara Messy"
	icon_state = "hair_messy"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_kingly
	name = "Vox Kingly"
	icon_state = "vox_kingly"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_afro
	name = "Vox Afro"
	icon_state = "vox_afro"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_mohawk
	name = "Vox Mohawk"
	icon_state = "vox_mohawk"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_yasu
	name = "Vox Yasuhiro"
	icon_state = "vox_yasu"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_horns
	name = "Vox Quorns"
	icon_state = "vox_horns"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/vox_quills_nights
	name = "Vox Nights"
	icon_state = "vox_nights"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/hair/diona_popcorn
	name = "Popped Hair"
	icon_state = "hair_popcorn"
	species_allowed = list("Diona")
	do_colouration = 0

/datum/sprite_accessory/hair/slime_tendrils
	name = "Long Tendrils"
	icon_state = "slime_tendrils"
	species_allowed = list("Evolved Slime")

/datum/sprite_accessory/hair/slime_spikes
	name = "Spikes"
	icon_state = "slime_spikes"
	species_allowed = list("Evolved Slime")

/datum/sprite_accessory/hair/slime_droplet
	name = "Droplet"
	icon_state = "slime_droplet"
	species_allowed = list("Evolved Slime")

/datum/sprite_accessory/hair/slime_suu
	name = "Wiggly"
	icon_state = "slime_suu"
	species_allowed = list("Evolved Slime")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "facial_mutton"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_mutton
	name = "Tajara Mutton"
	icon_state = "facial_mutton"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "facial_pencilstache"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_moustache
	name = "Tajara Moustache"
	icon_state = "facial_moustache"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_goatee
	name = "Tajara Goatee"
	icon_state = "facial_goatee"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/taj_smallstache
	name = "Tajara Smallsatche"
	icon_state = "facial_smallstache"
	species_allowed = list("Tajaran")
	do_colouration = 0

/datum/sprite_accessory/facial_hair/vox_face_colonel
	name = "Vox Colonel"
	icon_state = "vox_colonel"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/facial_hair/vox_face_fu
	name = "Quill Fu"
	icon_state = "vox_fu"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/facial_hair/vox_face_neck
	name = "Neck Quills"
	icon_state = "vox_neck"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

/datum/sprite_accessory/facial_hair/vox_face_beard
	name = "Quill Beard"
	icon_state = "vox_beard"
	species_allowed = list(VOX_SHAPED)
	do_colouration = 0

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list("Human")

/datum/sprite_accessory/skin/human_tatt01
	name = "Tatt01 human skin"
	icon_state = "tatt1"
	species_allowed = list("Human")

/datum/sprite_accessory/skin/tajaran
	name = "Default tajaran skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_tajaran.dmi'
	species_allowed = list("Tajaran")

/datum/sprite_accessory/skin/unathi
	name = "Default Unathi skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_lizard.dmi'
	species_allowed = list("Unathi")

/datum/sprite_accessory/skin/skrell
	name = "Default skrell skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_skrell.dmi'
	species_allowed = list("Skrell")

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "mohawk"
