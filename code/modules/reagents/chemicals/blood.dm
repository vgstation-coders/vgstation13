/datum/reagent/blood
	data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#a00000" // rgb: 160, 0, 0

/datum/reagent/blood/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/blood/self = src
	src = null
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			// We don't spread.
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

			if(method == TOUCH)
				M.contract_disease(D)
			else //injected
				M.contract_disease(D, 1, 0)
	if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
		if(method == TOUCH)
			infect_virus2(M,self.data["virus2"], notes="(Contact with blood)")
		else
			infect_virus2(M,self.data["virus2"],1, notes="(INJECTED)") //injected, force infection!
	if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
		var/mob/living/carbon/C = M
		C.antibodies |= self.data["antibodies"]

	if(istype(M, /mob/living/carbon/human) && (method == TOUCH))
		var/mob/living/carbon/human/H = M
		H.bloody_body(self.data["donor"])
		if(self.data["donor"])
			H.bloody_hands(self.data["donor"])
		spawn()//bloody feet, result of the blood that fell on the floor
			var/obj/effect/decal/cleanable/blood/B = locate() in get_turf(H)

			if (B)
				B.Crossed(H)
		H.update_icons()

/datum/reagent/blood/on_merge(var/data)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/on_update(var/atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
	if(!istype(T)) return
	var/datum/reagent/blood/self = src
	src = null
	if(!(volume >= 3)) return
	//var/datum/disease/D = self.data["virus"]
	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = getFromPool(/obj/effect/decal/cleanable/blood,T)
			blood_prop.New(T)
			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus

	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		blood_splatter(T,self,1)
	else if(istype(self.data["donor"], /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,self,1)
		if(B) B.blood_DNA["Non-Human DNA"] = "A+"
	else if(istype(self.data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,self,1)
		if(B) B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
	return
