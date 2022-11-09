/******************************
***                         ***
***                         ***
***      TRADER GEAR        ***
*** Items that help traders ***
*** not necessarily for sale***
***                         ***
******************************/

/obj/item/weapon/coin/trader
	material=MAT_GOLD
	name = "trader coin"
	icon_state = "coin_mythril"


/obj/item/dictionary
	name = "nanodictionary"
	desc = "Prized communication tools, nanodictionaries let you learn a whole language extremely quickly. The process comes at the cost of destroying the nanodictionary itself -- this also means that only one person can make use of it, because pieces will be missing if someone else claims it."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookDummy"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "book"

	var/busy = FALSE

	var/mob/living/owner
	var/datum/language/tongue
	var/progress = 0
	var/progress_goal = 6 //How many times do you need to progress to master the language?
	var/progress_time = 10 SECONDS //How much time does it take to progress a step?
	var/progress_fail_chance = 0 //Chance of failing to advance each step

	var/list/fundamental_letters = list("a b c d e", "f g h i j", "k l m n o", "p q r s t", "u v w x y z")
	var/list/basic_words = list("hello","goodbye","please","thank you","yes","no","what is that?","how are you?","I am","from","look","see","go to","where is","I like","I understand")
	var/list/intermediate_phrases = list("How's it going?", "What have you been up to?", "How've you been?", "I've been cooking lately.", "How about we watch a movie?", "Sorry, I can't.", "Sure, it sounds good.", "Do you wanna visit the moon?", "I will not like, subscribe, or follow.", "How do I get to my hotel?", "In the restroom, is there soap in the dispenser?")
	var/list/advanced_phrases = list("I am literally an autodidact, not merely idiomatically.", "The particular characteristics of the orangutan flustered the blustering entomologist.", "I saw a kitten eating chicken in the kitchen.", "I slit the sheet, the sheet I slit, and on the slitted sheet I sit.", "She rebuffed my agastopia with a scrumptious riposte: a jam to jam my romantic ambitions.")

/obj/item/dictionary/vox/New()
	..()
	name = "pidgin nanodictionary"
	tongue = all_languages[LANGUAGE_VOX]

/obj/item/dictionary/Destroy()
	master = null
	tongue = null
	..()

/obj/item/dictionary/attack_self(mob/user)
	if(!tongue)
		to_chat(user,"<span class='danger'>This nanodictionary is blank!</span>")
		return
	if(busy)
		return
	if(tongue in user.languages)
		to_chat(user,"<span class='danger'>You already know this language!</span>")
		return
	if(!master)
		master = user
	if(master != user)
		to_chat(user,"<span class='danger'>This nanodictionary is already partially used up. Useless. You need the fundamentals.</span>.")
		return
	busy = TRUE
	if(do_after(user, src,progress_time, 10, custom_checks = new /callback(src, /obj/item/dictionary/proc/on_do_after)))
		if(prob(progress_fail_chance))
			to_chat(user,"<span class='danger'>Although you practiced your hardest, you didn't make any progress</span>.")
		else
			progress++
			if(progress<progress_goal)
				to_chat(user,"<span class='good'>You make some progress in learning.</span>")
			else
				to_chat(user,"<span class='good'>You have mastered the language!</span>")
				user.languages += tongue
				qdel(src)
	busy = FALSE

/obj/item/dictionary/proc/on_do_after(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	. =  do_after_default_checks(arglist(args))
	if(. && prob(35))
		practice(user)
	return .

/obj/item/dictionary/proc/practice(mob/user)
	var/phrase
	switch(round(progress / progress_goal,0.01))
		if(0 to 0.1) //Fundamentals - learning alphabet
			say(pick(fundamental_letters), tongue)
		if(0.11 to 0.4) //Basics - learning words, repeat in both languages
			phrase = pick(basic_words)
			say(phrase, tongue)
			user.say(phrase, user.languages[1])
		if(0.41 to 0.7) //As above, but phrases
			phrase = pick(intermediate_phrases)
			say(phrase, tongue)
			user.say(phrase, user.languages[1])
		if(0.71 to 1)
			phrase = pick(advanced_phrases)
			say(phrase, tongue)

/obj/item/dictionary/GetVoice()
	return master

//Talonifier
/obj/item/talonprosthetic
	name = "mushroom-to-talon prosthetic"
	desc = "Since the incorporation of Mushrooms into Vox culture, the more ambitious of their kind have sought the right to sign their own legal documents. In Vox culture, this requires a talon. This doesn't stop ambitious mushrooms. The wicked implement looks prepared to seize your arm by force: if you're not made of fungal matter, this will probably hurt a lot."
	icon = 'icons/obj/robot_parts.dmi'
	icon_state = "l_arm"
	item_state = "buildpipe"

/obj/item/talonprosthetic/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		to_chat(H, "<span class='warning'>You can't use this.</span>")
	if(H.organ_has_mutation(H.get_active_hand_organ(), M_TALONS))
		to_chat(H, "<span class='warning'>Your active hand is already a talon!</span>")
		return
	to_chat(H,"<span class='warning'>\The [src] begins burrowing into your arm - cutting it off to take its place!</span>")
	playsound(src, "sound/weapons/bloodyslice.ogg", 50, 1, -1)
	var/datum/organ/external/temp = H.get_active_hand_organ()
	if(!(H.species.flags & IS_PLANT))
		to_chat(H, "<span class='danger'>This was a bad idea!</span>")
		temp.explode()
		H.adjustBruteLoss(15)
		return
	if(!(H.species.flags & SPECIES_NO_MOUTH))
		to_chat(H, "<span class='danger'>Your screaming disrupts the cauterizing process!</span>")
		H.audible_scream()
		H.adjustFireLoss(17)
	temp.robotize()
	temp.species = new /datum/species/vox
	H.regenerate_icons()
	to_chat(H, "<span class='good'>You have a robotic talon!</span>")
	qdel(src)

/obj/item/weapon/card/id/vox/extra
	name = "Spare trader ID"
	desc = "A worn looking ID with access to the tradepost, able to be set once for aspiring traders."
	assignment = "Trader"
	var/canSet = TRUE

/obj/item/weapon/card/id/vox/extra/attack_self(mob/user as mob)
	if(canSet)
		var t = reject_bad_name(input(user, "What name would you like to put on this card?", "Trader ID Card Name", ishuman(user) ? user.real_name : user.name))
		if(!t) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t
		canSet = FALSE
		name = "[t]'s ID card ([assignment])"
	else
		return

/obj/item/crackerbox
	name = "crackerbox"
	desc = "The greatest invention known to birdkind. Converts unwanted, unneeded cash, into useful, beautiful crackers!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "fingerbox"
	var/status //if true, is in use.

/obj/item/crackerbox/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>Currently the conversion rate reads at [get_cash2cracker_rate()] per cracker.</span>")

/obj/item/crackerbox/proc/get_cash2cracker_rate()
	return round(10, nanocoins_rates)

/obj/item/crackerbox/attackby(obj/item/I, mob/user)
	if(!status && istype(I, /obj/item/weapon/spacecash) && user.drop_item(I, src))
		status = TRUE
		var/obj/item/weapon/spacecash/S = I
		var/crackers_to_dispense = round((S.worth*S.amount)/get_cash2cracker_rate())
		playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		if(!crackers_to_dispense)
			say("Not enough! Never enough!")
		spawn(3 SECONDS)
			say("That is enough for [crackers_to_dispense] crackers!")
			if(crackers_to_dispense > 100)
				visible_message("<span class = 'warning'>\The [src]'s matter fabrication unit overloads!</span>")
				explosion(loc, 0, prob(15), 2, 0, whodunnit = user)
				qdel(src)
				return
			for(var/x = 1 to crackers_to_dispense)
				var/obj/II = new /obj/item/weapon/reagent_containers/food/snacks/cracker(get_turf(src))
				II.throw_at(get_turf(pick(orange(7,src))), 1*crackers_to_dispense, 1*crackers_to_dispense)
				sleep(1)
			status = FALSE
		qdel(S)
		return
	..()