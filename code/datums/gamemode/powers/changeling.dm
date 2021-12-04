

/datum/power/changeling
	var/allowduringlesserform = 0
	var/allowduringhorrorform = 1
	spellmaster = /obj/abstract/screen/movable/spell_master/changeling	

/datum/power/changeling/can_use(var/mob/user)
	if(ismonkey(user))
		if(allowduringlesserform)
			return TRUE
		else
			return FALSE
	if(ishorrorform(user))
		if(allowduringhorrorform)
			return TRUE
		else
			return FALSE
	return TRUE

/datum/power_holder/changeling 
	menu_name = "Changeling Evolution Menu"
	menu_desc = {"Hover over a power to see more information<br>
				Absorb genomes to acquire more evolution points"}
	purchase_word = "Evolve"
	currency = "Evolution Points"

/datum/power/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human. They become one with us, and we become stronger."
	cost = 0
	spellpath = /spell/changeling/absorbdna

/datum/power/changeling/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	cost = 0
	spellpath = /spell/changeling/transform
	allowduringhorrorform = 0

/datum/power/changeling/change_species
	name = "Change Species"
	desc = "We take on the apperance of a species that we have absorbed."
	cost = 0
	spellpath = /spell/changeling/changespecies
	allowduringhorrorform = 0

/datum/power/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	helptext = "Can be used before or after death. Duration varies greatly."
	cost = 0
	allowduringlesserform = 1
	spellpath = /spell/changeling/regenerate

// Hivemind

/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA you channel from the airwaves. Will not help them towards their absorb objectives."
	cost = 0
	spellpath = /spell/changeling/hiveupload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows you to absorb a single DNA and use it. Does not count towards your absorb objective."
	cost = 0
	spellpath = /spell/changeling/hivedownload

/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	cost = 1
	spellpath = /spell/changeling/lesserform
	allowduringhorrorform = 0

/datum/power/changeling/horror_form
	name = "Horror Form"
	desc = "This costly evolution allows us to transform into an all-consuming abomination. We are incredibly strong, to the point that we can force open airlocks, and are immune to conventional stuns."
	cost = 15
	spellpath = /spell/changeling/horrorform

/datum/power/changeling/deaf_sting
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	cost = 1
	allowduringlesserform = 1
	spellpath = /spell/changeling/sting/deaf

/datum/power/changeling/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	cost = 2
	allowduringlesserform = 1
	spellpath = /spell/changeling/sting/blind

/datum/power/changeling/silence_sting
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they have been stung, until they try to speak and cannot."
	cost = 2
	allowduringlesserform = 1
	spellpath = /spell/changeling/sting/mute

/datum/power/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter."
	cost = 3
	spellpath = /spell/changeling/voicechange

/datum/power/changeling/extractdna
	name = "Extract DNA"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give you the DNA of your target, allowing you to transform into them. Does not count towards absorb objectives."
	cost = 3
	allowduringlesserform = 1
	spellpath = /spell/changeling/sting/dnaextract

/datum/power/changeling/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	cost = 3
	spellpath = /spell/changeling/sting/transformation

/datum/power/changeling/paralysis_sting
	name = "Paralysis Sting"
	desc = "We silently sting a human, paralyzing them for a short time."
	cost = 4
	spellpath = /spell/changeling/sting/paralyse

/datum/power/changeling/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallucinogen."
	helptext = "The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	cost = 3
	spellpath = /spell/changeling/sting/hallucinate

/datum/power/changeling/unfat_sting
	name = "Unfat Sting"
	desc = "We silently sting a human or ourselves, forcing them to rapidly metabolize their fat."
	helptext = "Caution: This can also target you!"
	cost = 0
	spellpath = /spell/changeling/sting/unfat

/datum/power/changeling/fat_sting
	name = "Fat Sting"
	desc = "We silently sting a human or ourselves, forcing them to rapidly accumulate fat."
	helptext = "Caution: This can also target you!"
	cost = 0
	spellpath = /spell/changeling/sting/fat

/datum/power/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	helptext = "Our throat adjusts to launch the stinger."
	cost = 2

/datum/power/changeling/boost_range/add_power(var/datum/role/R)
	. = ..()
	if (!.) 
		return 
	var/datum/role/changeling/changeling = R
	if(changeling)
		changeling.sting_range = 2

/datum/power/changeling/Epinephrine
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Gives the ability to instantly recover from stuns.  High chemical cost."
	cost = 4
	spellpath = /spell/changeling/unstun

/datum/power/changeling/ChemicalSynth
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	cost = 4

/datum/power/changeling/ChemicalSynth/add_power(var/datum/role/R)
	. = ..()
	if (!.) 
		return 
	var/datum/role/changeling/changeling = R
	if(changeling)
		changeling.chem_recharge_rate *= 2

/datum/power/changeling/AdvChemicalSynth
	name = "Advanced Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	cost = 8

/datum/power/changeling/AdvChemicalSynth/add_power(var/datum/role/R)
	. = ..()
	if (!.) 
		return 
	var/datum/role/changeling/changeling = R
	if(changeling)
		changeling.chem_recharge_rate *= 2

/datum/power/changeling/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	cost = 4

/datum/power/changeling/EngorgedGlands/add_power(var/datum/role/R)
	. = ..()
	if (!.) 
		return 
	var/datum/role/changeling/changeling = R
	if(changeling)
		changeling.chem_storage += 25

/datum/power/changeling/DigitalCamoflague
	name = "Digital Camouflage"
	desc = "We evolve the ability to distort our form and proportions, defeating common algorithms used to detect lifeforms on cameras."
	cost = 3
	allowduringlesserform = 1

/datum/power/changeling/DigitalCamoflague/add_power(var/datum/role/R)
	. = ..()
	if (!.) 
		return 
	var/mob/living/carbon/human/C = R.antag.current
	to_chat(C, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	C.digitalcamo = 1



/datum/power/changeling/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	cost = 8
	spellpath = /spell/changeling/rapidregen

/datum/power/changeling/armblade
	name = "Arm Blade"
	desc = "We transform one of our arms into an organic blade that can cut through flesh and bone."
	helptext = "The blade can be retracted by using the same spell used to manifest it. It has a chance to deflect projectiles."
	cost = 5
	spellpath = /spell/changeling/armblade

// /datum/power/changeling/chemsting
// 	name = "Chemical Sting"
// 	desc = "We repurpose our internal organs to process and recreate any chemicals we have learned, ready to inject into another lifeform or ourselves if needs be."
// 	helptext = "This can be used to hinder others, or help ourselves, through the application of medicines or poisons."
// 	cost = 1
// 	spellpath = /obj/item/verbs/changeling/proc/changeling_chemsting

// /datum/power/changeling/chemspit
// 	name = "Chemical Spit"
// 	desc = "We repurpose our internal organs to process and recreate any chemicals we have learned, ready to fire like projectile venom in our facing direction."
// 	helptext = "Handy for firing acid at enemies, providing we have learned such chemicals."
// 	cost = 1
// 	allowduringlesserform = 1
// 	spellpath = /obj/item/verbs/changeling/proc/changeling_chemspit
