
/datum/dna/gene/disability/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_message = "YOU FEEL LIKE YELLING!"
	deactivation_message = "You feel like being quiet.."

/datum/dna/gene/disability/loud/New()
	..()
	block = LOUDBLOCK

/datum/dna/gene/disability/loud/OnSay(var/mob/M, var/datum/speech/speech)
	speech.message = replacetext(speech.message,".","!")
	speech.message = replacetext(speech.message,"?","?!")
	speech.message = replacetext(speech.message,"!","!!")

	speech.message = uppertext(speech.message)


/datum/dna/gene/disability/whisper
	name = "Quiet"
	desc = "Damages the subjects vocal cords"
	activation_message = "<i>Your throat feels sore..</i>"
	deactivation_message = "You feel fine again."

/datum/dna/gene/disability/whisper/New()
	..()
	block = WHISPERBLOCK

/datum/dna/gene/disability/whisper/can_activate(var/mob/M,var/flags)
	// No loud whispering.
	if(M_LOUD in M.mutations)
		return 0
	return ..(M,flags)

/datum/dna/gene/disability/whisper/OnSay(var/mob/M, var/datum/speech/speech)
	//M.whisper(message)
	return 0


/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_message = "You feel very dizzy..."
	deactivation_message = "You regain your balance."
	flags = GENE_UNNATURAL

/datum/dna/gene/disability/dizzy/New()
	..()
	block = DIZZYBLOCK

/datum/dna/gene/disability/dizzy/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(M_DIZZY in M.mutations)
		M.Dizzy(300)


/datum/dna/gene/disability/sans
	name = "Wacky"
	desc = "Forces the subject to talk in an odd manner."
	activation_message = "You feel an off sensation in your voicebox.."
	deactivation_message = "The off sensation passes.."

/datum/dna/gene/disability/sans/New()
	..()
	block = SANSBLOCK

/datum/dna/gene/disability/sans/OnSay(var/mob/M, var/datum/speech/speech)
	speech.message_classes.Add("sans") // SPEECH 2.0!!!1

/datum/dna/gene/disability/veganism
	name = "Veganism"
	desc = "Causes the digestive system to completely reject all animal products, from meat to dairy."
	activation_message = "You feel vegan."
	deactivation_message = "You're back on top of the food chain."

	mutation = M_VEGAN

	var/static/list/nonvegan_reagents = list(
		HONEY,
		//Milk-based products
		MILK,
		VIRUSFOOD,
		CREAM,
		CAFE_LATTE,
		MILKSHAKE,
		OFFCOLORCHEESE,
		CHEESYGLOOP, //this one doesn't leave your body naturally, but you'll vomit it out eventually
		//Blood-based products
		BLOOD,
		DEMONSBLOOD,
		RED_MEAD,
		DEVILSKISS,
		MEDCOFFEE,
		//Misc
		HORSEMEAT,
		BONEMARROW,
	)

/datum/dna/gene/disability/veganism/New()
	..()
	block = VEGANBLOCK

/datum/dna/gene/disability/veganism/OnMobLife(var/mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(prob(10))
		for(var/R in nonvegan_reagents)
			if(H.reagents.has_reagent(R))
				to_chat(H, "<span class='warning'>Your body rejects the [reagent_name(R)]!</span>")

				if(H.lastpuke) //If already puking, add some toxins
					H.adjustToxLoss(2.5)
				else
					H.vomit()
				break

/datum/dna/gene/disability/asthma
	name = "Asthma"
	desc = "A condition in which a person's airways become inflamed, narrow and swell, and produce extra mucus, which makes it difficult to breathe."
	activation_message = "You feel short of breath."
	deactivation_message = "You can breathe normally again."
	disability = ASTHMA
	flags = GENE_UNNATURAL
	mutation = M_ASTHMA

/datum/dna/gene/disability/asthma/New()
	..()
	block = ASTHMABLOCK

var/list/milk_reagents = list(
	MILK,
	CREAM,
	VIRUSFOOD,
	OFFCOLORCHEESE,
	CHEESYGLOOP,
	ALOE,
	BANANAHONK,
	BILK,
	CAFE_LATTE,
	MILKSHAKE,
	BAREFOOT,
	PINACOLADA,
	BOOGER,
	BROWNSTAR,
	IRISHCARBOMB,
	IRISHCOFFEE,
	IRISHCREAM,
	SILENCER,
	DOCTORSDELIGHT,
	WHITERUSSIAN,
	ANTIFREEZE)


/datum/dna/gene/disability/lactose
	name = "Lactose intolerance"
	desc = "A condition where your body is unable to digest Lactose, a sugar commonly found in milk."
	activation_message = "Your stomach feels upset and bloated."
	deactivation_message = "The discomfort in your stomach fades away."
	disability = LACTOSE

	mutation = M_LACTOSE

/datum/dna/gene/disability/lactose/New()
	..()
	block = LACTOSEBLOCK

/datum/dna/gene/disability/lactose/OnMobLife(var/mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(prob(10))
		for(var/R in milk_reagents)
			if(H.reagents.has_reagent(R))
				to_chat(H, "<span class='warning'>Your body rejects the [reagent_name(R)]!</span>")

				if(H.lastpuke) //If already puking, add some toxins
					H.adjustToxLoss(2.5)
				else
					H.vomit()
				break
