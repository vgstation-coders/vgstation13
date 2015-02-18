/datum/chemical_reaction/discount
	name = "Discount Dan's Special Sauce"
	id = "discount"
	required_reagents = list("irradiatedbeans"=1, "toxicwaste"=1, "refriedbeans"=1, "mutatedbeans"=1, "beff"=1, "horsemeat"=1,"moonrocks"=1, "offcolorcheese"=1, "bonemarrow"=1, "greenramen"=1, "glowingramen"=1, "deepfriedramen"=1)
	results = list("discount"=12)

/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	results = list("stoxin" = 5)

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
	results = list("chloralhydrate" = 1)

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	required_reagents = list("carpotoxin" = 5, "stoxin" = 5, "copper" = 5)
	results = list("zombiepowder" = 2)

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("plasma" = 5)
	results = list("condensedcapsaicin" = 1)

// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	results = list("ammonia" = 3)

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	results = list("diethylamine" = 2)

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1)
	results = list("cleaner" = 2)

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	required_reagents = list("toxin" = 1, "water" = 4)
	results = list("plantbgone" = 5)
