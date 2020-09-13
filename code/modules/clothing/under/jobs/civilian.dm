//Alphabetical order of civilian jobs.
/obj/item/clothing/under/rank/barber
	desc = "This outfit comes in packs of four."
	name = "barber's uniform"
	icon_state = "barber"
	item_state = "barber"
	_color = "barber"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	_color = "ba_suit"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/btc_bartender
	desc = "Sanctioned by the BTC. Including the tights."
	name = "BTC bartender's uniform"
	icon_state = "btc_bartender"
	item_state = "btc_bartender"
	_color = "btc_bartender"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')


/obj/item/clothing/under/rank/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "caparmor"
	_color = "captain"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	_color = "qm"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	_color = "cargo"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	_color = "chapblack"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"
	_color = "chef"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	_color = "clown"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	_color = "hop"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "hydroponicist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	_color = "hydroponics"
	permeability_coefficient = 0.50
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/rank/botany
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. For the more garden-minded botanist."
	name = "botanist's jumpsuit"
	icon_state = "botany"
	item_state = "botany"
	_color = "botany"
	permeability_coefficient = 0.50
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED)


/obj/item/clothing/under/rank/beekeeper
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. Hopefully bees will see you as one of them."
	name = "beekeeper's jumpsuit"
	icon_state = "beekeeper"
	item_state = "g_suit"
	_color = "beekeeper"
	permeability_coefficient = 0.50
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED)


/obj/item/clothing/under/rank/gardener
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. For those who value the embelishment of the station."
	name = "gardener's jumpsuit"
	icon_state = "gardener"
	item_state = "g_suit"
	_color = "gardener"
	permeability_coefficient = 0.50
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED)


/obj/item/clothing/under/rank/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	_color = "internalaffairs"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	_color = "janitor"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/lawyer
	desc = "Slick threads."
	name = "Lawyer suit"
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/under/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	_color = "lawyer_black"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/lawyer/female
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	_color = "black_suit_fem"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/lawyer/red
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	_color = "lawyer_red"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lawyer/blue
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	_color = "lawyer_blue"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/lawyer/bluesuit
	name = "Blue Suit"
	desc = "A classy suit and tie."
	icon_state = "bluesuit"
	item_state = "bluesuit"
	_color = "bluesuit"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/lawyer/purpsuit
	name = "Purple Suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	_color = "lawyer_purp"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/under/lawyer/oldman
	name = "Old Man's Suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	_color = "oldman"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)


/obj/item/clothing/under/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	_color = "red_suit"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	_color = "mime"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)


/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	_color = "miner"
	clothing_flags = ONESIZEFITSALL
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/under/bridgeofficer
	name = "bridge officer uniform"
	desc = "A jumpsuit for those ranked high enough to stand at the bridge, but not high enough to touch any buttons."
	icon_state = "bridgeofficer"
	item_state = "bridgeofficer"
	_color = "bridgeofficer"
	clothing_flags = ONESIZEFITSALL
