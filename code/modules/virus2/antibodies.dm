
// reserving some numbers for later special antigens
var/const/ANTIGEN_A  = 1
var/const/ANTIGEN_B  = 2
var/const/ANTIGEN_RH = 4
var/const/ANTIGEN_Q  = 8
var/const/ANTIGEN_U  = 16
var/const/ANTIGEN_V  = 32
var/const/ANTIGEN_X  = 64
var/const/ANTIGEN_Y  = 128
var/const/ANTIGEN_Z  = 256
var/const/ANTIGEN_M  = 512
var/const/ANTIGEN_N  = 1024
var/const/ANTIGEN_P  = 2048
var/const/ANTIGEN_O  = 4096

var/list/ANTIGENS = list(
"[ANTIGEN_A]" = "A",
"[ANTIGEN_B]" = "B",
"[ANTIGEN_RH]" = "RH",
"[ANTIGEN_Q]" = "Q",
"[ANTIGEN_U]" = "U",
"[ANTIGEN_V]" = "V",
"[ANTIGEN_Z]" = "Z",
"[ANTIGEN_M]" = "M",
"[ANTIGEN_N]" = "N",
"[ANTIGEN_P]" = "P",
"[ANTIGEN_O]" = "O"
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
