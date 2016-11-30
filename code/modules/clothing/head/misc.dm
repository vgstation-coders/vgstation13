

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "centhat"
	siemens_coefficient = 0.9

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	siemens_coefficient = 0.9

/obj/item/clothing/head/that/armored
	name = "armored top-hat"
	desc = "It's an amish looking top hat. This one looks sturdier."
	armor = list(melee = 35, bullet = 15, laser = 30, energy = 5, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish."
	icon_state = "hasturhood"
	body_parts_covered = EARS|HEAD
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	body_parts_covered = FULL_HEAD
	siemens_coefficient = 2.0
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	item_state="cueball"
	starting_materials = METAL_HAT_COMPONENTS

/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags = FPRINT
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	siemens_coefficient = 0.9
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"
	starting_materials = CLOTH_HAT_COMPONENTS

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For that industrial age look."
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Like a top hat, but made of beavers."
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "Goes well with celery."
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/squatter_hat
	name = "slav squatter hat"
	icon_state = "squatter_hat"
	item_state = "squatter_hat"
	desc = "Cyka blyat."
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A great hat ruined by being within fifty yards of you."
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/fedora/OnMobLife(var/mob/living/carbon/human/wearer)
	if(!istype(wearer))
		return
	if(wearer.head == src)
		if(prob(1))
			to_chat(wearer, "<span class=\"warning\">You feel positively euphoric!</span>")

//TIPS FEDORA
/obj/item/clothing/head/fedora/verb/tip_fedora()
	set name = "Tip Fedora"
	set category = "Object"
	set desc = "Show that CIS SCUM who's boss." //I'm pretty sure you're mincing memes here, but whatever

	usr.visible_message("[usr] tips \his fedora.", "You tip your fedora.")

/obj/item/clothing/head/fedora/white
	name = "white fedora"
	icon_state = "fedora_white"
	desc = "A great white hat ruined by being within fifty yards of you."

/obj/item/clothing/head/fedora/brown
	name = "brown fedora"
	icon_state = "fedora_brown"
	desc = "Don't you even think about losing it."

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "Put it on your monkey, make lots of cash money."
	starting_materials = CLOTH_HAT_COMPONENTS

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags = FPRINT
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 2.0

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	body_parts_covered = FULL_HEAD|BEARD
	siemens_coefficient = 2.0

/obj/item/clothing/head/bearpelt
	name = "cheap bear pelt hat"
	desc = "Not as fuzzy as the real thing."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 2.0

/obj/item/clothing/head/bearpelt/real
	name = "bear pelt hat"
	desc = "Now that's what I call fuzzy."

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	siemens_coefficient = 2.0

/obj/item/clothing/head/batman
	name = "bathelmet"
	desc = "No one cares who you are until you put on the mask."
	icon_state = "bmhead"
	item_state = "bmhead"
	flags = FPRINT
	body_parts_covered = HEAD|EARS|EYES

/obj/item/clothing/head/stalhelm
	name = "Stalhelm"
	desc = "Ein Helm, um die Nazi-Interesse an fremden Raumstationen zu sichern."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	flags = FPRINT

/obj/item/clothing/head/panzer
	name = "Panzer Cap"
	desc = "Ein Hut passen nur für die größten Tanks."
	icon_state = "panzercap"
	item_state = "panzercap"
	flags = FPRINT

/obj/item/clothing/head/naziofficer
	name = "Officer Cap"
	desc = "Ein Hut von Offizieren in der Nazi-Partei getragen."
	icon_state = "officercap"
	item_state = "officercap"
	flags = FPRINT

/obj/item/clothing/head/russobluecamohat
	name = "russian blue camo beret"
	desc = "A symbol of discipline, honor, and lots and lots of removal of some type of skewered food."
	icon_state = "russobluecamohat"
	item_state = "russobluecamohat"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/russofurhat
	name = "russian fur hat"
	desc = "Russian winter got you down? Maybe your enemy, but not you!"
	icon_state = "russofurhat"
	item_state = "russofurhat"
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/lordadmiralhat
	name = "lord admiral's hat"
	desc = "A hat suitable for any man of high and exalted rank."
	icon_state = "lordadmiralhat"
	item_state = "lordadmiralhat"
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/jesterhat
	name = "jester hat"
	desc = "A hat fit for a fool."
	icon_state = "jesterhat"
	item_state = "jesterhat"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/libertyhat
	name = "liberty top hat"
	desc = "Show everyone just how patriotic you are."
	icon_state = "libertyhat"
	item_state = "libertyhat"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/maidhat
	name = "maid headband"
	desc = "Do these even do anything besides look cute?"
	icon_state = "maidhat"
	item_state = "maidhat"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/mitre
	name = "mitre"
	desc = "A funny hat worn by extremely boring people."
	icon_state = "mitre"
	item_state = "mitre"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/clownpiece
	name = "Clownpiece's jester hat"
	desc = "A purple polka-dotted jester's hat with yellow pompons."
	icon_state = "clownpiece"
	item_state = "clownpiece"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/headband
	name = "head band"
	desc = "You wear this around your head."
	icon_state = "headband"
	item_state = "headband"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/metalgear.dmi', "right_hand" = 'icons/mob/in-hand/right/metalgear.dmi')
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/cowboy
	name = "cowboy hat"
	desc = "Pefect for the closet botanist."
	icon_state = "cowboy"
	item_state = "cowboy"
	starting_materials = LEATHER_HAT_COMPONENTS

/obj/item/clothing/head/christmas/santahat/red
	name = "red santa hat"
	desc = "Not quite as magical as the real thing, but it flops over one ear and itches your head just the same."
	icon_state = "santahatred"
	item_state = "santahatred"

/obj/item/clothing/head/christmas/santahat/green
	name = "green santa hat"
	desc = "Not quite as magical as the real thing, but it flops over one ear and itches your head just the same."
	icon_state = "santahatgreen"
	item_state = "santahatgreen"

/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	item_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/pajamahat
	name = "pajama hat"
	desc = "This looks pretty damn comfortable."
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/pajamahat/red
	icon_state = "pajamahat_red"
	item_state = "pajamahat_red"

/obj/item/clothing/head/pajamahat/blue
	icon_state = "pajamahat_blue"
	item_state = "pajamahat_blue"

/obj/item/clothing/head/mummy_rags
	name = "mummy rags"
	desc = "Ancient rags taken off from some mummy."
	icon_state = "mummy"
	item_state = "mummy"
	_color = "mummy"
	starting_materials = CLOTH_HAT_COMPONENTS

/obj/item/clothing/head/dunce_cap
	name = "dunce cap"
	desc = "A conical paper hat which used to be used as a punishment in schools. Misbehaving children had to wear it while standing in a corner. The writing on it says \"DUNCE\"."
	icon_state = "duncecap"
	item_state = "duncecap"

/obj/item/clothing/head/snake
	name = "snake head"
	desc = "Reenact acts of violence against reptiles, or sneak into a swamp unnoticed."
	icon_state = "snakehead"
	item_state = "snakehead"

/obj/item/clothing/head/turban
	name = "turban"
	desc = "A long piece of cloth wrapped around the head."
	icon_state = "turban"
