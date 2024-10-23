/mob/proc/radon_effects()

/mob/living/radon_effects()
	if(flags & INVULNERABLE)
		return
	if(!src.loc)
		return
	
	var/molesofradon=src.loc.return_air().molar_density(GAS_RADON)*CELL_VOLUME
	src.apply_radiation(molesofradon*1.5, RAD_EXTERNAL)