
/datum/reagent/proc/irradiate(var/list/current_reagents=null) //called when getting products in the fission reactor. The first param is a list of the reactor's current fuel (normalized so it sums to 1). you should always account for it being able to be null.
	return list(src.id=1.0) //by default, it will do nothing (return itself). this list is what percent of things to return. that is to say, return 100% of itself.



//the variables determining power output and fuel duration are in the reagent defines.

/datum/reagent/uranium/irradiate(var/list/current_reagents=null) //primary purpose: general purpose. gets you a bit of everything and decent power.
	return list(LEAD=0.3, PLUTONIUM=0.2, RADIUM=0.25, THALLIUM=0.1, RADON=0.15)

/datum/reagent/plutonium/irradiate(var/list/current_reagents=null) //primary purpose: pure power bay bee.
	return list(LEAD=0.5, URANIUM=0.2, RADIUM=0.2, RADON=0.1)

/datum/reagent/radium/irradiate(var/list/current_reagents=null) //primary purpose:  getting you the new materials, radon, thallium, and lead.
	return list(LEAD=0.4, RADON=0.4, THALLIUM=0.2)

/datum/reagent/radon/irradiate(var/list/current_reagents=null) //primary purpose: wasting radon. 
	return list(LEAD=1.0)
	
/datum/reagent/plasma/irradiate(var/list/current_reagents=null) //primary purpose: a very lossy way to get phazon via plasma. powergaymers rejoice.
	return list(PHAZON=0.05) //fun fact. 1 sheet of plas = 20 units. 1 sheet of phaz = 1 unit. funny, huh?
	
/datum/reagent/degeneratecalcium/irradiate(var/list/current_reagents=null)
	return list(REGENERATECALCIUM=1.0)

//these give the same reagent, but in different ratios. DD is far more efficent, but to support our ghetto chem brothers, we let them get some of this, too. not as much, though.
/datum/reagent/tricordrazine/irradiate(var/list/current_reagents=null)
	return list(EQUALIZONE=0.1)

/datum/reagent/drink/doctor_delight/irradiate(var/list/current_reagents=null)
	return list(EQUALIZONE=0.25)
