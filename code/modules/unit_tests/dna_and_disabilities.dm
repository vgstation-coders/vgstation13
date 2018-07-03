/datum/unit_test/dna_and_disabilities

/datum/unit_test/dna_and_disabilities/start()
	for(var/disability_type in subtypesof(/datum/dna/gene/disability))
		var/datum/dna/gene/disability/instance = new disability_type

		if(!instance.activation_message)
			fail("[disability_type] does not specify an activation message.")
		if(!instance.deactivation_message)
			fail("[disability_type] does not specify a deactivation message.")
