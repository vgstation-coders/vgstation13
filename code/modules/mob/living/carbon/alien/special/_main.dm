//XCOM alien code
//By Xerif (Donated by the Foundation project, ss13.org)

/mob/living/carbon/alien/humanoid/special
	has_fine_manipulation = 1
	var/xcom_state

	New()
		..()
		spawn (1)
			var/datum/reagents/R = new/datum/reagents(100)
			reagents = R
			R.my_atom = src

			mind = new()
			mind.key = key
			mind.special_role = "Special Xeno"

			name = "[name] ([rand(1, 1000)])"
			real_name = name

			stand_icon = new /icon('xcomalien.dmi', xcom_state)
			lying_icon = new /icon('xcomalien.dmi', xcom_state)
			icon = stand_icon

			remove_special_verbs()


			rebuild_appearance()

	death(gibbed)
		..()
		spawn(5)
			gib()

	Stat()
		if(statpanel("Status"))
			if(client && client.holder)
				stat(null, "([x], [y], [z])")

			stat(null, "Intent: [a_intent]")
			stat(null, "Move Mode: [m_intent]")

			if (internal)
				if (!internal.air_contents)
					qdel(internal)
					internal = null
				else
					stat("Internal Atmosphere Info", internal.name)
					stat("Tank Pressure", internal.air_contents.return_pressure())
					stat("Distribution Pressure", internal.distribute_pressure)
		return

	alien_talk()
		if(istype(src, /mob/living/carbon/alien/humanoid/special/etheral))
			..()
			return
		if(istype(src, /mob/living/carbon/alien/humanoid/special/sectoid))
			..()
			return
		return

/mob/living/carbon/alien/humanoid/special/proc/xcom_attack()
	return

/mob/living/carbon/alien/humanoid/special/proc/remove_special_verbs()
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	verbs -= /mob/living/carbon/alien/humanoid/verb/ActivateHuggers
	verbs -= /mob/living/carbon/alien/humanoid/verb/whisp
	verbs -= /mob/living/carbon/alien/humanoid/verb/transfer_plasma
	verbs -= /mob/living/carbon/alien/humanoid/verb/corrode
	return
