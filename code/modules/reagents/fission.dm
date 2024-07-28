
/datum/reagent/proc/irradiate() //called when getting products in the fission reactor.
	return list(src.id=1.0) //by default, it will do nothing (return itself). this list is what percent of things to return. that is to say, return 100% of itself.



//the variables determining power output and fuel duration are in the reagent defines.

/datum/reagent/uranium/irradiate() //primary purpose: general purpose. gets you a bit of everything and decent power.
	return list(LEAD=0.25, PLUTONIUM=0.25, RADIUM=0.25, THALLIUM=0.1, RADON=0.15)

/datum/reagent/plutonium/irradiate() //primary purpose: pure power bay bee.
	return list(LEAD=0.5, URANIUM=0.2, RADIUM=0.2, RADON=0.1)

/datum/reagent/radium/irradiate() //primary purpose:  getting you the new materials, radon, thallium, and lead.
	return list(LEAD=0.4, RADON=0.4, THALLIUM=0.2)

/datum/reagent/radon/irradiate() //primary purpose: wasting radon. 
	return list(LEAD=1.0)
	
/datum/reagent/plasma/irradiate() //primary purpose: a very lossy way to get phazon via plasma. powergaymers rejoice.
	return list(PHAZON=0.05) //fun fact. 1 sheet of plas = 20 units. 1 sheet of phaz = 1 unit. funny, huh?
	
