
var/list/all_antigens = list(
	ANTIGEN_O,
	ANTIGEN_A,
	ANTIGEN_B,
	ANTIGEN_RH,
	ANTIGEN_Q,
	ANTIGEN_U,
	ANTIGEN_V,
	ANTIGEN_M,
	ANTIGEN_N,
	ANTIGEN_P,
	ANTIGEN_X,
	ANTIGEN_Y,
	ANTIGEN_Z,
)
var/list/blood_antigens = list(
	ANTIGEN_O,
	ANTIGEN_A,
	ANTIGEN_B,
	ANTIGEN_RH,
)
var/list/common_antigens = list(
	ANTIGEN_Q,
	ANTIGEN_U,
	ANTIGEN_V,
)
var/list/rare_antigens = list(
	ANTIGEN_M,
	ANTIGEN_N,
	ANTIGEN_P,
)
var/list/alien_antigens = list(
	ANTIGEN_X,
	ANTIGEN_Y,
	ANTIGEN_Z,
)


// pure concentrated antibodies
datum/reagent/antibodies
	data = list("antibodies"=0)
	name = "Antibodies"
	id = "antibodies"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#0050F0"

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(!iscarbon(M))
			return
		var/mob/living/carbon/dude = M
		if(src.data && method == INGEST)
			if(dude.virus2)
				if(src.data["antibodies"] & dude.virus2.antigen)
					dude.virus2.dead = 1
			dude.antibodies |= src.data["antibodies"]

// iterate over the list of antigens and see what matches
/proc/antigens2string(var/antigens)
	var/code = ""
	for(var/V in ANTIGENS) if(text2num(V) & antigens) code += ANTIGENS[V]
	return code
