/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	species_fit = list(INSECT_SHAPED)
	desc = "It's good to be emperor."
	flags = FPRINT
	item_state = "centhat"
	siemens_coefficient = 0.9

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	species_fit = list(INSECT_SHAPED)
	desc = "Smells nice."
	item_state = "hairflower"
	flags = FPRINT

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/that
	name = "top hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	siemens_coefficient = 0.9
	wizard_garb = 5 //Treat this as a % chance to be a magic hat to start. It becomes TRUE/FALSE later.
	var/timer

/obj/item/clothing/head/that/New()
	..()
	if(prob(wizard_garb))
		desc = "It's a magic looking hat."
		wizard_garb = TRUE
	else
		wizard_garb = FALSE

/obj/item/clothing/head/that/attackby(obj/item/W, mob/user)
	if(wizard_garb)
		var/static/list/allowed_wands = list(/obj/item/item_handle, /obj/item/weapon/cane, /obj/item/weapon/nullrod, /obj/item/weapon/staff)
		if(is_type_in_list(W, allowed_wands))
			if(world.time - timer >= 20 SECONDS)
				timer = world.time
				user.visible_message("<span class='notice'>[user] taps \the [name] with \the [W] and a rabbit pops out of \the [name]!</span>","<span class='notice'>You tap \the [name] with \the [W] and a rabbit pops out of \the [name]!</span>")
				new/mob/living/simple_animal/rabbit(get_turf(src))
	..()

/obj/item/clothing/head/that/magic
	wizard_garb = 100

/obj/item/clothing/head/that/armored
	name = "armored top hat"
	desc = "It's an amish looking top hat. This one looks sturdier."
	armor = list(melee = 35, bullet = 15, laser = 30, energy = 5, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	flags = FPRINT

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."
	flags = FPRINT
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	sterility = 100

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish."
	icon_state = "hasturhood"
	species_fit = list(INSECT_SHAPED)
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	body_parts_visible_override = FACE

/obj/item/clothing/head/vamphunter
	name = "vampire hunter circlet"
	desc = "A golden chain circlet which gives the impression of a halo."
	icon_state = "vamphunter"
	item_state = "vamphunter"
	species_fit = list(INSECT_SHAPED)
	body_parts_covered = NONE

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	siemens_coefficient = 0.9

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|HIDEHEADHAIR
	siemens_coefficient = 2.0
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/spaceninjafake
	name = "ninja hood replica"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	desc = "A plastic replica of a space ninja's hood, you'll look just like a real murderous space ninja in this! This is a toy, it is not made for use in space!"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD|HIDEHEADHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/opsfake
	name = "blood-red hardsuit helmet"
	desc = "A plastic replica of a nuclear operative's helmet, you'll look just like a real murderous syndicate operative in this! This is a toy, it is not made for use in space!"
	icon_state = "rig0-syndi"
	item_state = "syndie_helm"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = FULL_HEAD|HIDEHEADHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/timefake
	name = "time helmet"
	desc = "A replica of the time helmet worn by the original Looper, the one who saved us from the collapsing timeline. We remember."
	icon_state = "time_helmet"
	item_state = "time_helmet"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, SKRELL_SHAPED, UNATHI_SHAPED, TAJARAN_SHAPED, INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = FULL_HEAD|HIDEHEADHAIR
	siemens_coefficient = 1.0

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD|HIDEHEADHAIR
	item_state="cueball"

/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/beret/highlander
	name = "highlander's beret"
	desc = "Don't lose your head!"
	icon_state = "highlanderberet"
	item_state = "highlanderberet"
	species_fit = list(INSECT_SHAPED)
	wizard_garb = 1 //required for the spell in the highlander syndicate bundle

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/clothing/head/cardborg/affect_speech(var/datum/speech/speech, var/mob/living/L)
	if(L.is_wearing_item(src, slot_head))
		speech.message_classes.Add("siliconsay")

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD|MASKHEADHAIR

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
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	species_fit = list(INSECT_SHAPED)
	siemens_coefficient = 0.9

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/sith
	name = "Sith Cowl"
	desc = "UNLIMITED POWER!"
	icon_state = "sith"
	item_state = "sith"
	species_fit = list(INSECT_SHAPED)
	body_parts_covered = HIDEHAIR|HIDEBEARDHAIR
	wizard_garb = 1 //Allows lightning to be used

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For that industrial age look."
	flags = FPRINT
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	species_fit = list(INSECT_SHAPED)
	desc = "Like a top hat, but made of beavers."
	flags = FPRINT

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "Goes well with celery."
	flags = FPRINT
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

/obj/item/clothing/head/squatter_hat
	name = "slav squatter hat"
	icon_state = "squatter_hat"
	item_state = "squatter_hat"
	species_fit = list(INSECT_SHAPED)
	desc = "Cyka blyat."
	flags = FPRINT

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	actions_types = list(/datum/action/item_action/tip_fedora)
	desc = "A great hat ruined by being within fifty yards of you."
	flags = FPRINT
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/fedora/OnMobLife(var/mob/living/carbon/human/wearer)
	if(!istype(wearer))
		return
	if(wearer.get_item_by_slot(slot_head) == src)
		if(prob(1))
			to_chat(wearer, "<span class=\"warning\">You feel positively euphoric!</span>")

//TIPS FEDORA
/obj/item/clothing/head/fedora/proc/tip_fedora(mob/user)
	if(user.attack_delayer.blocked())
		return
	user.visible_message("[user] tips \his fedora.", "You tip your fedora.")
	user.delayNextAttack(1 SECONDS)

/datum/action/item_action/tip_fedora
	name = "Tip Fedora"

/datum/action/item_action/tip_fedora/Trigger()
	var/obj/item/clothing/head/fedora/T = target
	if(!istype(T))
		return
	T.tip_fedora(usr)

/obj/item/clothing/head/fedora/white
	name = "white fedora"
	icon_state = "fedora_white"
	species_fit = list(INSECT_SHAPED)
	desc = "A great white hat ruined by being within fifty yards of you."

/obj/item/clothing/head/fedora/brown
	name = "brown fedora"
	icon_state = "fedora_brown"
	species_fit = list(INSECT_SHAPED)
	desc = "Don't you even think about losing it."

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "Put it on your monkey, make lots of cash money."
	flags = FPRINT
	species_fit = list(GREY_SHAPED,VOX_SHAPED,INSECT_SHAPED)

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickenhead"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/chicken/white
	name = "white chicken suit head"
	desc = "Caw!"
	icon_state = "chickenhead_white"
	item_state = "chickenhead_white"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/bearpelt
	name = "cheap bear pelt hat"
	desc = "Not as fuzzy as the real thing."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	body_parts_covered = EARS|HEAD|HIDEHEADHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/bearpelt/real
	name = "bear pelt hat"
	desc = "Now that's what I call fuzzy."

/obj/item/clothing/head/bearpelt/real/spare
	name = "spare bear pelt"
	desc = "It shimmers in the light"
	icon_state = "sparebearpelt"
	item_state = "sparebearpelt"
	slot_flags = SLOT_ID|SLOT_HEAD
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/bearpelt/real/spare/GetAccess()
	if(arcanetampered)
		return ..()
	return get_all_accesses()

/obj/item/clothing/head/bearpelt/black
	name = "bear pelt hat"
	desc = "Just like the pelt of a space bear without as much space."
	icon_state = "blackbearpelt"
	item_state = "blackbearpelt"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/bearpelt/brown
	name = "brown bear pelt hat"
	desc = "Faded and rough, it almost passes as a real pelt."
	icon_state = "brownbearpeltfake"
	item_state = "brownbearpeltfake"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/bearpelt/brown/real
	name = "brown bear pelt hat"
	desc = "Now that's what I call fuzzy."
	icon_state = "brownbearpelt"
	item_state = "brownbearpelt"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/bearpelt/polar
	name = "bear pelt hat"
	desc = "For those polar chills."
	icon_state = "polarbearpelt"
	item_state = "polarbearpelt"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/bearpelt/panda
	name = "panda pelt hat"
	desc = "Makes you want to chew on bamboo sticks."
	icon_state = "pandbearpelt"
	item_state = "pandbearpelt"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/wolfpelt
	name = "wolf pelt hat"
	desc = "Atop your head is one wolf."
	icon_state = "wolfpelt"
	item_state = "wolfpelt"
	armor = list(melee = 10, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)
	body_parts_covered =  EARS|HEAD|HIDEHEADHAIR
	species_fit = list(VOX_SHAPED)


/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	desc = "A helmet made out of chitinous alien hide."
	body_parts_covered = FULL_HEAD|BEARD|HIDEHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/batman
	name = "bathelmet"
	desc = "No one cares who you are until you put on the mask."
	icon_state = "bmhead"
	item_state = "bmhead"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT
	body_parts_covered = HEAD|EARS|EYES

/obj/item/clothing/head/stalhelm
	name = "Stalhelm"
	desc = "Ein Helm, um die Nazi-Interesse an fremden Raumstationen zu sichern."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/panzer
	name = "Panzer Cap"
	desc = "Ein Hut passen nur für die größten Tanks."
	icon_state = "panzercap"
	item_state = "panzercap"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/naziofficer
	name = "Officer Cap"
	desc = "Ein Hut von Offizieren in der Nazi-Partei getragen."
	icon_state = "officercap"
	item_state = "officercap"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/russobluecamohat
	name = "russian blue camo beret"
	desc = "A symbol of discipline, honor, and lots and lots of removal of some type of skewered food."
	icon_state = "russobluecamohat"
	item_state = "russobluecamohat"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/russofurhat
	name = "russian fur hat"
	desc = "Russian winter got you down? Maybe your enemy, but not you!"
	icon_state = "russofurhat"
	item_state = "russofurhat"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/lordadmiralhat
	name = "lord admiral's hat"
	desc = "A hat suitable for any man of high and exalted rank."
	icon_state = "lordadmiralhat"
	item_state = "lordadmiralhat"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/jesterhat
	name = "jester hat"
	desc = "A hat fit for a fool."
	icon_state = "jesterhat"
	item_state = "jesterhat"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/libertyhat
	name = "liberty top hat"
	desc = "Show everyone just how patriotic you are."
	icon_state = "libertyhat"
	item_state = "libertyhat"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/maidhat
	name = "maid headband"
	desc = "Do these even do anything besides look cute?"
	icon_state = "maidhat"
	item_state = "maidhat"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/maidhat
	name = "maid headband"
	desc = "Do these even do anything besides look cute?"
	icon_state = "maidhat"
	item_state = "maidhat"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/mitre
	name = "mitre"
	desc = "A funny hat worn by extremely boring people."
	icon_state = "mitre"
	item_state = "mitre"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/clownpiece
	name = "Clownpiece's jester hat"
	desc = "A purple polka-dotted jester's hat with yellow pompons."
	icon_state = "clownpiece"
	item_state = "clownpiece"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/headband
	name = "head band"
	desc = "You wear this around your head."
	icon_state = "headband"
	item_state = "headband"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/metalgear.dmi', "right_hand" = 'icons/mob/in-hand/right/metalgear.dmi')

/obj/item/clothing/head/cowboy
	name = "cowboy hat"
	desc = "Perfect for the closet botanist."
	icon_state = "cowboy"
	item_state = "cowboy"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	armor = list(melee = 0, bullet = 10, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/cowboy/dimma
	name = "ten million gallon hat"
	desc = "A soaring monument to the power and ego of its wearer. Only the most powerful of men can support a hat of such unparalleled height without being crushed."
	icon = 'icons/obj/dimma.dmi'
	icon_state = "cowboydimma"
	wear_override = new/icon("icon" = 'icons/mob/dimma.dmi', "icon_state" = "cowboydimma")

/obj/item/clothing/head/christmas/santahat/red
	name = "red santa hat"
	desc = "Not quite as magical as the real thing, but it flops over one ear and itches your head just the same."
	icon_state = "santahatred"
	item_state = "santahatred"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/head/christmas/santahat/green
	name = "green santa hat"
	desc = "Not quite as magical as the real thing, but it flops over one ear and itches your head just the same."
	icon_state = "santahatgreen"
	item_state = "santahatgreen"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/head/christmas/santahat/blue
	name = "blue santa hat"
	desc = "Not quite as magical as the real thing, but it flops over one ear and itches your head just the same."
	icon_state = "santahatblue"
	item_state = "santahatblue"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)


/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	item_state = "xmashat"
	species_fit = list(INSECT_SHAPED)
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags = FPRINT
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/pajamahat
	name = "pajama hat"
	desc = "This looks pretty damn comfortable."
	heat_conductivity = INS_HELMET_HEAT_CONDUCTIVITY

/obj/item/clothing/head/pajamahat/red
	icon_state = "pajamahat_red"
	item_state = "pajamahat_red"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/pajamahat/blue
	icon_state = "pajamahat_blue"
	item_state = "pajamahat_blue"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/mummy_rags
	name = "mummy rags"
	desc = "Ancient rags taken off from some mummy."
	icon_state = "mummy"
	item_state = "mummy"
	_color = "mummy"

/obj/item/clothing/head/dunce_cap
	name = "dunce cap"
	desc = "A conical paper hat which used to be used as a punishment in schools. Misbehaving children had to wear it while standing in a corner. The writing on it says \"DUNCE\"."
	icon_state = "duncecap"
	item_state = "duncecap"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/party_hat
	name = "party hat"
	desc = "A party cone. Not useful to disguise one's self as a unicorn or to impale one's foes."
	icon_state = "birthdayhat"
	item_state = "birthdayhat"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/snake
	name = "snake head"
	desc = "Reenact acts of violence against reptiles, or sneak into a swamp unnoticed."
	icon_state = "snakehead"
	item_state = "snakehead"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/clockwork_hood
	name = "clockwork hood"
	icon_state = "clockwork"
	item_state = "clockwork"
	species_fit = list(INSECT_SHAPED)
	desc = "A hood worn by the followers of Ratvar."
	flags = FPRINT

/obj/item/clothing/head/franken_bolt
	name = "neck bolts"
	desc = "The result of extreme medical malpractice to save a patient, or a trip to the robotics lab."
	icon_state = "neckbolts"
	item_state = "neckbolts"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/alien_antenna
	name = "alien antennae"
	desc = "Take us to your leader/captain/clown."
	icon_state = "antennae"
	item_state = "antennae"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/devil_horns
	name = "devil horns"
	desc = "Might be slightly offensive to your local chaplain."
	icon_state = "devil_horns"
	item_state = "devil_horns"
	species_fit = list(INSECT_SHAPED)
	flags = FPRINT

/obj/item/clothing/head/elfhat
	name = "elf hat"
	desc = "Wear this hat, and become one of Santa's little helpers!"
	icon_state = "elf_hat"
	item_state = "elf_hat"
	species_fit = list(INSECT_SHAPED)
	body_parts_covered = HEAD|EARS
	wizard_garb = 1 //being elf cursed wont prevent you casting robed spells if wizard

/obj/item/clothing/head/elfhat/stickymagic
	canremove = 0

/obj/item/clothing/head/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"
	item_state = "rice_hat"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/head/rice_hat/ronin
	name = "roningasa"
	desc = "A conical amigasa with a flat top, often worn by ronin."
	icon_state = "kasa"
	item_state = "kasa"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/inquisitor
	name = "cappello romano"
	desc = "A round wide-brimmed hat worn by more traditional Roman Catholic clergy."
	icon_state = "brim-hat"
	item_state = "brim-hat"
	species_fit = list(INSECT_SHAPED)
	wizard_garb = TRUE
	armor = list(melee = 0, bullet = 0, laser = 15, energy = 15, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/widehat_red
	name = "red wide-brimmed hat"
	desc = "A red fancy looking wide-brimmed hat. It's even got a feather in it."
	icon_state = "widehat_red"
	item_state = "widehat_red"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/pharaoh
	name = "pharaoh's headpiece"
	desc = "An ornate golden headpiece worn by the ancient rulers of Space Egypt."
	icon_state = "pharaoh"
	item_state = "pharaoh"
	species_fit = list(INSECT_SHAPED)
	wizard_garb = TRUE
	body_parts_covered = FULL_HEAD|HEAD|EARS|MASKHEADHAIR

/obj/item/clothing/head/sombrero
	name = "sombrero"
	desc = "Meanwhile in Neo Space Mexico."
	icon_state = "sombrero"
	item_state = "sombrero"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/head/donitos_pope
	name = "\improper Donitos Pope hat"
	desc = "An oversized Donitos promotional plastic donut-shaped hat."
	icon_state = "donitos_pope"
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/head/banana_hat
	name = "banana hat"
	desc = "Ring ring ring ring ring ring ring." //BANANA PHONE!
	icon_state = "banana_hat"
	item_state = "banana_hat"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	body_parts_covered = HEAD|EARS|MASKHEADHAIR

/obj/item/clothing/head/bteamcaptain
    name = "\improper Burning Team Captain"
    icon_state = "bteamcaptain"
    desc = "For the man who can get his team to actually push the payload on Hightower."
    flags = FPRINT
    item_state = "bteamcaptain"
    siemens_coefficient = 0.9

var/image/unusual_overlay = image('icons/mob/head.dmi', "unusual_overlay", pixel_y = 15)
/obj/item/clothing/head/bteamcaptain/equipped(mob/user)
    user.overlays += unusual_overlay
    return ..()

/obj/item/clothing/head/bteamcaptain/unequipped(mob/user)
    user.overlays -= unusual_overlay
    return ..()

/obj/item/clothing/head/kippah
	name = "kippah"
	desc = "A brimless hat made of cloth, worn by men within Orthdox Jewish communities as part of religious custom."
	flags = FPRINT
	icon_state = "kippah_black"

/obj/item/clothing/head/kippah/kippah_random

/obj/item/clothing/head/kippah/kippah_random/New()
	icon_state = "kippah_[pick("blue","white","goldblack","black","yellow")]"

/obj/item/clothing/head/kippah/kippah_blue
	icon_state = "kippah_blue"
/obj/item/clothing/head/kippah/kippah_white
	icon_state = "kippah_white"
/obj/item/clothing/head/kippah/kippah_goldblack
	icon_state = "kippah_goldblack"
/obj/item/clothing/head/kippah/kippah_yellow
	icon_state = "kippah_yellow"

// American "football"

/obj/item/clothing/head/nt_football_helmet
	name = "NT football helmet"
	desc = "Where captain rigs go to die."
	flags = FPRINT
	icon_state = "ntfootballhelmet"

/obj/item/clothing/head/syndie_football_helmet
	name = "Syndie football helmet"
	desc = "It survived an explosive implant, it'll survive you."
	flags = FPRINT
	icon_state = "syndiefootballhelmet"