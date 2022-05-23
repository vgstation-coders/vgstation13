//Blessings and curses that confer (un)luck to a mob.
/datum/blesscurse
	var/blesscurse_name		//string: Name of the blessing or curse.
	var/blesscurse_strength	//number: How much luck (+) or unluck (-) the blessing or curse confers.

//Curse when someone breaks a mirror.
/datum/blesscurse/brokenmirror
	blesscurse_name = "mirror-breaker curse"
	blesscurse_strength = -50

//Curse when someone spills salt. Requires accidental reagent-spilling to be re-implmented.
/datum/blesscurse/saltspiller
	blesscurse_name = "salt-spiller curse"
	blesscurse_strength = -50

//Curse when a mime breaks their vow of silence.
/datum/blesscurse/mimevowbreak
	blesscurse_name = "vow-of-silence-breaker curse"
	blesscurse_strength = -250