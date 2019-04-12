
/datum/borer_chem
	var/id = ""
	var/name = ""
	var/cost = 1 // Per dose delivered.
	var/dose_size = 15

	var/unlockable=0

/datum/borer_chem/New()
	if(!id)
		return
	var/datum/reagent/C = chemical_reagents_list[id]
	name = C.name

/datum/borer_chem/head
/datum/borer_chem/chest
/datum/borer_chem/arm
/datum/borer_chem/leg

/datum/borer_chem/head/bicaridine
	id = BICARIDINE

/datum/borer_chem/head/tramadol
	id = TRAMADOL

/datum/borer_chem/head/alkysine
	id = ALKYSINE
	//cost = 0

/datum/borer_chem/head/ryetalyn
	id = RYETALYN

/datum/borer_chem/head/methylin
	id = METHYLIN

/datum/borer_chem/chest/blood
	id = BLOOD

/datum/borer_chem/chest/imidazoline
	id = IMIDAZOLINE

/datum/borer_chem/chest/inacusiate
	id = INACUSIATE

/datum/borer_chem/chest/lipozine
	id = LIPOZINE

/datum/borer_chem/chest/ethylredoxrazine
	id = ETHYLREDOXRAZINE

/datum/borer_chem/chest/oxycodone
	id = OXYCODONE

/datum/borer_chem/chest/radium
	id = RADIUM

/datum/borer_chem/chest/leporazine
	id = LEPORAZINE

/datum/borer_chem/chest/charcoal
	id = CHARCOAL
	cost = 2

/datum/borer_chem/chest/anti_toxin
	id = ANTI_TOXIN

/datum/borer_chem/chest/inaprovaline
	id = INAPROVALINE
	cost = 2

/datum/borer_chem/arm/bicaridine
	id = BICARIDINE
	cost = 2

/datum/borer_chem/arm/kelotane
	id = KELOTANE
	cost = 2

/datum/borer_chem/leg/hyperzine
	id = HYPERZINE

////////////////////////////
// UNLOCKABLES
////////////////////////////

//datum/borer_chem/unlockable
//	unlockable=1

/datum/borer_chem/head/unlockable
	unlockable=1
/datum/borer_chem/chest/unlockable
	unlockable=1
/datum/borer_chem/arm/unlockable
	unlockable=1
/datum/borer_chem/leg/unlockable
	unlockable=1

/datum/borer_chem/head/unlockable/space_drugs
	id = SPACE_DRUGS
	cost = 2

/datum/borer_chem/head/unlockable/paracetamol
	id = PARACETAMOL
	cost = 2

/datum/borer_chem/head/unlockable/dexalin
	id = DEXALIN
	cost = 2

/datum/borer_chem/head/unlockable/dexalinp
	id = DEXALINP
	cost = 2

/datum/borer_chem/head/unlockable/peridaxon
	id = PERIDAXON
	cost = 2

/datum/borer_chem/head/unlockable/rezadone
	id = REZADONE
	cost = 2

/datum/borer_chem/chest/unlockable/nutriment
	id = NUTRIMENT
	cost = 2

/datum/borer_chem/chest/unlockable/paismoke
	id = PAISMOKE
	cost = 15

/datum/borer_chem/chest/unlockable/arithrazine
	id = ARITHRAZINE
	cost = 2

/datum/borer_chem/chest/unlockable/capsaicin
	id = CAPSAICIN
	cost = 2

/datum/borer_chem/chest/unlockable/frostoil
	id = FROSTOIL
	cost = 2

/datum/borer_chem/chest/unlockable/clottingagent
	id = CLOTTING_AGENT
	cost = 10

/datum/borer_chem/chest/unlockable/dermaline
	id = DERMALINE
	cost = 2

/datum/borer_chem/arm/unlockable/cafe_latte
	id = CAFE_LATTE
	cost = 1

/datum/borer_chem/arm/unlockable/iron
	id = IRON
	cost = 1

/datum/borer_chem/leg/unlockable/bustanut
	id = BUSTANUT
	cost = 2

/datum/borer_chem/leg/unlockable/synaptizine
	id = SYNAPTIZINE
	cost = 2