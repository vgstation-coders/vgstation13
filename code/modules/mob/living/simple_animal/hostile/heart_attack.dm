/mob/living/simple_animal/hostile/heart_attack
	name = "heart"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	icon_dead = "heart-off"
	environment_smash_flags = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	health = 50
	maxHealth = 50
	stat_attack = 1
	var/blood_data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O+",
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		)
	var/datum/dna/source_dna

/mob/living/simple_animal/hostile/heart_attack/proc/update_heart(var/obj/item/organ/internal/heart/source, var/datum/dna/_dna, var/list/vir = list())
	if (!istype(source))
		return
	appearance = source.appearance
	blood_data = source.blood_data
	blood_data["virus2"] = vir
	source_dna = _dna


/mob/living/simple_animal/hostile/heart_attack/death(var/gibbed = FALSE)
	..()
	visible_message("<b>[src]</b> blows apart!")
	hgibs(loc, blood_data["virus2"], source_dna, blood_data["blood_colour"], blood_data["blood_colour"], 2)
	qdel(src)

/mob/living/simple_animal/hostile/heart_attack/UnarmedAttack(var/atom/A)
	..()
	var/datum/reagent/blood/B = new
	B.data = blood_data
	blood_splatter(loc,B,TRUE)
