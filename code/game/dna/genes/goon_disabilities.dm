//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/dna/gene/disability/mute
	name = "Mute"
	desc = "Completely shuts down the speech center of the subject's brain."
	activation_message   = "You feel unable to express yourself at all."
	deactivation_message = "You feel able to speak freely again."
	sdisability = MUTE

/datum/dna/gene/disability/mute/New()
	..()
	block = MUTEBLOCK

/datum/dna/gene/disability/mute/OnSay(var/mob/M, var/datum/speech/speech)
	speech.message = ""

////////////////////////////////////////
// Harmful to others
////////////////////////////////////////

/datum/dna/gene/disability/radioactive
	name = "Radioactive"
	desc = "The subject emits radiation to nearby people, but rapidly gets rid of their own radiation."
	activation_message = "You feel a strange warmth permeate your whole body."
	deactivation_message = "You no longer feel strangely warm."
	flags = GENE_UNNATURAL

/datum/dna/gene/disability/radioactive/New()
	..()
	block = RADBLOCK

/datum/dna/gene/disability/radioactive/OnMobLife(var/mob/living/owner)
	var/radiation = owner.radiation
	var/living_radiation = round(3 * (radiation >= 10 ? radiation/10 : 1), 1) //+3 radiation for every 10 radiation above 10.
	owner.radiation = max(radiation - 30, 0)
	if(owner.getarmor(null, "rad") < 100)
		emitted_harvestable_radiation(get_turf(owner), radiation * 100, range = 3) //1 power = ~70W, are you ready for radiation engines?
		for(var/mob/living/L in orange(1, owner)) //Everyone nearby except the user
			to_chat(L, "<span class='warning'>You are enveloped by a soft green glow emanating from [owner].</span>")
			L.apply_radiation(living_radiation, RAD_EXTERNAL)

/datum/dna/gene/disability/radioactive/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "rads[fat]_s"

////////////////////////////////////////
// Other disabilities
////////////////////////////////////////

// WAS: /datum/bioEffect/fat
/datum/dna/gene/disability/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	activation_message = "You feel blubbery and lethargic!"
	deactivation_message = "You feel fit!"

/datum/dna/gene/disability/fat/can_activate(var/mob/M, var/flags)
	if(!ishuman(M))
		return 0

	var/mob/living/carbon/human/H = M
	if(H.species && !(H.species.anatomy_flags & CAN_BE_FAT))
		return 0

	return 1

/datum/dna/gene/disability/fat/activate(var/mob/M)
	if(M.overeatduration < 500)
		M.overeatduration = 600 // This ensures M_FAT activates if the mob isn't already fat

/datum/dna/gene/disability/fat/deactivate(var/mob/M,var/connected,var/flags)
	if(..() && M.nutrition <= OVEREAT_THRESHOLD)
		M.overeatduration = M.overeatduration > 600 ? M.overeatduration - 600 : 0

/datum/dna/gene/disability/fat/New()
	..()
	block = FATBLOCK

/////////////////////////
// SPEECH MANIPULATORS //
/////////////////////////

// WAS: /datum/bioEffect/smile
/datum/dna/gene/disability/smile
	name = "Smile"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin and a chemical resembling ecstacy when engaged."
	activation_message = "You feel so happy. Nothing can be wrong with anything :)"
	deactivation_message = "Everything is terrible again. :("

/datum/dna/gene/disability/smile/New()
	..()
	block = SMILEBLOCK
	speech_filter = new /datum/speech_filter/smile

/datum/dna/gene/disability/smile/OnSay(var/mob/M, var/datum/speech/speech)
	..()
	if(prob(30))
		speech.message += " check your privilege."


// WAS: /datum/bioEffect/elvis
/datum/dna/gene/disability/elvis
	name = "Elvis"
	desc = "Forces the language center and primary motor cortex of the subject's brain to talk and act like the King of Rock and Roll."
	activation_message = "You feel pretty good, honeydoll."
	deactivation_message = "You feel a little less conversation would be great."

/datum/dna/gene/disability/elvis/New()
	..()
	block = ELVISBLOCK
	speech_filter = new /datum/speech_filter/elvis

/datum/dna/gene/disability/elvis/OnSay(var/mob/M, var/datum/speech/speech)
	if(prob(5))
		M.visible_message("<b>[M]</b> [pick("rambles to themselves.","begins talking to themselves.")]")
		return 1
	..()

/datum/dna/gene/disability/elvis/OnMobLife(var/mob/M)
	switch(pick(1,2))
		if(1)
			if(prob(15))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				M.visible_message("<b>[M]</b> busts out some [dancemoves] moves!")
		if(2)
			if(prob(15))
				M.visible_message("<b>[M]</b> [pick("jiggles their hips.", "rotates their hips.", "gyrates their hips.", "taps their foot.", "dances to an imaginary song.", "jiggles their legs.", "snaps their fingers.")]")


// WAS: /datum/bioEffect/chav
/datum/dna/gene/disability/chav
	name = "Chav"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	activation_message = "Ye feel like a reet prat like, innit?"
	deactivation_message = "You no longer feel like being rude and sassy."
	mutation = M_CHAV

/datum/dna/gene/disability/chav/New()
	..()
	block = CHAVBLOCK
	speech_filter = new /datum/speech_filter/chav

// WAS: /datum/bioEffect/swedish
/datum/dna/gene/disability/swedish
	name = "Swedish"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	activation_message = "You feel Swedish, however that works."
	deactivation_message = "The feeling of Swedishness passes."
	mutation = M_SWEDE

/datum/dna/gene/disability/swedish/New()
	..()
	block=SWEDEBLOCK
	speech_filter = new /datum/speech_filter/swedish

/datum/dna/gene/disability/swedish/OnSay(var/mob/M, var/datum/speech/speech)
	// svedish!
	..()
	if(prob(30))
		speech.message += " Bork[pick("",", bork",", bork, bork")]!"

// WAS: /datum/bioEffect/unintelligable
/datum/dna/gene/disability/unintelligable
	name = "Unintelligable"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	activation_message = "You can't seem to form any coherent thoughts!"
	deactivation_message = "Your mind feels more clear."

/datum/dna/gene/disability/unintelligable/New()
	..()
	block = SCRAMBLEBLOCK

/datum/dna/gene/disability/unintelligable/OnSay(var/mob/M, var/datum/speech/speech)
	var/prefix=copytext(speech.message,1,2)
	if(prefix == ";")
		speech.message = copytext(speech.message,2)
	else if(prefix in list(":","#"))
		prefix += copytext(speech.message,2,3)
		speech.message = copytext(speech.message,3)
	else
		prefix=""

	var/list/words = splittext(speech.message," ")
	var/list/rearranged = list()
	for(var/i=1;i<=words.len;i++)
		var/cword = pick(words)
		words.Remove(cword)
		var/suffix = copytext(cword,length(cword)-1,length(cword))
		while(length(cword)>0 && (suffix in list(".",",",";","!",":","?")))
			cword  = copytext(cword,1              ,length(cword)-1)
			suffix = copytext(cword,length(cword)-1,length(cword)  )
		if(length(cword))
			rearranged += cword
	speech.message = "[prefix][uppertext(jointext(rearranged," "))]!!"

// WAS: /datum/bioEffect/toxic_farts
/datum/dna/gene/disability/toxic_farts
	name = "Toxic Farts"
	desc = "Causes the subject's digestion to create a significant amount of noxious gas."
	activation_message = "Your stomach grumbles unpleasantly."
	deactivation_message = "Your stomach stops acting up. Phew!"
	flags = GENE_UNNATURAL

	mutation = M_TOXIC_FARTS

/datum/dna/gene/disability/toxic_farts/New()
	..()
	block=TOXICFARTBLOCK

//////////////////
// USELESS SHIT //
//////////////////


// WAS: /datum/bioEffect/horns
/datum/dna/gene/disability/horns
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_message = "A pair of horns erupt from your head."
	deactivation_message = "Your horns crumble away into nothing."
	flags = GENE_UNNATURAL
	mutation = M_HORNS

/datum/dna/gene/disability/horns/New()
	..()
	block = HORNSBLOCK

/datum/dna/gene/disability/horns/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "horns_s"

////////////////////////////////////////////////////////////////////////
// WAS: /datum/bioEffect/immolate
/datum/dna/gene/basic/grant_spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	flags = GENE_UNNATURAL
	activation_messages = list("You suddenly feel rather hot.")
	deactivation_messages = list("You no longer feel uncomfortably hot.")

	spelltype = /spell/targeted/immolate

/datum/dna/gene/basic/grant_spell/immolate/New()
	..()
	block = IMMOLATEBLOCK

/spell/targeted/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC

	charge_type = Sp_RECHARGE
	charge_max = 600

	spell_flags = INCLUDEUSER
	invocation_type = SpI_NONE
	range = SELFCAST
	max_targets = 1
	selection_type = "range"
	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	cast_sound = 'sound/effects/bamf.ogg'

	hud_state = "gen_immolate"
	override_base = "genetic"

/spell/targeted/immolate/cast(list/targets)
	..()
	for(var/mob/living/target in targets)
		target.adjust_fire_stacks(0.5) // Same as walking into fire. Was 100 (goon fire)
		target.visible_message("<span class='danger'><b>[target.name]</b> suddenly bursts into flames!</span>")
		target.on_fire = 1
		target.update_icon = 1

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/melt
/datum/dna/gene/basic/grant_spell/melt
	name = "Self Biomass Manipulation"
	desc = "The subject becomes able to transform the matter of their cells into a liquid state."
	flags = GENE_UNNATURAL
	activation_messages = list("You feel strange and jiggly.")
	deactivation_messages = list("You feel more solid.")

	spelltype = /spell/targeted/melt

/datum/dna/gene/basic/grant_spell/melt/New()
	..()
	block = MELTBLOCK

/spell/targeted/melt
	name = "Dissolve"
	desc = "Transform yourself into a liquified state."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC

	charge_type = Sp_RECHARGE
	charge_max = 200

	spell_flags = INCLUDEUSER | STATALLOWED
	invocation_type = SpI_NONE
	range = SELFCAST
	max_targets = 1
	selection_type = "range"

	override_base = "genetic"
	hud_state = "gen_dissolve"

/spell/targeted/melt/cast(var/list/targets, mob/user)
	for(var/mob/M in targets)
		if (istype(M,/mob/living/carbon/human/))
			var/mob/living/carbon/human/H = M
			var/no_blood = (H.species.flags & NO_BLOOD)
			if(isskellington(H))
				to_chat(H, "<span class='warning'>You have no flesh left to melt!</span>")
				return 0
			if(isvox(H))
				H.set_species("Skeletal Vox")
				H.regenerate_icons()
				H.visible_message("<span class='danger'>[H.name]'s flesh melts right off! Holy shit!</span>")
				H.drop_all()
			else if(H.set_species("Skellington"))
				H.regenerate_icons()
				H.visible_message("<span class='danger'>[H.name]'s flesh melts right off! Holy shit!</span>")
				H.drop_all()

			if (!no_blood)
				gibs(H.loc, H.virus2, H.dna)
		else
			M.visible_message("<span class='danger'>[usr.name] melts into a pile of bloody viscera!</span>")
			M.drop_all()
			M.gib(1)
