/mob/proc/make_changeling()
	if(!mind)
		return
	var/datum/role/changeling/C = mind.GetRole(CHANGELING)
	if(!C)
		return

	var/lesserform = ishuman(src)
	for(var/datum/power/changeling/power in C.current_powers)
		if(power.allowduringlesserform && lesserform)
			continue
		power.grant_spell(C)

	var/mob/living/carbon/human/H = src
	dna.flavor_text = H.flavor_text
	if(!(M_HUSK in H.mutations))
		C.absorbed_dna |= dna
		if(istype(H))
			C.absorbed_species |= H.species.name

	for(var/language in languages)
		C.absorbed_languages |= language
	updateChangelingHUD()
	return 1

/mob/proc/updateChangelingHUD()
	if(hud_used)
		var/datum/role/changeling/changeling = mind.GetRole(CHANGELING)
		if(!changeling)
			return
		if(!hud_used.vampire_blood_display)
			hud_used.changeling_hud()
			//hud_used.human_hud(hud_used.ui_style)
		hud_used.vampire_blood_display.maptext_width = WORLD_ICON_SIZE*2
		hud_used.vampire_blood_display.maptext_height = WORLD_ICON_SIZE
		var/C = round(changeling.chem_charges)
		hud_used.vampire_blood_display.maptext = "<div align='left' valign='top' style='position:relative; top:0px; left:6px'>\
				C:<font color='#EAB67B'>[C]</font><br>\
				G:<font color='#FF2828'>[changeling.absorbedcount]</font><br>\
				[changeling.geneticdamage ? "GD: <font color='#8b0000'>[changeling.geneticdamage]</font>" : ""]\
				</div>"
	return

//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(var/updated_languages)


	languages.len = 0
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")