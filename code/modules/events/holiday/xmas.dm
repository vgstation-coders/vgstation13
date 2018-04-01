/obj/item/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = 0

/obj/item/toy/xmas_cracker/attack(mob/target, mob/user)
	if( !cracked && ishuman(target) && (target.stat == CONSCIOUS) && !target.get_active_held_item() )
		target.visible_message("[user] and [target] pop \an [src]! *pop*", "<span class='notice'>You pull \an [src] with [target]! *pop*</span>", "<span class='italics'>You hear a pop.</span>")
		var/obj/item/paper/Joke = new /obj/item/paper(user.loc)
		Joke.name = "[pick("awful","terrible","unfunny")] joke"
		Joke.info = pick("What did one snowman say to the other?\n\n<i>'Is it me or can you smell carrots?'</i>",
			"Why couldn't the snowman get laid?\n\n<i>He was frigid!</i>",
			"Where are santa's helpers educated?\n\n<i>Nowhere, they're ELF-taught.</i>",
			"What happened to the man who stole advent calanders?\n\n<i>He got 25 days.</i>",
			"What does Santa get when he gets stuck in a chimney?\n\n<i>Claus-trophobia.</i>",
			"Where do you find chili beans?\n\n<i>The north pole.</i>",
			"What do you get from eating tree decorations?\n\n<i>Tinsilitis!</i>",
			"What do snowmen wear on their heads?\n\n<i>Ice caps!</i>",
			"Why is Christmas just like life on ss13?\n\n<i>You do all the work and the fat guy gets all the credit.</i>",
			"Why doesn�t Santa have any children?\n\n<i>Because he only comes down the chimney.</i>")
		new /obj/item/clothing/head/festive(target.loc)
		user.update_icons()
		cracked = 1
		icon_state = "cracker1"
		var/obj/item/toy/xmas_cracker/other_half = new /obj/item/toy/xmas_cracker(target)
		other_half.cracked = 1
		other_half.icon_state = "cracker2"
		target.put_in_active_hand(other_half)
		playsound(user, 'sound/effects/snap.ogg', 50, 1)
		return 1
	return ..()

/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags_inv = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/effect/landmark/xmastree
	name = "christmas tree spawner"
	layer = FLY_LAYER
	var/festive_tree = /obj/structure/flora/tree/pine/xmas
	var/christmas_tree = /obj/structure/flora/tree/pine/xmas/presents

/obj/effect/landmark/xmastree/Initialize(mapload)
	..()
	if((CHRISTMAS in SSevents.holidays) && christmas_tree)
		new christmas_tree(get_turf(src))
	else if((FESTIVE_SEASON in SSevents.holidays) && festive_tree)
		new festive_tree(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xmastree/rdrod
	name = "festivus pole spawner"
	festive_tree = /obj/structure/festivus
	christmas_tree = null

/datum/round_event_control/santa
	name = "Santa is coming to town! (Christmas)"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/santa
	weight = 20
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/santa
	var/mob/living/carbon/human/santa //who is our santa?

/datum/round_event/santa/announce(fake)
	priority_announce("Santa is coming to town!", "Unknown Transmission")

/datum/round_event/santa/start()
	var/list/candidates = pollGhostCandidates("Santa is coming to town! Do you want to be Santa?", poll_time=150)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		santa = new /mob/living/carbon/human(pick(GLOB.blobstart))
		santa.key = C.key

		santa.equipOutfit(/datum/outfit/santa)
		santa.update_icons()

		var/datum/objective/santa_objective = new()
		santa_objective.explanation_text = "Bring joy and presents to the station!"
		santa_objective.completed = 1 //lets cut our santas some slack.
		santa_objective.owner = santa.mind
		santa.mind.objectives += santa_objective
		santa.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/presents)
		var/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/telespell = new(santa)
		telespell.clothes_req = 0 //santa robes aren't actually magical.
		santa.mind.AddSpell(telespell) //does the station have chimneys? WHO KNOWS!

		to_chat(santa, "<span class='boldannounce'>You are Santa! Your objective is to bring joy to the people on this station. You can conjure more presents using a spell, and there are several presents in your bag.</span>")
