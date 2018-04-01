/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 0
	level = 5
	severity = 0

/datum/symptom/undead_adaptation/Start(datum/disease/advance/A)
	if(!..())
		return
	A.process_dead = TRUE
	A.infectable_hosts |= SPECIES_UNDEAD

/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmittable = 3
	level = 5
	severity = 0

/datum/symptom/inorganic_adaptation/Start(datum/disease/advance/A)
	if(!..())
		return
	A.infectable_hosts |= SPECIES_INORGANIC