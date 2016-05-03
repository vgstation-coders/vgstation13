//Everything in this list with a / is the same datum, it just inherits and changes a var
/*

  * Traitor / DA / Enthralled
  * Changeling
  * Vampire
  * Malf AI
  * Rev / Revhead
  * Cultist
  * Wizard / Wizard Apprentice
  * Blob
  * Nuke Agent
  * Vox Raider
  * Xeno
  * Special
  * ERT/Deathsquad

*/

//This is applied to the antagonist var in a mob's mind, it holds the antag datums
/datum/antagonistholder
	var/mob/holder

	var/datum/blob
	var/datum/changeling
	var/datum/cultist
	var/datum/deathsquad //ert are considered a deathsquad
	var/datum/malf
	var/datum/nuclear
	var/datum/raider
	var/datum/revolutionary
	var/datum/special //This is for adminbus, it will show up on round end report as whatever the name var is set to. The special antagonists were: [holder] was a [name].
	var/datum/traitor
	var/datum/vampire
	var/datum/wizard //apprentices are also considered wizards
	var/datum/xeno

/datum/antagonistholder/New(var/mob/M)
	..()
	holder = M


//This is purely for the inherited holder define

/datum/antagonist
	var/mob/holder = null

/datum/antagonist/New(var/mob/M)
	..()
	holder = M

/*
******************
	CHANGELING
******************
*/

/datum/antagonist/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()
	var/mimicing = ""

/datum/antagonist/changeling/New(var/mob/M, var/gender=FEMALE)
	..(M)
	M.antagonist.changeling = src
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/antagonist/changeling/proc/regenerate()
	chem_charges = Clamp(chem_charges + chem_recharge_rate, 0, chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/antagonist/changeling/proc/GetDNA(var/dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/*
******************
	VAMPIRE
******************
*/

/datum/vampire
	var/bloodtotal = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/bloodusable = 0 // CHANGE TO ZERO WHEN PLAYTESTING HAPPENS
	var/mob/living/owner = null
	var/gender = FEMALE
	var/iscloaking = 0 // handles the vampire cloak toggle
	var/ismenacing = 0 // handles the vampire menace toggle
	var/list/powers = list() // list of available powers and passives, see defines in setup.dm
	var/mob/living/carbon/human/draining // who the vampire is draining of blood
	var/nullified = 0 //Nullrod makes them useless for a short while.
	var/smitecounter = 0 //Keeps track of how badly the vampire has been affected by holy tiles.

/datum/vampire/New(var/mob/M, gend = FEMALE)
	..(M)
	M.antagonist.vampire = src
	gender = gend