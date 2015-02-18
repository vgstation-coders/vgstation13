/datum/chemical_reaction/peptobismol
	name = "Peptobismol"
	id = "peptobismol"
	required_reagents = list("anti_toxin"=1, "discount"=1)
	results = list("peptobismol"=2)

/datum/chemical_reaction/phalanximine
	name = "Phalanximine"
	id = "phalanximine"
	required_reagents = list("arithrazine" = 1, "diethylamine" = 1, "mutagen" = 1)
	results = list("phalanximine"=1)

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
	results = list("sterilizine"=3)

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)
	results = list("inaprovaline"=3)

/datum/chemical_reaction/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)
	results = list("anti_toxin"=3)

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = "lexorin"
	required_reagents = list("plasma" = 1, "hydrogen" = 1, "nitrogen" = 1)
	results = list("lexorin"=3)

// Painkillers?
/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = "tramadol"
	required_reagents = list("inaprovaline" = 1, "ethanol" = 1, "oxygen" = 1)
	results = list("tramadol"=3)

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	required_reagents = list("ethanol" = 1, "tramadol" = 1, "plasma" = 1)
	results = list("oxycodone"=1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
	results = list("synaptizine"=3)

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	required_reagents = list("radium" = 1, "anti_toxin" = 1)
	results = list("hyronalin" = 2)

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
	results = list("arithrazine" = 2)

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
	results = list("impedrezene" = 2)

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	required_reagents = list("silicon" = 1, "carbon" = 1)
	results = list("kelotane" = 2)

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1)
	results = list("virusfood" = 2) // Was 5

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	required_reagents = list("silicon" = 1, "copper" = 1)
	required_catalysts = list("plasma" = 5)
	results = list("leporazine" = 2)

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
	results = list("cryptobiolin" = 3)

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	results = list("tricordrazine" = 2)

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = "alkysine"
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
	results = list("alkysine" = 2)

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	required_reagents = list("oxygen" = 2)
	required_catalysts = list("plasma" = 5)
	results = list("dexalin" = 1)

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = "dermaline"
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
	results = list("dermaline"=3)

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
	results = list("dexalinp" = 3)

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	required_reagents = list("inaprovaline" = 1, "carbon" = 1)
	results = list("bicaridine" = 2)

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
	results = list("hyperzine" = 3)

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	required_reagents = list("arithrazine" = 1, "carbon" = 1)
	results = list("ryetalyn" = 2)

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
	results = list("cryoxadone" = 3)

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	required_reagents = list("cryoxadone" = 1, "sodium" = 1)
	required_catalysts = list("plasma" = 5)
	results = list("clonexadone" = 2)

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	results = list("spaceacillin" = 2)

/datum/chemical_reaction/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	results = list("imidazoline" = 2)

/datum/chemical_reaction/inacusiate
	name = "inacusiate"
	id = "inacusiate"
	required_reagents = list("water" = 1, "carbon" = 1, "anti_toxin" = 1)
	results = list("inacusiate" = 3)

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
	results = list("ethylredoxrazine" = 3)

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
	required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
	results = list("water" = 2)

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)
	results = list("rezadone" = 3)

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
	results = list("lipozine" = 3)

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
	results = list("virusfood" = 3)