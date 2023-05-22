
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                            MEDICAL ORDERS                                                //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//9 orders

//----------------------------------------------Surgery----------------------------------------------------

/datum/centcomm_order/department/medical
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Medbay",
		)
	acct_by_string = "Medical"

/datum/centcomm_order/department/medical/kidneys/New()
	..()
	requested = list(
		/obj/item/organ/internal/kidneys = rand(1,2)
	)
	name_override = list(
		/obj/item/organ/internal/kidneys = "human kidneys"
	)
	extra_requirements = "The organs needs to be fresh, use a medical crate or a freezer."
	worth = 200*requested[requested[1]]

/datum/centcomm_order/department/medical/kidneys/ExtraChecks(var/obj/item/organ/internal/kidneys/I)
	if (!istype(I))
		return 0
	if (I.health > 0)
		return 1
	return 0

/datum/centcomm_order/department/medical/heart/New()
	..()
	requested = list(
		/obj/item/organ/internal/heart = 1
	)
	name_override = list(
		/obj/item/organ/internal/heart = "human heart"
	)
	extra_requirements = "The organ needs to be fresh, use a medical crate or a freezer."
	worth = 400

/datum/centcomm_order/department/medical/heart/ExtraChecks(var/obj/item/organ/internal/heart/I)
	if (!istype(I))
		return 0
	if (I.health > 0)
		return 1
	return 0

//----------------------------------------------Virology----------------------------------------------------

//Vaccine
/datum/centcomm_order/department/medical/vaccine
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Virology",
		)
	var/required_vac

/datum/centcomm_order/department/medical/vaccine/New()
	..()
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Vaccine"
	)
	var/difficulty = rand(1,4)
	switch (difficulty)
		if (1)
			required_vac = pick(blood_antigens)
			worth = 200
		if (2)
			required_vac = pick(common_antigens)
			worth = 400
		if (3)
			required_vac = pick(rare_antigens)
			worth = 800
		if (4)
			required_vac = pick(alien_antigens)
			worth = 1600
	extra_requirements = "Must contain [required_vac] antibodies."

/datum/centcomm_order/department/medical/vaccine/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	for(var/datum/reagent/vaccine/vaccine in V.reagents?.reagent_list)
		for (var/A in vaccine.data["antigen"])
			if (A == required_vac)
				return 1
	return 0

/datum/centcomm_order/department/medical/vaccine/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (istype(V))
		var/list/vac_data = list("antigen" = list(required_vac))
		V.reagents.add_reagent(VACCINE,V.reagents.maximum_volume,vac_data)

//Dangerous Disease Vial
/datum/centcomm_order/department/medical/harmful_disease/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Virology",
		)
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Infected Blood"
	)

	extra_requirements = "Must contain a dangerous disease with a combined Effect Danger level of at least 13, and a Strength of at least 80."
	worth = 600

/datum/centcomm_order/department/medical/harmful_disease/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	var/datum/reagent/blood/blood = locate() in V.reagents.reagent_list
	if (blood?.data["virus2"])
		var/list/blood_viruses = blood.data["virus2"]
		for (var/ID in blood_viruses)
			var/datum/disease2/disease/D = blood_viruses[ID]
			if (D.strength >= 80)
				if (D.get_total_badness() >= 13)
					return 1
	return 0

/datum/centcomm_order/department/medical/harmful_disease/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (istype(V))
		// Bacteria and memetics are blacklisted as their combined badness can never be 13 or over
		var/virus_choice = pick(subtypesof(/datum/disease2/disease) - typesof(/datum/disease2/disease/predefined) - /datum/disease2/disease/bacteria - /datum/disease2/disease/meme)
		var/datum/disease2/disease/new_virus = new virus_choice

		var/list/anti = list(
			ANTIGEN_BLOOD	= 0,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 0,
			EFFECT_DANGER_FLAVOR	= 0,
			EFFECT_DANGER_ANNOYING	= 1,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 4,
			EFFECT_DANGER_DEADLY	= 2,
			)

		while(new_virus.get_total_badness() < 13)
			new_virus.makerandom(list(80,90),list(20,90),anti,bad,src)

		var/list/blood_data = list(
			"viruses" = null,
			"blood_DNA" = null,
			"blood_type" = "O-",
			"resistances" = null,
			"trace_chem" = null,
			"virus2" = list()
		)
		blood_data["virus2"]["[new_virus.uniqueID]-[new_virus.subID]"] = new_virus
		V.reagents.add_reagent(BLOOD,V.reagents.maximum_volume,blood_data)

//Beneficial Disease Vial
/datum/centcomm_order/department/medical/beneficial_disease/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Virology",
		)
	requested = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = 1
	)
	name_override = list(
		/obj/item/weapon/reagent_containers/glass/beaker/vial = "Vial of Infected Blood"
	)

	extra_requirements = "Must contain a beneficial disease with a combined Effect Danger level of at most 2."
	worth = 1000

/datum/centcomm_order/department/medical/beneficial_disease/ExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (!istype(V))
		return 0
	var/datum/reagent/blood/blood = locate() in V.reagents.reagent_list
	if (blood?.data["virus2"])
		var/list/blood_viruses = blood.data["virus2"]
		for (var/ID in blood_viruses)
			var/datum/disease2/disease/D = blood_viruses[ID]
			if (D.get_total_badness() <= 2)
				return 1

	return 0

/datum/centcomm_order/department/medical/beneficial_disease/BuildToExtraChecks(var/obj/item/weapon/reagent_containers/glass/beaker/vial/V)
	if (istype(V))
		var/virus_choice = pick(subtypesof(/datum/disease2/disease) - typesof(/datum/disease2/disease/predefined))
		var/datum/disease2/disease/new_virus = new virus_choice

		var/list/anti = list(
			ANTIGEN_BLOOD	= 0,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 2,
			EFFECT_DANGER_FLAVOR	= 1,
			EFFECT_DANGER_ANNOYING	= 0,
			EFFECT_DANGER_HINDRANCE	= 0,
			EFFECT_DANGER_HARMFUL	= 0,
			EFFECT_DANGER_DEADLY	= 0,
			)

		while(new_virus.get_total_badness() > 2)
			new_virus.makerandom(list(80,90),list(20,90),anti,bad,src)

		var/list/blood_data = list(
			"viruses" = null,
			"blood_DNA" = null,
			"blood_type" = "O-",
			"resistances" = null,
			"trace_chem" = null,
			"virus2" = list()
		)
		blood_data["virus2"]["[new_virus.uniqueID]-[new_virus.subID]"] = new_virus
		V.reagents.add_reagent(BLOOD,V.reagents.maximum_volume,blood_data)

//Specific GNA Disks
/datum/centcomm_order/department/medical/gna_disk
	var/already_goten = list()
	var/already_generated = list()
	var/req_stage
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Virology",
		)

/datum/centcomm_order/department/medical/gna_disk/New()
	..()
	req_stage = rand(1,4)
	requested = list(
		/obj/item/weapon/disk/disease = rand (2,5)
	)
	name_override = list(
		/obj/item/weapon/disk/disease = "GNA Disks"
	)

	extra_requirements = "Each must contain a different Stage [req_stage] symptom."
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/gna_disk/ExtraChecks(var/obj/item/weapon/disk/disease/Disk)
	if (!istype(Disk))
		return 0
	if ((Disk.stage == req_stage) && Disk.effect && !(Disk.effect.type in already_goten))
		already_goten += Disk.effect.type
		return 1
	return 0

/datum/centcomm_order/department/medical/gna_disk/BuildToExtraChecks(var/obj/item/weapon/disk/disease/Disk)
	if (istype(Disk))
		Disk.stage = req_stage
		if(!Disk.effect)
			var/effect_type = null
			while(!effect_type || (effect_type in already_generated))
				effect_type = pick(subtypesof(/datum/disease2/effect))
			Disk.effect = new effect_type
			already_generated += effect_type

//----------------------------------------------Genetics----------------------------------------------------

//Clean SE
/datum/centcomm_order/department/medical/clean_se/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Genetics",
		)
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,5)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Clean SE Injector"
	)
	worth = 100 * requested[requested[1]]

/datum/centcomm_order/department/medical/clean_se/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (!I.block && I.buf)//Not a block injector
		var/datum/dna2/record/R = I.buf
		if (R.types & DNA2_BUF_SE)//SE Injector
			for (var/block in R.dna.SE)
				if (block >= 2050)
					return 0
		return 1
	return 0

/datum/centcomm_order/department/medical/clean_se/BuildToExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (istype(I))
		I.buf=new
		I.buf.dna=new
		I.buf.types = DNA2_BUF_SE
		I.buf.dna.ResetSE()

//Specific Superpowers
/datum/centcomm_order/department/medical/xray/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Genetics",
		)
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "X-Ray SE Block Injector"
	)
	worth = 200 * requested[requested[1]]

/datum/centcomm_order/department/medical/xray/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == XRAYBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & DNA2_BUF_SE)//SE Injector
			var/bstate = R.dna.GetSEState(XRAYBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/xray/BuildToExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (istype(I))
		I.buf=new
		I.buf.dna=new
		I.buf.types = DNA2_BUF_SE
		I.buf.dna.ResetSE()
		I.SetValue(0xFFF,XRAYBLOCK)

/datum/centcomm_order/department/medical/hulk/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Genetics",
		)
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Hulk SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/hulk/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == HULKBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & DNA2_BUF_SE)//SE Injector
			var/bstate = R.dna.GetSEState(HULKBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/hulk/BuildToExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (istype(I))
		I.buf=new
		I.buf.dna=new
		I.buf.types = DNA2_BUF_SE
		I.buf.dna.ResetSE()
		I.SetValue(0xFFF,HULKBLOCK)

/datum/centcomm_order/department/medical/telepathy/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Genetics",
		)
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Telepathy SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/telepathy/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == TELEPATHYBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & 4)//SE Injector
			var/bstate = R.dna.GetSEState(TELEPATHYBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/telepathy/BuildToExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (istype(I))
		I.buf=new
		I.buf.dna=new
		I.buf.types = DNA2_BUF_SE
		I.buf.dna.ResetSE()
		I.SetValue(0xFFF,TELEPATHYBLOCK)

/datum/centcomm_order/department/medical/remoteview/New()
	..()
	request_consoles_to_notify = list(
		"Chief Medical Officer's Desk",
		"Genetics",
		)
	requested = list(
		/obj/item/weapon/dnainjector = rand (1,3)
	)
	name_override = list(
		/obj/item/weapon/dnainjector = "Remote View SE Block Injector"
	)
	worth = 300 * requested[requested[1]]

/datum/centcomm_order/department/medical/remoteview/ExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (!istype(I))
		return 0
	if (I.block == REMOTEVIEWBLOCK && I.buf)//Block Injector
		var/datum/dna2/record/R = I.buf
		if (R.types & DNA2_BUF_SE)//SE Injector
			var/bstate = R.dna.GetSEState(REMOTEVIEWBLOCK)
			return bstate
	return 0

/datum/centcomm_order/department/medical/remoteview/BuildToExtraChecks(var/obj/item/weapon/dnainjector/I)
	if (istype(I))
		I.buf=new
		I.buf.dna=new
		I.buf.types = DNA2_BUF_SE
		I.buf.dna.ResetSE()
		I.SetValue(0xFFF,REMOTEVIEWBLOCK)

