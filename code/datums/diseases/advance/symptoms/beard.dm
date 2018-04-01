/*
//////////////////////////////////////
Facial Hypertrichosis

	No change to stealth.
	Increases resistance.
	Increases speed.
	Slighlty increases transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	stealth = 0
	resistance = 3
	stage_speed = 2
	transmittable = 1
	level = 4
	severity = 1
	symptom_delay_min = 18
	symptom_delay_max = 36

/datum/symptom/beard/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(1, 2)
				to_chat(H, "<span class='warning'>Your chin itches.</span>")
				if(H.facial_hair_style == "Shaved")
					H.facial_hair_style = "Jensen Beard"
					H.update_hair()
			if(3, 4)
				to_chat(H, "<span class='warning'>You feel tough.</span>")
				if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard") && !(H.facial_hair_style == "Full Beard"))
					H.facial_hair_style = "Full Beard"
					H.update_hair()
			else
				to_chat(H, "<span class='warning'>You feel manly!</span>")
				if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard"))
					H.facial_hair_style = pick("Dwarf Beard", "Very Long Beard")
					H.update_hair()
