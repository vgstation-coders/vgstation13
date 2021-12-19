#define EMPTYZONE /obj/item/spessioh/card/emptyZone

/obj/machinery/spessioh/terminal
	name = "Spessioh Terminal"
	desc = "Spessioh"
	icon = 'icons/obj/spessioh.dmi'
	icon_state = "terminal_red"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE
	var/obj/machinery/spessioh/terminal/opponent = null
	var/duelist = null
	var/lifepoint = 20
	var/turnNumber = 0
	var/list/spellZones = list(EMPTYZONE, EMPTYZONE, EMPTYZONE, EMPTYZONE, EMPTYZONE)
	var/list/creatureZones = list(EMPTYZONE, EMPTYZONE, EMPTYZONE, EMPTYZONE, EMPTYZONE)
	var/list/cardsInHand = list()
	var/list/cardsInDeck = list()
	var/list/cardsInGrave = list()
	var/selectedDeck = null
	var/selectedCard = null
	var/activeEvent = null
	var/list/loadedDeck = list()
	var/list/preBuiltDeckOne = list(/obj/item/spessioh/card/space_carp)
	var/list/preBuiltDeckTwo = list(/obj/item/spessioh/card/space_carp)
	var/currentlyDueling = FALSE
	var/yourTurn = FALSE
	var/infoPanel = ""

////////////UI//////////////

/obj/machinery/spessioh/terminal/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = list(
		"opponent" = opponent,
		//"selectedDeck" = selectedDeck,
		"cardsInDeck" = cardsInDeck,
		"lifepoint" = lifepoint,
		"spellZones" = spellZones,
		"creatureZones" = creatureZones,
		"cardsInHand" = cardsInHand,
		"selectedCard" = selectedCard,
		"turnNumber" = turnNumber,
		"activeEvent" = activeEvent,
		"loadedDeck" = loadedDeck,
		"infoPanel" = infoPanel
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "spessioh.tmpl", "Spessioh", 800,800)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

/obj/machinery/spessioh/terminal/Topic(href, href_list)
	if(href_list["select_card"])
		selectedCard = href_list["select_card"]
		return TRUE
	if(href_list["choose_deck"])
		cardsInDeck = selectedCard.Copy()
		return TRUE
	if(href_list["ready_up"])
		if(selectedDeck)
			infoPanel = "Ready!"
			duelstart()
		else
			infoPanel = "Please select a deck"
		return TRUE

///////////Terminal setup stuff////////////////

/obj/machinery/spessioh/terminal/attackby(var/obj/item/O, mob/user as mob)
	..()
	if(istype(O, /obj/item/weapon/storage/spessiohsleeve))
		var/obj/item/weapon/storage/spessiohsleeve/D = O
		loadedDeck = D.contents.Copy()
		playsound(src, "sound/machines/twobeep.ogg", 75, 1)
		to_chat(user, "You scan your Spessioh deck into the terminal")

/obj/machinery/spessioh/terminal/attack_hand(user as mob)
	if(opponent == null)
		var/turf/I = get_ranged_target_turf(src, src.dir, 5)
		spark(I)
		for(var/obj/machinery/spessioh/terminal/O in I)
			if((O.opponent == null)||(O.opponent == src))
				opponent = O
				to_chat(user, "<span class='warning'>Opponent set.</span>")
			else
				to_chat(user, "<span class='warning'>That terminal already has a designated opponent.</span>")
		return
	if((opponent) && (opponent.opponent == src))
		duelist = user
		ui_interact(user)
		return
	to_chat(user, "<span class='warning'>Please wait for your opponent to pair.</span>")

/////////////We are now dueling//////////////

/obj/machinery/spessioh/terminal/proc/duelstart()
	currentlyDueling = TRUE
	infoPanel = "Matching.."
	spawn(5 SECONDS)
		if(!opponent.currentlyDueling)
			infoPanel = "Matching failure, please try again"
			currentlyDueling = FALSE
			selectedDeck = null
			return
		infoPanel = "Duel!"
		for(0 to 5)
			var/drawCard = pick(cardsInDeck)
			cardsInHand += drawCard
			cardsInDeck -= drawCard
			//playsound(src, ) forbidden memories card draw
			spawn(2)

/obj/machinery/spessioh/terminal/proc/playCard()
	if(selectedCard.cardSubtype == "creature")
		for(var/z in creatureZones.len)
			if(istype(z, EMPTYZONE))
				z = selectedCard
				return
		infoPanel = "Your creature zones are full"
		return
	if(selectedCard.cardSubtype == "spell")
		for(var/z in spellZones.len)
			if(istype(z, EMPTYZONE))
				z = selectedCard
				return
		infoPanel = "Your equipment zones are full"
		return




















/obj/item/weapon/storage/spessiohsleeve
	name = ""
	desc = ""
	icon = 'icons/obj/spessioh.dmi'
	icon_state = ""
	storage_slots = 20
	w_class = W_CLASS_SMALL
	fits_max_w_class = W_CLASS_LARGE
	//can_only_hold = list(/obj/item/spessioh/card)

/obj/item/weapon/storage/spessiohsleeve/paper
	name = "Paper deck sleeve"
	desc = "A spessioh deck sleeve. This one is made of paper"
	icon_state = "decksleeve_paper"

/obj/item/weapon/storage/spessiohsleeve/cardboard
	name = "Cardboard deck sleeve"
	desc = "A spessioh deck sleeve. This one is made of cardboard"
	icon_state = "decksleeve_cardboard"

/obj/item/weapon/storage/spessiohsleeve/leather
	name = "Leather deck sleeve"
	desc = "A spessioh deck sleeve. This one is made of leather, fancy"
	icon_state = "decksleeve_leather"

/obj/item/spessioh/card
	name = ""
	desc = ""
	icon = 'icons/obj/spessioh.dmi'
	icon_state = "creature_common"
	w_class = W_CLASS_SMALL
	var/cLife = 0
	var/cAttack = 0
	var/effect = ""
	var/inHandName = "" //In case it needs shortening for the UI
	var/cardSubtype = ""

/obj/item/spessioh/card/emptyZone //For displaying the icon in the UI and smoother list manipulation
	name = "empty zone"
	desc = ""
	icon = 'icons/obj/spessioh.dmi'
	icon_state = "empty_zone"
	w_class = W_CLASS_SMALL
	var/cLife = 0
	var/cAttack = 0
	var/effect = ""
	var/inHandName = ""
	var/cardSubtype = ""

/obj/item/spessioh/card/examine(mob/user as mob)
	..()
	to_chat(user, "Attack: [cAttack], Life: [cLife], Effect:[effect]")

/obj/item/spessioh/card/space_carp
	name = "Space Carp"
	desc = ""
	cLife = 2
	cAttack = 2
	effect = "If another Space Carp is on your side of the field, gib this card and spawn up to 4 baby carp"
	cardSubtype = "Creature"

///obj/item/spessioh/card/space_carp/proc/space_carp_activateEffect()
//	var/carpCount = 0
//	for(var/obj/item/spessioh/card/E in creatureZones)
//		if(istype(E, /obj/item/spessioh/card/space_carp))
//			carpCount += 1
//			if(carpCount >1)
//				creatureZones -= src
//				for(creatureZones.len to 5)
//					creatureZones += /obj/item/spessioh/card/baby_carp
//				return

///obj/item/spessioh/card/baby_carp
//	name = "Baby Carp"
//	desc = ""
//	creatureHealth = 1
//	attack = 2
//	effect = "None"
