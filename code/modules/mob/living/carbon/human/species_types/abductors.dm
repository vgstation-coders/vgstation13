/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = FALSE
	species_traits = list(SPECIES_ORGANIC,NOBLOOD,NOEYES)
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_NOGUNS,TRAIT_NOHUNGER,TRAIT_NOBREATH)
	mutanttongue = /obj/item/organ/tongue/abductor
	var/scientist = FALSE // vars to not pollute spieces list with castes

/datum/species/abductor/copy_properties_from(datum/species/abductor/old_species)
	scientist = old_species.scientist

/datum/species/abductor/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(C)

/datum/species/abductor/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(C)
