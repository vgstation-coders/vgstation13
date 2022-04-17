
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
	ANTIGEN_CULT,
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
var/list/special_antigens = list(
	ANTIGEN_CULT,
)

/proc/antigen_family(var/id)
	switch(id)
		if (ANTIGEN_BLOOD)
			return blood_antigens
		if (ANTIGEN_COMMON)
			return common_antigens
		if (ANTIGEN_RARE)
			return rare_antigens
		if (ANTIGEN_ALIEN)
			return alien_antigens
		if(ANTIGEN_SPECIAL)
			return special_antigens