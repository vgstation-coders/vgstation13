
/datum/body_archive // basically /datum/mind scans its mob when first created, allowing the original body to be re-created if needed
	var/mob_type
	var/datum/dna2/record/dna_records

/datum/body_archive/New(var/mob/source)
	if (!source)
		qdel(src)
		return
	..()
	mob_type = source.type
	if (ishuman(source))
		var/mob/living/carbon/human/H = source
		var/datum/organ/internal/brain/Brain = H.internal_organs_by_name["brain"]

		var/datum/dna2/record/R = new /datum/dna2/record()
		if(!isnull(Brain.owner_dna) && Brain.owner_dna != H.dna)
			R.dna = Brain.owner_dna.Clone()
		else
			R.dna = H.dna.Clone()
		R.ckey = H.ckey
		R.id= copytext(md5(R.dna.real_name), 2, 6)
		R.name=R.dna.real_name
		R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
		R.languages = H.languages.Copy()
		R.attack_log = H.attack_log.Copy()
		R.default_language = H.default_language
		R.times_cloned = H.times_cloned
		R.talkcount = H.talkcount

		dna_records = R

/////////////////////////////////////////////

/mob/proc/reset_body(var/datum/body_archive/archive)
	if (!archive)
		if (mind && mind.body_archive)
			archive = mind.body_archive
		else
			return

	var/mob/new_mob
	// can't just do a /mob/living/carbon/human/reset_body() since the mob might have changed to a non-human since then
	if (archive.mob_type in typesof(/mob/living/carbon/human))
		var/datum/dna2/record/R = archive.dna_records
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(loc, R.dna.species, delay_ready_dna = TRUE)
		H.times_cloned = 0
		H.talkcount = R.talkcount
		if(isplasmaman(H))
			H.fire_sprite = "Plasmaman"
		H.dna = R.dna.Clone()
		H.dna.flavor_text = R.dna.flavor_text
		H.dna.species = R.dna.species
		if(H.dna.species != "Human")
			H.set_species(H.dna.species, TRUE)
		H.check_mutations = TRUE
		H.updatehealth()
		has_been_shade -= mind
		mind.transfer_to(H)
		H.ckey = R.ckey
		if (H.mind.miming)
			H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
			if (H.mind.miming == MIMING_OUT_OF_CHOICE)
				H.add_spell(new /spell/targeted/oathbreak/)
		if (isvampire(H))
			var/datum/role/vampire/V = isvampire(H)
			V.check_vampire_upgrade()
			V.update_vamp_hud()
		H.UpdateAppearance()
		H.set_species(R.dna.species)
		H.dna.mutantrace = R.dna.mutantrace
		H.update_mutantrace()
		for(var/datum/language/L in R.languages)
			H.add_language(L.name)
			if (L == R.default_language)
				H.default_language = R.default_language
		H.attack_log = R.attack_log
		H.real_name = H.dna.real_name
		H.name = H.real_name
		H.flavor_text = H.dna.flavor_text
		if(H.mind)
			H.mind.suiciding = FALSE
		H.update_name()
		if (H.client)
			H.client.eye = H.client.mob
			H.client.perspective = MOB_PERSPECTIVE
		H.updatehealth()
		domutcheck(H)
		new_mob = H

	else

		new_mob = new archive.mob_type(loc)
		mind.transfer_to(new_mob)

	drop_all()
	qdel(src)
	return new_mob
